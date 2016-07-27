# Pokélerts
Get notified when pokemon you want to catch are nearby.

## Install
```
npm install pokelerts
```

## Usage
For base with no config
```
$ pokelerts
```

You can add parameters for sorting functions. Default is by
distance but you can also sort by ID or by name.
```
$ pokelerts [-i|-n]
```

As well as a parameter to turn off the notifications.
```
$ pokelerts -q
```

## Config
There are settings in `settings.json`.
```
{
    "api": "",
    "interval": 60,
    "blacklist": [
        10, // Caterpie
        13, // Weedle
        16, // Pidgey
        19, // Rattata
        21, // Spearow
        22  // Fearow
    ]
}
```
**api**: Google Geocode API key for searching by address (not needed)

**interval**: How many seconds to wait between checks. Keep this at a minute or

above.
**blacklist**: You can put IDs of pokemon that you want to filter out of the
results in here.
The first time you start the program you will be asked where you are. This will
set the program to search around that location. This location will be saved in
the `settings.json` file. You can change it manually or delete it to run the
prompt again if you wish to search elsewhere.

# TODO
- Add data to pokemon to use elsewhere like distance, etc.

Uses the &copy; PokeVision.com API.
