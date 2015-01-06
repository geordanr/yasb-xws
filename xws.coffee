cards = require('./xwing/coffeescripts/cards-common').basicCardData()
permalink = require './permalink'

fromXWSFaction =
    'rebels': 'Rebel Alliance'
    'empire': 'Galactic Empire'
    'scum': 'Scum and Villainy'

toXWSFaction =
    'Rebel Alliance': 'rebels'
    'Galactic Empire': 'empire'
    'Scum and Villainy': 'scum'

toXWSUpgrade =
    'Astromech': 'amd'
    'Elite': 'ept'
    'Modification': 'mod'
    'Salvaged Astromech': 'samd'

fromXWSUpgrade =
    'amd': 'Astromech'
    'astromechdroid': 'Astromech'
    'ept': 'Elite'
    'elitepilottalent': 'Elite'
    'mod': 'Modification'
    'samd': 'Salvaged Astromech'

exportObj = exports ? this

exportObj.serializedToXWS = (faction, serialized) ->
    xws =
        faction: toXWSFaction[faction]
        pilots: []
        vendor:
            yasb:
                builder: '(Yet Another) X-Wing Miniatures Squad Builder'
                builder_url: 'https://geordanr.github.io/xwing'
                link: 'https://geordanr.github.io/xwing'
        version: '0.2.0'

    for ship in permalink.serializedToShips faction, serialized
        continue unless ship?.pilot?
        try
            shipdata = cards.ships[ship.pilot.ship]
        catch e
            console.error "Unknown ship: #{e}"
            continue
        
        try
            pilot =
                name: ship.pilot.canonical_name ? ship.pilot.name.canonicalize()
                ship: shipdata.canonical_name ? shipdata.name.canonicalize()
        catch e
            console.error "Cannot set pilot and ship: #{e}"
            continue

        upgrade_obj = {}

        for upgrade in ship.upgrades
            try
                slot = toXWSUpgrade[upgrade.slot] ? upgrade.slot.canonicalize()
                (upgrade_obj[slot] ?= []).push(upgrade.canonical_name ? upgrade.name.canonicalize())
            catch e
                console.error "Cannot add upgrade: #{e}"
                continue

        for modification in ship.modifications
            try
                (upgrade_obj[toXWSUpgrade['Modification']] ?= []).push(modification.canonical_name ? modification.name.canonicalize())
            catch e
                console.error "Cannot add modification: #{e}"
                continue

        if ship.title?
            try
                (upgrade_obj[toXWSUpgrade['Title']] ?= []).push(ship.title.canonical_name ? ship.title.name.canonicalize())
            catch e
                console.error "Cannot add title: #{e}"
                continue

        if Object.keys(upgrade_obj).length > 0
            pilot.upgrades = upgrade_obj

        xws.pilots.push pilot

    xws
