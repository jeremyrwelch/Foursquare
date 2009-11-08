require 'rubygems'
require 'httparty'

class Foursquare
  
  include HTTParty
  base_uri 'api.foursquare.com'
  format :xml
  

# auth user    
  def initialize(user="",pass="")
    self.class.basic_auth user, pass
  end
  
  
# test for response from Foursquare
  def test 
    self.class.get("/v1/test") 
  end

# no auth required 
  def cities
    self.class.get("/v1/cities")
  end
  
  def venues(geolat,geolong,radius="",limit="",query="")
    self.class.get("/v1/venues?geolat=#{geolat}&geolong=#{geolong}&r=#{radius}&l=#{limit}&q=#{query}")
  end
  
  def tips(geolat,geolong,limit="")
    self.class.get("/v1/tips?geolat=#{geolat}&geolong=#{geolong}&l=#{limit}")
  end


# auth required
  def check_city(geolat, geolong) 
    self.class.get("/v1/checkcity?geolat=#{geolat}&geolong=#{geolong}")
  end

  def switch_city(city_id)
    self.class.post("/v1/switchcity", :body => {:cityid => city_id})
  end

  def friend_checkins
    self.class.get("/v1/checkins")
  end
  
  def checkin(vid,venue,shout,private_checkin,tweetThis,geolat,geolong)
    self.class.get("/v1/checkin?vid=#{vid}&venue=#{venue}&shout=#{shout}&private=#{private_checkin}&twitter=#{tweetThis}&geolat=#{geolat}&geolong=#{geolong}")
  end
  
  def history(limit="10")
    self.class.get("/v1/history?l=#{limit}")
  end
  
  def user_details(user_id,badges="0",mayor="0")
    self.class.get("/v1/user?uid=#{user_id}&badges=#{badges}&mayor=#{mayor}")
  end
  
  def friends
    self.class.get("/v1/friends")
  end
  
  def venue_details(venue_id)
    self.class.get("/v1/venue?vid=#{venue_id}")
  end
  
  def add_venue(city_id,name,address,cross_street,city,state,zip="",phone="")
    self.class.post("/v1/addvenue", :body => {:name => name, :address => address, :crossstreet => cross_street, :city => city, :state => state, :zip => zip, :cityid => city_id, :phone => phone})
  end
  
  def add_tip(venue_id,text,type)
    self.class.post("/v1/addtip", :body => {:vid => venue_id, :text => text, :type => type})
  end
  
end
