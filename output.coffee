require 'colors'

notifier = require 'node-notifier'
moment = require 'moment'
path = require 'path'

Table = require 'cli-table'

geo = require './geo'
settings = require './settings.json'
pokemonNames = require('./pokemon.json').pokemon

module.exports.printTable = (pokemons) ->
  if pokemons.length > 0
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
    for pokemon in pokemons
      timeLeft = pokemon.expiration_time - now
      date = new Date timeLeft * 1000
      seconds = date.getUTCSeconds()
      seconds = if seconds < 10 then "0#{seconds}" else seconds
      time = "#{date.getUTCMinutes()}:#{seconds}"
      location = "#{pokemon.latitude},#{pokemon.longitude}"
      distance = geo.haversine settings.lat, settings.lng, pokemon.latitude, pokemon.longitude
      brng = geo.bearing settings.lat, settings.lng, pokemon.latitude, pokemon.longitude
      direction = geo.bearingToDirection brng
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
  return pokemons

module.exports.notify = (message) ->
  notifier.notify
    title: 'Pokelerts'
    message: message
    icon: path.join __dirname, 'logo-mini-light.png'
    sound: true
    wait: true
    open: "https://pokevision.com/#/@#{settings.lat},#{settings.lng}"

module.exports.log = (message = '') ->
  console.log "[#{moment().format 'MM/DD/YYYY HH:mm'}] ".green, message

