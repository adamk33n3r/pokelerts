#!/usr/bin/env coffee

cloudscraper = require 'cloudscraper'
readline = require 'readline'

output = require './output'
settings = require './settings.json'
pokemonNames = require('./pokemon.json').pokemon

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

module.exports = search
