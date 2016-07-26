#!/usr/bin/env coffee

cloudscraper = require 'cloudscraper'
minimist = require 'minimist'
readline = require 'readline'

output = require './output'
settings = require './settings.json'
pokemonNames = require('./pokemon.json').pokemon

args = minimist process.argv.slice 2

cloudscraper.getJSONAsync = (url) ->
  return new Promise (resolve, reject) ->
    cloudscraper.request
      method: 'GET'
      url: url
      headers:
        'Accept': 'application/json'
    , (err, response, body) ->
      return reject(err) if err
      if response.headers['content-type'].startsWith 'text/html'
        return reject('site down')
      return resolve(JSON.parse(body))

search = (lat, long) ->
  cloudscraper.getJSONAsync "https://pokevision.com/map/data/#{lat}/#{long}"
  .then (response) ->
    if response.status is 'success'
      return response.pokemon
    return Promise.reject response
  .then (pokemons) ->
    if pokemons.length is 0
      output.log 'No pokemon nearby'
      return pokemons
    pokemons = pokemons.filter (pokemon) ->
      return pokemon.pokemonId not in settings.blacklist
    if pokemons.length is 0
      output.log 'All pokemon filtered out'
      return pokemons
    # sort by distance
    pokemons = pokemons.sort (poke1, poke2) ->
      return poke1
    if args.a
      pokemons = pokemons.sort (poke1, poke2) ->
        return pokemonNames[parseInt(poke1.pokemonId) - 1].localeCompare pokemonNames[parseInt(poke2.pokemonId) - 1]
    else if args.n
      pokemons = pokemons.sort (poke1, poke2) ->
        return parseInt(poke1.pokemonId) - parseInt(poke2.pokemonId)
    else
      pokemons = pokemons.sort (poke1, poke2) ->
        return pokemonNames[parseInt(poke1.pokemonId) - 1].localeCompare pokemonNames[parseInt(poke2.pokemonId) - 1]
    return pokemons

module.exports = search
