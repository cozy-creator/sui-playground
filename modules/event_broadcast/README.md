sui client call --package 0xa4ddc86e4ff1b21d9974a14de9724fb1c1c6b706 --module event_broadcast --function broadcast --args "Elden Ring[a] is a 2022 action role-playing game developed by FromSoftware and published by Bandai Namco Entertainment. It was directed by Hidetaka Miyazaki with worldbuilding provided by fantasy writer George R. R. Martin and was released for PlayStation 4, PlayStation 5, Windows, Xbox One, and Xbox Series X/S on February 25. In the game, players control a customizable player character on a journey to repair the titular Elden Ring, and become the new Elden Lord. The game is presented through a third-person perspective, with players freely roaming its interactive open world, featuring locations such as dungeons, catacombs, and caves. Gameplay elements include combat using several types of weapons and magic spells, horseback riding, and crafting. FromSoftware wanted to create an open-world game with gameplay similar to Dark Souls, intending Elden Ring to act as an evolution of the first game in the series. Miyazaki admired Martin's work and hoped his contributions would produce a more accessible narrative than FromSoftware's previous games. Elden Ring received widespread critical acclaim for its open-world, gameplay systems, and setting, with criticism going towards its technical performance upon release. The game won several awards, including multiple Game of the Year honors, and had sold more than 17.5 million copies by October 2022. Elden Ring is an action role-playing game played in a third person perspective, with gameplay focusing on combat and exploration. It features elements similar to those found in other games developed by FromSoftware, such as the Dark Souls series, Bloodborne, and Sekiro: Shadows Die Twice. Set in an open world, players are allowed to freely explore the Lands Between and its six main areas; these locations range from Limgrave, an area featuring grassy plains and ancient ruins, to Caelid, a wasteland home to undead monsters.[1] Open world areas are explorable using the character's mount, Torrent, as the primary mode of transportation, along with the ability to fast travel outside of combat. Throughout the game, players encounter non-player characters (NPCs) and enemies, including the demigods who rule each main area and serve as the game's main bosses.[2][3] Aside from open world areas, Elden Ring also features hidden dungeons, such as catacombs, tunnels, and caves where players can fight bosses and gather helpful items.[4] The game contains crafting mechanics, which require materials in order to create items. To craft a certain item, the player must have the item's crafting recipe. Recipes can be found inside collectables called Cookbooks, which are scattered throughout the world. Materials can be collected by defeating enemies, exploring the game's world, or by trading with merchant NPCs. Crafted items range from poison darts and exploding pots, to consumables that temporarily increase the player's strength in combat.[16][17] Similar to the Dark Souls games, the player can summon friendly NPCs called spirits to fight enemies.[18] Each type of summonable spirit requires its equivalent Spirit Ash for summoning; different types of Spirit Ashes can be discovered as the player explores the game world. Spirits can only be summoned near structures called Rebirth Monuments, which are primarily found in large areas and inside boss fight arenas.[19]" --gas-budget 3000

sui client call --package 0xa4ddc86e4ff1b21d9974a14de9724fb1c1c6b706 --module event_broadcast --function store --args b"Elden Ring[a] is a 2022 action role-playing game developed by FromSoftware and published by Bandai Namco Entertainment. It was directed by Hidetaka Miyazaki with worldbuilding provided by fantasy writer George R. R. Martin and was released for PlayStation 4, PlayStation 5, Windows, Xbox One, and Xbox Series X/S on February 25. In the game, players control a customizable player character on a journey to repair the titular Elden Ring, and become the new Elden Lord. The game is presented through a third-person perspective, with players freely roaming its interactive open world, featuring locations such as dungeons, catacombs, and caves. Gameplay elements include combat using several types of weapons and magic spells, horseback riding, and crafting. FromSoftware wanted to create an open-world game with gameplay similar to Dark Souls, intending Elden Ring to act as an evolution of the first game in the series. Miyazaki admired Martin's work and hoped his contributions would produce a more accessible narrative than FromSoftware's previous games. Elden Ring received widespread critical acclaim for its open-world, gameplay systems, and setting, with criticism going towards its technical performance upon release. The game won several awards, including multiple Game of the Year honors, and had sold more than 17.5 million copies by October 2022. Elden Ring is an action role-playing game played in a third person perspective, with gameplay focusing on combat and exploration. It features elements similar to those found in other games developed by FromSoftware, such as the Dark Souls series, Bloodborne, and Sekiro: Shadows Die Twice. Set in an open world, players are allowed to freely explore the Lands Between and its six main areas; these locations range from Limgrave, an area featuring grassy plains and ancient ruins, to Caelid, a wasteland home to undead monsters.[1] Open world areas are explorable using the character's mount, Torrent, as the primary mode of transportation, along with the ability to fast travel outside of combat. Throughout the game, players encounter non-player characters (NPCs) and enemies, including the demigods who rule each main area and serve as the game's main bosses.[2][3] Aside from open world areas, Elden Ring also features hidden dungeons, such as catacombs, tunnels, and caves where players can fight bosses and gather helpful items.[4] The game contains crafting mechanics, which require materials in order to create items. To craft a certain item, the player must have the item's crafting recipe. Recipes can be found inside collectables called Cookbooks, which are scattered throughout the world. Materials can be collected by defeating enemies, exploring the game's world, or by trading with merchant NPCs. Crafted items range from poison darts and exploding pots, to consumables that temporarily increase the player's strength in combat.[16][17] Similar to the Dark Souls games, the player can summon friendly NPCs called spirits to fight enemies.[18] Each type of summonable spirit requires its equivalent Spirit Ash for summoning; different types of Spirit Ashes can be discovered as the player explores the game world. Spirits can only be summoned near structures called Rebirth Monuments, which are primarily found in large areas and inside boss fight arenas.[19]" --gas-budget 3000

