require 'rubygems'
require 'foursquare'


fq = Foursquare.new('','') #Add Your Foursquare Login (email or phone number) and Pass
puts fq.cities.inspect
puts fq.test