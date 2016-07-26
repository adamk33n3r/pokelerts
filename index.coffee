#!/usr/bin/env coffee

require 'colors'
fs = require 'fs'

search = require './search'
output = require './output'
geo = require './geo'
settings = require './settings.json'
pokemonNames = require('./pokemon.json').pokemon

pokemonAlerted = []
main = () ->
  search settings.lat, settings.lng
  .then (pokemons) ->
    output.log() if pokemons.length > 0
    return pokemons
  .then output.printTable
  .then (pokemons) ->
    now = Date.now()
    for pokemon in pokemons
      if pokemon.pokemonId in settings.watchlist
        name = pokemonNames[pokemon.pokemonId - 1]
        name = name.charAt(0).toUpperCase() + name.slice 1
        dist = geo.haversine settings.lat, settings.lng, pokemon.latitude, pokemon.longitude
        feet = Math.round dist * 3.2808
        timeLeft = moment((pokemon.expiration_time * 1000) - now).format('mm:ss')
        message = "#{name} is #{feet}ft away for #{timeLeft}!"
        if pokemon.uid not in pokemonAlerted
          output.notify message
          pokemonAlerted.push pokemon.uid
        message += " https://www.google.com/maps/dir/#{settings.lat},#{settings.lng}/#{pokemon.latitude},#{pokemon.longitude}"
        output.log message.red.bold
  .catch (err) ->
    output.error err



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
  console.log 'Press Ctrl-C to exit.'
  main()
  setInterval main, 30000
