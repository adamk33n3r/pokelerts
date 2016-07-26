readline = require 'readline'
cloudscraper = require 'cloudscraper'

settings = require './settings.json'

##############
# Math stuff #
##############

Number.prototype.toDegrees = () ->
  return this * 180 / Math.PI
Number.prototype.toRadians = () ->
  return this * Math.PI / 180

module.exports.haversine = (lat1, long1, lat2, long2) ->
  lat1r = lat1.toRadians()
  lat2r = lat2.toRadians()
  deltaLatr = (lat2 - lat1).toRadians()
  deltaLongr = (long2 - long1).toRadians()
  a = Math.sin(deltaLatr / 2) * Math.sin(deltaLatr / 2) +
      Math.cos(lat1r) * Math.cos(lat2r) *
      Math.sin(deltaLongr / 2) * Math.sin(deltaLongr / 2)
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  d = 6371e3 * c
  return d

module.exports.bearing = (lat1, long1, lat2, long2) ->
  y = Math.sin((long2 - long1).toRadians()) * Math.cos(lat2.toRadians())
  x = Math.cos(lat1.toRadians()) * Math.sin(lat2.toRadians()) -
      Math.sin(lat1.toRadians()) * Math.cos(lat2.toRadians()) * Math.cos((long2 - long1).toRadians())
  brng = (Math.atan2(y, x).toDegrees() + 360) % 360
  return brng

directions = [ 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N' ]
module.exports.bearingToDirection = (brng) ->
  return directions[Math.round((brng % 360) / 45)]

##############
# Other stuff #
##############
module.exports.distanceFromMe = (lat, lng) ->
  return module.exports.haversine lat, lng, settings.lat, settings.lng

cloudscraper.getJSONAsync = (url) ->
  return new Promise (resolve, reject) ->
    cloudscraper.request
      method: 'GET'
      url: url
      headers:
        'accept': 'application/json'
        'referer': 'http://myfarms.com/'
    , (err, response, body) ->
      return reject(err) if err
      if response.headers['content-type'].startsWith 'text/html'
        return reject('site down')
      return resolve(JSON.parse(body))
findLocation = (location) ->
  return cloudscraper.getJSONAsync "https://maps.googleapis.com/maps/api/geocode/json?address=#{encodeURIComponent(location)}&key=AIzaSyBSQ_1g4yhqoCyRM8qgmK_y1RcZ-ZbVtHI"
    .then (response) ->
      if response.status is 'OK'
        return response.results[0].geometry.location
      return Promise.reject response

module.exports.find = () ->
  return new Promise (resolve, reject) ->
    rl = readline.createInterface
      input: process.stdin
      output: process.stdout
    rl.question 'Where are you?\nLocation: ', (loc) ->
      rl.close()
      resolve findLocation(loc)
