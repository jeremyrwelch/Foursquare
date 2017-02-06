== DEPRECATED
This gem is no longer useful, as it does not support the Foursquare API 2.0. 

<div style="margin: 25px;">
<a href="https://rapidapi.com/package/Foursquare/functions?utm_source=FoursquareAPIGitHub-RubySDK&utm_medium=button&utm_content=Vendor_GitHub" style="
    all: initial;
    background-color: #498FE1;
    border-width: 0;
    border-radius: 5px;
    padding: 10px 20px;
    color: white;
    font-family: 'Helvetica';
    font-size: 12pt;
    background-image: url(https://scdn.rapidapi.com/logo-small.png);
    background-size: 25px;
    background-repeat: no-repeat;
    background-position-y: center;
    background-position-x: 10px;
    padding-left: 44px;
    cursor: pointer;">
  Run now on <b>RapidAPI</b>
</a>
</div>

Please refer to https://github.com/mattmueller/foursquare2


--------------------


== foursquare

A simple Ruby Gem wrapper for the Foursquare API. With OAuth authentication.

== install
  
  gem install foursquare
    
== example
  
  require 'rubygems'
  require 'foursquare'
  
  oauth_key = 'your_key'
  oauth_secret = 'your_secret'
  
  oauth = Foursquare::OAuth.new(oauth_key, oauth_secret)
  
  request_token = oauth.request_token.token
  request_secret = oauth.request_token.secret
  
  # redirecting user to foursquare to authorize
  oauth.request_token.authorize_url
  
  # foursquare redirects back to your callback url, passing the verifier in the url params
  
  access_token, access_secret = oauth.authorize_from_request(request_token, request_secret, verifier)
  
  # save the user's access token and secret
  
  
  oauth = Foursquare::OAuth.new(oauth_key, oauth_secret)
  oauth.authorize_from_access(access_token, access_secret)
  foursquare = Foursquare::Base.new(oauth)
  
  foursquare.test
  
  foursquare.venues :geolat => geolat, :geolong => geolong, :l => 10, :q => 'pizza'
  foursquare.tips :geolat => geolat, :geolong => geolong, :l => 10
  foursquare.checkins :geolat => geolat, :geolong => geolong
  
  checkin = {
    :vid => vid,
    :shout => "this is what i'm up to",
    :venue => "Cohabitat",
    :private => 0,
    :twitter => 0,
    :geolat => geolat,
    :geolong => geolong
  }
  
  # these all do the same thing
  # the response is a hashie object built from the checkin json.  so you can do new_checkin.shout
  new_checkin = foursquare.checkin(checkin)
  new_checkin.class
  => Hashie::Mash
  new_checkin
  => {...checkin hashie...}
  new_checkin = foursquare.send('checkin=', checkin)
  new_checkin.class
  => Hash
  new_checkin
  => {'checkin' => {...}}
  new_checkin = foursquare.api(:checkin=, checkin)
  new_checkin.class
  => Hashie::Mash
  new_checkin
  => {:checkin => {...}}
  
  foursquare.history :l => 10
  foursquare.api(:history, :l => 10).checkins
  foursquare.user :uid => user_id :badges => 0
  foursquare.user # currently authenticated user
  foursquare.friends :uid => 99999
  foursquare.venue :vid => venue_id
  foursquare.addvenue :name => name, :address => address, :city => city, ...
  foursquare.venue_proposeedit :venue_id => venue_id, :name => name, :address => address, :city => ...
  foursquare.venue_flagclosed :vid => venue_id
  foursquare.addtip :vid => 12345, :tip => 'here is a tip'
  foursquare.tip_marktodo :tid => tip_id
  foursquare.tip_markdone :tid => tip_id
  foursquare.friend_requests
  foursquare.friend_approve :uid => friend_id
  foursquare.friend_deny :uid => friend_id
  foursquare.friend_sendrequest :uid => friend_id
  foursquare.findfriends_byname :q => search_string
  foursquare.findfriends_byphone :q => '555 123'
  foursquare.findfriends_bytwitter :q => twitter_name
  foursquare.settings_setping :uid => user_id, :self => global_ping_status
  
== license 

(the MIT license)

Copyright (c) 2009 Workperch Inc

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
