require 'rubygems'
require 'httparty'
require 'hashie'
require 'oauth'

module Foursquare
  class OAuth
    def initialize(ctoken, csecret, options={})
      @consumer_token, @consumer_secret = ctoken, csecret
    end
  
    def consumer
      return @consumer if @consumer
      @consumer = ::OAuth::Consumer.new(@consumer_token, @consumer_secret, {
        :site               => "http://foursquare.com",
        :scheme             => :header,
        :http_method        => :post,
        :request_token_path => "/oauth/request_token",
        :access_token_path  => "/oauth/access_token",
        :authorize_path     => "/oauth/authorize",
        :proxy              => (ENV['HTTP_PROXY'] || ENV['http_proxy'])
      })
    end
  
    def set_callback_url(url)
      clear_request_token
      request_token(:oauth_callback => url)
    end
    
    def request_token(options={})
      @request_token ||= consumer.get_request_token(options)
    end
  
    def authorize_from_request(request_token, request_secret, verifier)
      request_token = ::OAuth::RequestToken.new(consumer, request_token, request_secret)
      access_token = request_token.get_access_token(:oauth_verifier => verifier)
      @atoken, @asecret = access_token.token, access_token.secret
    end
  
    def access_token
      @access_token ||= ::OAuth::AccessToken.new(consumer, @atoken, @asecret)
    end
  
    def authorize_from_access(atoken, asecret)
      @atoken, @asecret = atoken, asecret
    end
    
    private
    
    def clear_request_token
      @request_token = nil
    end
  end
  
  class Base
    BASE_URL = 'http://api.foursquare.com/v1'
    FORMAT = 'json'
    
    def initialize(oauth)
      @oauth = oauth
    end
    
    #
    # Foursquare API: http://groups.google.com/group/foursquare-api/web/api-documentation
    #
    # .test                                          # api test method
    #  => {'response': 'ok'}
    # .checkin = {:shout => 'At home. Writing code'} # post new check in
    #  => {...checkin hashie...}
    # .history                                       # authenticated user's checkin history
    # => [{...checkin hashie...}, {...another checkin hashie...}]
    # .send('venue.flagclosed', {:vid => 12345})     # flag venue 12345 as closed
    # => {'response': 'ok'}
    #
    def method_missing(method_symbol, *args)
      method_name = method_symbol.to_s.split('.').join('/')
      
      if %w(=).include?(method_name[-1,1])
        method = method_name[0..-2]
        operator = method_name[-1,1]
        if operator == '='
          post(url_for(method), args.first)
        end
      else
        get(url_for(method_name, args.first))
      end
    end
    
    def url_for(method_name, options = nil)
      params = options.is_a?(Hash) ? to_query_params(options) : options
      params = nil if params and params.blank?
      
      
      (BASE_URL + '/' + method_name.split('.').join('/') + '.' + FORMAT + (params ? ('?' + params) : ''))
    end
    
    def parse_response(response)
      raise_errors(response)
      Hashie::Mash.new(Crack::JSON.parse(response.body))
    end
    
    def to_query_params(options)
      options.collect { |key, value| "#{key}=#{value}" }.join('&')
    end
    
    def get(url)
      parse_response(@oauth.access_token.get(url))
    end
    
    def post(url, body)
      parse_response(@oauth.access_token.post(url, body))
    end
    
    # API methods
    
    def checkin(body = {})
      unless body[:vid] || body[:venue] || body[:shout]
        raise ArgumentError, "A vid(venue id), venue or shout is required to checkin", caller
      end
      
      post(url_for('checkin'), body).checkin
    end
    
    def history(params = {})
      get(url_for('history', params)).checkins
    end
    
    def user(params = {})
      get(url_for('user', params)).user
    end
    
    private
    
    
    def raise_errors(response)
      case response.code.to_i
        when 400
          raise RateLimitExceeded, "(#{response.code}): #{response.message} - #{data['error'] if data}"
        when 401
          data = parse(response)
          raise Unauthorized, "(#{response.code}): #{response.message} - #{data['error'] if data}"
        when 403
          raise General, "(#{response.code}): #{response.message} - #{data['error'] if data}"
        when 404
          raise NotFound, "(#{response.code}): #{response.message}"
        when 500
          raise InternalError, "Foursquare had an internal error. Please let them know in the group. (#{response.code}): #{response.message}"
        when 502..503
          raise Unavailable, "(#{response.code}): #{response.message}"
      end
    end
  end
  
  
  class RateLimitExceeded < StandardError; end
  class Unauthorized      < StandardError; end
  class General           < StandardError; end
  class Unavailable       < StandardError; end
  class InternalError     < StandardError; end
  class NotFound          < StandardError; end
end