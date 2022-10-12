// Thoughts: for future upgradeability in mind, it might make sense to break packages up into mini-packages
// that are concerned each with one small area of the dataset, rather than large monolotihic packages.
// This will make it easier to ugprade packages in the future; fewer objects neeed to be migrated.

// User client-game: generates a random keypair, stores it safely
// Game-server: has its own keypair
// 

module openrails::apex_legends {
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use std::vector;

    // This is an owned-object, owned by the player. Each legend-number in the vector is true or false,
    // depending on whether or not the player as made the purchase already
    struct LegendsUnlocked has key {
        id: UID,
        inner: vector<bool>
    }

    // For each legend-number, this array holds the current price of the legend.
    // This is a shared object; it can only be updated by the game-creators, but
    // has to be used in every purchase transaction. This makes purchase-prices modular
    struct LegendPriceList has key {
        id: UID,
        inner: vector<u64>,
        to_pay: address
    }

    struct LegendSkin has key, store {
        id: UID,
        legend: u8,
        skin: u8
    }

    struct WeaponSkin has key, store {
        id: UID,
        weapon: u8,
        skin: u8
    }

    // The problem with this system is that the dev can NEVER add any new fields, otherwise it's a breaking
    // change. They would have to (1) add a new struct for each new field added, or (2) migrate everyone
    // over to a completely new package (yuck!). That's right; an entire PACKAGE, not just a new module.
    struct PlayerStats has key {
        id: UID,
        user: address,
        matches: u64,
        wins: u64,
        kills: u64,
        deaths: u64,
        level: u64,
        exp: u64,
        battle_pass_level: u64,
        battle_pass_exp: u64
    }

    // This will simply be serialized JSON in the data field. The problem with this is that it's not very
    // useful; no one can use it on-chain for anything without a whole de-serializer. Also it causes
    // concurrency issues.
    struct PlayerStats2 has key {
        data: vector<u8>
    }

    // Buys the legend
    public entry fun buy_legend(coin: &mut Coin<SUI>, price_list: &LegendPriceList, legend_num: u8, legends_unlocked: &mut LegendsUnlocked, ctx: &mut TxContext) {
        let recipient = price_list.to_pay;
        let price = vector::borrow(&price_list.inner, (legend_num as u64));

        // We assume that a price of 0 means the legend doesn't exist
        assert!(*price != 0, 0);

        coin::split_and_transfer(coin, *price, recipient, ctx);
        let unlocked = vector::borrow_mut(&mut legends_unlocked.inner, (legend_num as u64));
        // This legend was already unlocked
        assert!(!*unlocked, 0);
        *unlocked = true;
    }

    public entry fun buy_legend_skin() {

    }

    public entry fun buy_weapon_skin() {

    }

    // admin only

    public entry fun change_legend_price_list() {

    }

}