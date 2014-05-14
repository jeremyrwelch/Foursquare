require 'rubygems'
require 'httparty'
require 'hashie'
require 'oauth'

Hash.send :include, Hashie::HashExtensions



module Foursquare
  class OAuth
    def initialize(ctoken, csecret, options={})
      @consumer_token, @consumer_secret , @options = ctoken, csecret ,options
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
      }.merge(@options))
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
    
    attr_accessor :oauth
    
    def initialize(oauth)
      @oauth = oauth
    end
    
    #
    # Foursquare API: http://groups.google.com/group/foursquare-api/web/api-documentation
    #
    # .test                                          # api test method
    #  => {'response': 'ok'}
    # .checkin = {:shout => 'At home. Writing code'} # post new check in
    #  => {...checkin hash...}
    # .history                                       # authenticated user's checkin history
    # => [{...checkin hashie...}, {...another checkin hashie...}]
    # .send('venue.flagclosed=', {:vid => 12345})     # flag venue 12345 as closed
    # => {'response': 'ok'}
    # .venue_flagclosed = {:vid => 12345}
    # => {'response': 'ok'}
    #
    # Assignment methods(POSTs) always return a hash. Annoyingly Ruby always returns what's on
    # the right side of the assignment operator. So there are some wrapper methods below
    # for POSTs that make sure it gets turned into a hashie
    #
    def method_missing(method_symbol, params = {})
      method_name = method_symbol.to_s.split(/\.|_/).join('/')
      
      if (method_name[-1,1]) == '='
        method = method_name[0..-2]
        result = post(api_url(method), params)
        params.replace(result[method] || result)
      else
        result = get(api_url(method_name, params))
        result[method_name] || result
      end
    end
    
    def api(method_symbol, params = {})
      Hashie::Mash.new(method_missing(method_symbol, params))
    end
    
    def api_url(method_name, options = nil)
      params = options.is_a?(Hash) ? to_query_params(options) : options
      params = nil if params and params.blank?
      url = BASE_URL + '/' + method_name.split('.').join('/')
      url += ".#{FORMAT}"
      url += "?#{params}" if params
      url = URI.escape(url)
      url
    end
    
    def parse_response(response)
      raise_errors(response)
      Crack::JSON.parse(response.body)
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
    
    # API method wrappers
    
    def checkin(params = {})
      api(:checkin=, params).checkin
    end
    
    def history(params = {})
      api(:history, params).checkins
    end
    
    def addvenue(params = {})
      api(:addvenue=, params).venue
    end
    
    def venue_proposeedit(params = {})
      api(:venue_proposeedit=, params)
    end
    
    def venue_flagclosed(params = {})
      api(:venue_flagclosed=, params)
    end
    
    def addtip(params = {})
      api(:addtip=, params).tip
    end
    
    def tip_marktodo(params = {})
      api(:tip_marktodo=, params).tip
    end
    
    def tip_markdone(params = {})
      api(:tip_markdone=, params).tip
    end
    
    def friend_requests
      api(:friend_requests).requests
    end
    
    def friend_approve(params = {})
      api(:friend_approve=, params).user
    end
    
    def friend_deny(params = {})
      api(:friend_deny=, params).user
    end

    def friend_sendrequest(params = {})
      api(:friend_sendrequest=, params).user
    end
    
    def findfriends_byname(params = {})
      api(:findfriends_byname, params).users
    end
    
    def findfriends_byphone(params = {})
      api(:findfriends_byphone, params).users
    end
    
    def findfriends_bytwitter(params = {})
      api(:findfriends_bytwitter, params).users
    end
    
    def settings_setpings(params = {})
      api(:settings_setpings=, params).settings
    end
    
    private
    
    
    def raise_errors(response)
      message = "(#{response.code}): #{response.message} - #{response.inspect} - #{response.body}"
      
      case response.code.to_i
        when 400
          raise BadRequest, message
        when 401
          raise Unauthorized, message
        when 403
          raise General, message
        when 404
          raise NotFound, message
        when 500
          raise InternalError, "Foursquare had an internal error. Please let them know in the group.\n#{message}"
        when 502..503
          raise Unavailable, message
      end
    end
  end
  
  
  class BadRequest < StandardError; end
  class Unauthorized      < StandardError; end
  class General           < StandardError; end
  class Unavailable       < StandardError; end
  class InternalError     < StandardError; end
  class NotFound          < StandardError; end
end
