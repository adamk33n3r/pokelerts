fs = require 'fs'
request = require 'request-promise-native'

Promise.all(for num in [1..50]
    promise = request.get
        url: "http://pokeapi.co/api/v2/pokemon/#{num}/"
        json: true
    .then (result) ->
        return result.name
).then (pokemon) ->
    fs.writeFileSync 'pokemon1.json', JSON.stringify pokemon: pokemon, null, 4
.catch (err) ->
    console.error err
