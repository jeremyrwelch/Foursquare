require 'rubygems'
require 'httparty'

class Foursquare
  # Current Version of the Foursquare API: http://groups.google.com/group/foursquare-api/web/api-documentation
  
  include HTTParty
  base_uri 'api.foursquare.com'
  format :xml

  # auth user
  # TODO: add OAuth support (follow Twitter gem from jnunemaker http://github.com/jnunemaker/twitter)
  def initialize(user="",pass="", options={})
    self.class.basic_auth user, pass
    self.class.headers(options[:headers]) if options.has_key?(:headers)
  end

  # =========================
  # = No Auth Required Methods =
  # =========================
  # test for response from Foursquare
  def test 
      self.class.get("/v1/test") 
  end

  def venues(geolat, geolong, options={})
      options.merge!({:geolat=>geolat, :geolong=>geolong})
      self.class.get("/v1/venues", :query=>options)
  end

  def tips(geolat,geolong,options={})
      options.merge!({:geolat=>geolat, :geolong=>geolong})
      self.class.get("/v1/tips", :query=>options)
  end

  # =========================
  # = Auth Required Methods =
  # =========================
  def checkins(options={})
    self.class.get("/v1/checkins",:query=>options)
  end 

  def checkin(vid=nil,venue=nil,shout=nil,options={})
    unless vid || venue || shout
      raise ArgumentError, "A vid or venue or shout is required to checkin", caller
    end
    options.merge!({:vid=>vid, :venue=>venue, :shout=>shout})    
    self.class.post("/v1/checkin", :body => options)       
  end
  
  def history(options={})
    limit = options.delete(:limit) || 10
    uri = "/v1/history?l=#{limit}"
    sinceid = options.delete(:sinceid)
    uri << "&sinceid=#{sinceid}" unless sinceid.nil?
    self.class.get(uri)
  end
  
  def user_details(user_id,options={})
    unless user_id
      raise ArgumentError, "A user_id is required to get details about a user", caller
    end    
    self.class.get("/v1/user",:query=>options)
  end
  
  def friends
    self.class.get("/v1/friends")
  end
  
  def venue_details(venue_id)
    self.class.get("/v1/venue?vid=#{venue_id}")
  end

  # city_id has been removed from API
  def add_venue(name,address,cross_street,city,state,options={})
    unless name && address && cross_street && city && state
      raise ArgumentError, "A venue's name, address, cross_street, city, state are required to add_venue", caller
    end                            
    options.merge!({:name=>name, :address=>address, :cross_street=>cross_street, :city=>city, :state=>state})
    self.class.post("/v1/addvenue", :body => options)
  end

  # ===============
  # = TIP methods =
  # ===============
  def add_tip(venue_id,text,options={})
    unless venue_id && text
      raise ArgumentError, "venue_id and text are required to add_tip", caller
    end                      
    options.merge!({:vid=>venue_id, :text=>text})
    self.class.post("/v1/addtip", :body => options)
  end
  
  def mark_tip_as_todo(tid)
    unless tid 
      raise ArgumentError, "tip_id is required to mark tip as todo", caller
    end
    self.class.post("/v1/tip/marktodo", :body => {:tip=>tip})
  end 
     
  def mark_tip_as_done(tid)
    unless tid 
      raise ArgumentError, "tid is required to mark tip as done", caller
    end
    self.class.post("/v1/tip/markdone", :body => {:tip=>tip})
  end

  # ==================
  # = FRIEND Methods =
  # ==================
  def friend_requests
     self.class.get("/v1/friend/requests")
  end

  def friend_approve(uid)
    unless uid 
      raise ArgumentError, "uid is required to approve friend request", caller
    end
    self.class.post("/v1/friend/requests", :body => {:uid=>uid})
  end
     
  def friend_deny(uid)
    unless uid 
      raise ArgumentError, "uid is required to deny friend request", caller
    end
    self.class.post("/v1/friend/deny", :body => {:uid=>uid})
  end
     
  def request_friend(uid)
    unless uid 
      raise ArgumentError, "uid is required to request friend", caller
    end
    self.class.post("/v1/friend/sendrequest", :body => {:uid=>uid})
  end
  
  # ================
  # = FIND Methods =
  # ================
  def find_friends_by_name(q)
    self.class.get("/v1/findfriends/byname", :query=>{:q=>q})
  end 

  def find_friends_by_phone(q)
    self.class.get("/v1/findfriends/byphone", :query=>{:q=>q})
  end 

  def find_friends_by_twitter(q)
    self.class.get("/v1/findfriends/bytwitter", :query=>{:q=>q})
  end 

  # ===============
  # = SET methods =
  # ===============
  def set_pings(user_id=nil,ping=nil)
    uid = user_id || "self"
    self.class.post("/v1/settings/setpings?#{uid}=#{ping}")
  end
  
  # From Foursquare API
  # 20100108 - naveen - the concept of cities (cityid and all city-related methods) has now been removed
  # Deprecated
  def cities
      self.class.get("/v1/cities")
  end
  # Deprecated
    def check_city(geolat, geolong) 
      $stderr.puts "`check_city` Deprecated: The idea of \"cityid\" is now deprecated from the API"
      self.class.get("/v1/checkcity?geolat=#{geolat}&geolong=#{geolong}")
    end
  # Deprecated
    def switch_city(city_id)
      $stderr.puts "`switch_city` Deprecated: The idea of \"cityid\" is now deprecated from the API"
      self.class.post("/v1/switchcity", :body => {:cityid => city_id})
    end
  # Method changed to call checkins to match API
    def friend_checkins(options={})
        $stderr.puts "`friend_checkins` now calls `checkins` to match the foursquare api method call"
        $stderr.puts "http://groups.google.com/group/foursquare-api/web/api-documentation"
        checkins(options)
    end
  
end
