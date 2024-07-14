require "http"
require "json"

puts "We can help you decide if you need an umbrella today."
puts "Please provide a location:"
location = gets.chomp

puts "Checking weather at #{location}"

gmaps_key = ENV.fetch("GMAPS_KEY")
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{gmaps_key}"

#pp gmaps_url

htmlcontent = HTTP.get(gmaps_url)
coordinates = JSON.parse(htmlcontent).fetch("results").at(0).fetch("geometry").fetch("location")
longitude = coordinates.fetch("lng")
latitude = coordinates.fetch("lat")

pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{latitude},#{longitude}"

htmlcontent2 = HTTP.get(pirate_weather_url)
# pp pirate_weather_url
temperature = JSON.parse(htmlcontent2).fetch("currently").fetch("temperature")

puts "It is currently #{temperature}°F."

hourly = JSON.parse(htmlcontent2).fetch("hourly").fetch("data")
twelve_hours = hourly[1..12]
any_precipitation = false
twelve_hours.each do |hash|
  prob_of_precip = hash.fetch("precipProbability").to_f
  if prob_of_precip > 0.10
    any_precipitation = true
    precip_time = Time.at(hash.fetch("time"))
    seconds_from_now = precip_time - Time.now
    hours_from_now = seconds_from_now / 60 / 60
    puts "In #{hours_from_now.round} hours, there is a #{(prob_of_precip * 100).round}% chance of precipitation."
  end
end

if any_precipitation == true
  puts "You might want to take an umbrella!"
else
  puts "You probably won't need an umbrella."
end
