#!/usr/bin/env coffee

require 'colors'
fs = require 'fs'
moment = require 'moment'
minimist = require 'minimist'
args = minimist process.argv.slice 2

search = require './search'
output = require './output'
geo = require './geo'
settings = require './settings.json'
pokemonNames = require('./pokemon.json').pokemon

String.prototype.capitalize = () ->
  return @charAt(0).toUpperCase() + @slice 1

idToName = (id) ->
  return pokemonNames[id - 1].capitalize()

sortByDistance = (pokemons) ->
  return pokemons.sort (poke1, poke2) ->
    poke1Dist = geo.distanceFromMe poke1.latitude, poke1.longitude
    poke2Dist = geo.distanceFromMe poke2.latitude, poke2.longitude
    return poke1Dist - poke2Dist

sortByName = (pokemons) ->
  return pokemons.sort (poke1, poke2) ->
    return idToName(poke1.pokemonId).localeCompare idToName(poke2.pokemonId)

sortByID = (pokemons) ->
  return pokemons.sort (poke1, poke2) ->
    return parseInt(poke1.pokemonId) - parseInt(poke2.pokemonId)

if args.n
  sortFunction = sortByName
else if args.i
  sortFunction = sortByID
else
  sortFunction = sortByDistance
pokemonAlerted = []
main = () ->
  search settings.lat, settings.lng
  .then sortFunction
  .then output.printTable
  .then (pokemons) ->
    now = Date.now()
    for pokemon in pokemons
      if pokemon.pokemonId not in settings.blacklist
        name = idToName pokemon.pokemonId
        dist = geo.haversine settings.lat, settings.lng, pokemon.latitude, pokemon.longitude
        feet = Math.round dist * 3.2808
        timeLeft = moment((pokemon.expiration_time * 1000) - now).format('mm:ss')
        message = "#{name} is #{feet}ft away for #{timeLeft}!"
        if pokemon.uid not in pokemonAlerted
          output.notify message
          pokemonAlerted.push pokemon.uid
        output.log message.red.bold
        output.log "https://www.google.com/maps/dir/#{settings.lat},#{settings.lng}/#{pokemon.latitude},#{pokemon.longitude}".cyan.bold
  .catch (err) ->
    console.error err



settingsPromise = new Promise (resolve, reject) ->
  if not settings.lat? or not settings.lng?
    geo.find().then (location) ->
      settings.lat = location.lat
      settings.lng = location.lng
      fs.writeFileSync 'settings.json', JSON.stringify settings, null, 4
      resolve()
    .catch (err) ->
      console.error err
  else
    resolve()

settingsPromise.then () ->
  console.log 'Searching', "#{settings.lat}, #{settings.lng}"
  console.log 'If you wish to re-center, delete to lat and long keys from settings.json'
  console.log 'Blacklisted:'
  for blacklisted in settings.blacklist
    console.log "\t#{idToName blacklisted}"
  console.log 'Press Ctrl-C to exit.'
  main()
  setInterval main, settings.interval * 1000
