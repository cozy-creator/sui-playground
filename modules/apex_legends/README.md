Note that a sample dump of a player's data is about 40 KBs. That would cost about 5,200 gas on Sui to post.

https://api.mozambiquehe.re/bridge?auth=0d9fdc2bf0b841ecc8dc62ed34ffb83f&player=SUBLIME5546&platform=X1

### Offline game-save data:

- The user creates an account in-game, and generates a keypair, which is stored securely locally.
- (To assist later recovery of this keypair, the keypair could be uploaded to a cloud service, or emailed to the user, giving them a remote backup of the keypair.)
- The game proceeds as normal. When the user saves, the game produces a save-file (binary or base64 encoded JSON perhaps), and then sends that data to the Sui blockchain. This is an owned-object, owned by the player (with their keypair).
- When the player returns to the game later, the game queries an indexing service for save-file types owned by its locally-stored keypair. It receives a list of them (or just one, if there is only one save file); perhaps including the entire file, or perhaps just some metadata about the file, like when it was last saved. The player selects one of the save-files; the game retrieves the full size file from indexer, parses it, and loads the game.
- The next time the player saves, the game will post again to the Sui blockchain, this time overwriting the previous data rather than creating a new file.
- If the game does not want save-files to be publicly readable, then it can encrypt the save-file using its public key, and store that instead of the unencrypted save-file. The game can then reverse the process when loading game-data by decrypting the retrieved data.

The advantage of this is that the game-developer does not have to maintain any sort of game-save server / cloud backup, and the player always has a highly-available save-file. Additionally, the player cannot simply edit or hack their save file; they could however try to build a modified version of the game's binary, or perhaps try to modify the game's memory while it's running, and that way produce hacked game-states, but these are both very difficult tasks.

A questionable advantage (if save files are not encrypted) is that all other players will now have read access to every other player's save-file. So they could load someone else's save file, if the game allows them to. (The obvious way to disallow this would be to hash the save-file with the user's private-key; so unless the remote user shared their private key as well, the game would prevent someone else's game from loading.)

The downside is obviously the cost and latency; both will be higher on the Sui blockchain as compared to Amazon S3.

### Saving Online game-data:

- Each game-server has a keypair, and generates a Sui account
- After each match, it posts the results of the match to the Sui blockchain, by creating a new frozen (immutable) object like MatchResults. The data is most likely serialized JSON.
- There is a shared object for each player's player-data (stats and such), which is gated to only being editable by a few keys (the keys controlled by the servers). The server figures out what data it needs to update (player 1, 2, 3), does a query to an indexer, finds each player's player-data object-id, submits another query to the indexer to get the data for each of those players, then parses the data, updates it, and posts the newly written data for each player to the Sui blockchain.
- The problem with this of course is data-concurrency; multiple servers might be trying to write to the same player save-data, and their transactions could easily overwrite each other. Furthermore, because this is a shared object, it will be much slower than an owned-object.
- For our indexer, we then have a data-contract, which describes how the data is supposed to be parsed. We then grab the Sui data, parse it, and make it available to everyone as an API.

### Overall thoughts:

This is a terrible idea; I'm guessing right now for Apex Legends it works like:

game-server -> (auth) results to back-end server, processes the results -> (auth) writes to SQL database in a series of requests

user joins game -> request to back-end server for data -> (auth) request to SQL database -> response to back-end -> response to user

this is pretty standard and efficient. Instead we are going to replace it with:

game-server -> (auth) results to back-end server, processes the results -> (auth) writes to Sui blockchain (big concurrency issues) -> indexer service notices changes, indexes resulting data

user joins game -> request to indexer server for data -> response to user

essentially we have taken the SQL database approach, and inserted a blockchain into the middle of it. But the blockchain adds no real value; we can simply remove the blockchain and go straight to the indexer.

### The Problem:

The problem is that we have to have our own database-concurrency control; if we serialize data, and post it to the blockchain, then we might run into concurrency issues if multiple servers are trying to write to the same file at the same time. For structs, this read <-> write behavior is handled by the blockchain itself. However doing this requires:

1. data must be stored natively within the blockchain, not serialized JSON
2. the logic for updating the data must also be on the blockchain

For example, suppose Apex Legends has the following field:

struct PlayerData {
total_kills: u64
}

when a server wants to update this value, it should do a transaction like:

public fun increment_kills(player_data: &mut PlayerData, amount: u64) {
player_data.total_kills = player_data.total_kills + amount;
}

NOT

public fun set_kills(player_data: &mut PlayerData, new_amount: u64) {
player_data.total_kills = new_amount;
}

In the first case, if there are two servers, which are looking to report new kills earned, their transactions will stack on top of each other, arriving at the correct number. On the other hand, in the bottom case the second transaction will overwrite the first one; perhaps the second transaction was like "oh I checked the chain, this person has 200 kills, and they just earned 3, so now I'm going to write 203", but in between the time of them checking, and the time of them updating the value, the kill coint went from 200 to 202, meaning the second server is now using old stale data to arrive at the incorrect value.

This brings us to a new rule:

**Rule 1**
Don't rely on indexer-data as input to compute your results off-chain and then post the results on-chain. The indexer data may be stale or the values may change from the time you compute your output and the time you post it. If possible, always do the computation on-chain, so that you can use the latest data.

This is true for both single-writer and multi-writer objects; even with single writer your machine might be using the same private-key to post multiple results quickly, and end up overwriting itself!

(Do version ids effect this?)

**Rule 2**

-

### Data to put on chain:

1. any items or currency with financial value
2. any data with financial implications (such as which player won the game, if players are wagering money on the game)
3. any data you want other people to be able to write to