module: 0xa4ddc86e4ff1b21d9974a14de9724fb1c1c6b706::event_broadcast

### Step 1: Set the txBytes

`export SUI_RPC_HOST='https://fullnode.devnet.sui.io:443'`

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"method": "sui_moveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xa4ddc86e4ff1b21d9974a14de9724fb1c1c6b706",
"event_broadcast",
"broadcast",
[],
[],
"0xc5bf42f9331c28add838e5383c85392896fdebc0",
2000
],
"id": 1
}' | json_pp

txBytes: VHJhbnNhY3Rpb25EYXRhOjoAAv9oqTeGZR6wowJd8mAaQ000NgZzAQAAAAAAAAAgB157wIkZLg0WPglQvLiOYuKE/l2UIWZnP3Plvcrz2V8HZHJ5X3J1bgdjYWxsX21lAACB3J8trf3SioSBd6/Ys4tyh/dXPsW/QvkzHCit2DjlODyFOSiW/evAAQAAAAAAAAAgoaEAcIdLE5V8ERe/ypSCDupmKUbVx/v6b95rp2wGJpYBAAAAAAAAAOgDAAAAAAAA

### Step 2: Sign the txBytes

sui keytool sign --data VHJhbnNhY3Rpb25EYXRhOjoAAv9oqTeGZR6wowJd8mAaQ000NgZzAQAAAAAAAAAgB157wIkZLg0WPglQvLiOYuKE/l2UIWZnP3Plvcrz2V8HZHJ5X3J1bgdjYWxsX21lAACB3J8trf3SioSBd6/Ys4tyh/dXPsW/QvkzHCit2DjlODyFOSiW/evAAQAAAAAAAAAgoaEAcIdLE5V8ERe/ypSCDupmKUbVx/v6b95rp2wGJpYBAAAAAAAAAOgDAAAAAAAA --address 0x81dc9f2dadfdd28a848177afd8b38b7287f7573e

signature: 0k4y8yDjEobvTVgnkImqOqrcJGaSAh1s562WhB/Oi3J0/TfwSi8vJWpkbuDll/Srn1CQnXAyU3dInEmSqvctBA==

### Step 3: Submit the transaction

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_dryRunTransaction",
"params": [
"VHJhbnNhY3Rpb25EYXRhOjoAAv9oqTeGZR6wowJd8mAaQ000NgZzAQAAAAAAAAAgB157wIkZLg0WPglQvLiOYuKE/l2UIWZnP3Plvcrz2V8HZHJ5X3J1bgdjYWxsX21lAACB3J8trf3SioSBd6/Ys4tyh/dXPsW/QvkzHCit2DjlODyFOSiW/evAAQAAAAAAAAAgoaEAcIdLE5V8ERe/ypSCDupmKUbVx/v6b95rp2wGJpYBAAAAAAAAAOgDAAAAAAAA"
]
}' | json_pp

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_executeTransaction",
"params": [
"VHJhbnNhY3Rpb25EYXRhOjoAAv9oqTeGZR6wowJd8mAaQ000NgZzAQAAAAAAAAAgB157wIkZLg0WPglQvLiOYuKE/l2UIWZnP3Plvcrz2V8HZHJ5X3J1bgdjYWxsX21lAACB3J8trf3SioSBd6/Ys4tyh/dXPsW/QvkzHCit2DjlODyFOSiW/evAAQAAAAAAAAAgoaEAcIdLE5V8ERe/ypSCDupmKUbVx/v6b95rp2wGJpYBAAAAAAAAAOgDAAAAAAAA",
"ED25519",
"0k4y8yDjEobvTVgnkImqOqrcJGaSAh1s562WhB/Oi3J0/TfwSi8vJWpkbuDll/Srn1CQnXAyU3dInEmSqvctBA==",
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"WaitForLocalExecution"
]
}' | json_pp
