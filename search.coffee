#!/usr/bin/env coffee

cloudscraper = require 'cloudscraper'
minimist = require 'minimist'
Table = require 'cli-table'
args = minimist process.argv.slice 2

Number.prototype.toDegrees = () ->
  return this * 180 / Math.PI
Number.prototype.toRadians = () ->
  return this * Math.PI / 180

haversine = (lat1, long1, lat2, long2) ->
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

bearing = (lat1, long1, lat2, long2) ->
  y = Math.sin((long2 - long1).toRadians()) * Math.cos(lat2.toRadians())
  x = Math.cos(lat1.toRadians()) * Math.sin(lat2.toRadians()) -
      Math.sin(lat1.toRadians()) * Math.cos(lat2.toRadians()) * Math.cos((long2 - long1).toRadians())
  brng = (Math.atan2(y, x).toDegrees() + 360) % 360
  return brng

directions = [ 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N' ]
bearingToDirection = (brng) ->
  return directions[Math.round((brng % 360) / 45)]

pokemonNames = require('./pokemon.json').pokemon
lat = 40.437000399999995
long = -84.9727687

cloudscraper.getJSONAsync = (url) ->
  return new Promise (resolve, reject) ->
    cloudscraper.get url, (err, response, body) ->
      return reject(err) if err
      return resolve(JSON.parse(body))

cloudscraper.getJSONAsync "https://pokevision.com/map/data/#{lat}/#{long}"
.then (response) ->
  if response.status is 'success'
    return response.pokemon
  return Promise.reject response
.then (pokemons) ->
  now = Date.now() / 1000
  table = new Table
    style:
      head: ['blue']
    head: [
      '#'
      'Pokemon'
      'Time Remaining'
      'Lat/Long'
      'Distance (m/f)'
      'Bearing'
      'Direction'
    ]
  if pokemons.length is 0
    console.log 'No pokemon nearby'
  if args.a
    pokemons = pokemons.sort (poke1, poke2) ->
      return pokemonNames[parseInt(poke1.pokemonId) - 1].localeCompare pokemonNames[parseInt(poke2.pokemonId) - 1]
  else if args.n
    pokemons = pokemons.sort (poke1, poke2) ->
      return parseInt(poke1.pokemonId) - parseInt(poke2.pokemonId)
  else
    pokemons = pokemons.sort (poke1, poke2) ->
      return pokemonNames[parseInt(poke1.pokemonId) - 1].localeCompare pokemonNames[parseInt(poke2.pokemonId) - 1]
  for pokemon in pokemons
    timeLeft = pokemon.expiration_time - now
    date = new Date timeLeft * 1000
    seconds = date.getUTCSeconds()
    seconds = if seconds < 10 then "0#{seconds}" else seconds
    time = "#{date.getUTCMinutes()}:#{seconds}"
    location = "#{pokemon.latitude},#{pokemon.longitude}"
    distance = haversine lat, long, pokemon.latitude, pokemon.longitude
    brng = bearing lat, long, pokemon.latitude, pokemon.longitude
    direction = bearingToDirection brng
    table.push [
      pokemon.pokemonId
      pokemonNames[parseInt(pokemon.pokemonId) - 1]
      time
      location
      "#{Math.round(distance)} / #{Math.round(distance * 3.2808)}"
      Math.round(brng)
      direction
    ]
  console.log table.toString()
.catch (err) ->
  console.error err
