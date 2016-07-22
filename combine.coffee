fs = require 'fs'

pokemon = []
for num in [1..3]
  data = fs.readFileSync "pokemon#{num}.json"
  for poke in JSON.parse(data).pokemon
    pokemon.push poke
fs.writeFileSync 'pokemon.json', JSON.stringify { pokemon }, null, 4
