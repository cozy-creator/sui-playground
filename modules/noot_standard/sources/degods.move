module openrails::degods {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use std::string::{Self, String};
    use std::option;
    use std::vector;
    use openrails::noot::{Self, Noot};
    use openrails::rand;

    const EINSUFFICIENT_FUNDS: u64 = 1;
    const EDISPENSER_LOCKED: u64 = 2;

    struct WITNESS has drop {}

    struct DEGODS has drop {}

    struct AdminCap has key, store {
        id: UID
    }

    struct Traits has store {
        id: UID,
        background: String,
        skin: String,
        specialty: String,
        clothes: String,
        neck: String,
        head: String,
        eyes: String,
        mouth: String,
        version: String,
        y00t: bool
    }

    struct NootDNA has store {
        display: VecMap<String, String>,
        body: Traits
    }

    struct NootDispenser has key {
        id: UID,
        price: u64,
        treasury_addr: address,
        locked: bool,
        contents: vector<NootDNA>,
    }

    // Give the admin capability to the address that deployed this module
    fun init(witness: WITNESS, ctx: &mut TxContext) {
        let royalty_cap = noot::create_collection(witness, DEGODS {}, ctx);

        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }

    public entry fun create_dispenser_(admin_cap: &AdminCap, price: u64, treasury_addr: address, ctx: &mut TxContext) {
        let noot_dispenser = create_dispenser(admin_cap, price, treasury_addr, ctx);
        transfer::share_object(noot_dispenser);
    }

    public fun create_dispenser(_admin_cap: &AdminCap, price: u64, treasury_addr: address, ctx: &mut TxContext): NootDispenser {
        NootDispenser {
            id: object::new(ctx),
            price,
            treasury_addr,
            locked: true,
            contents: vector::empty<NootDNA>()
        }
    }

    public entry fun load_noot_dispenser(_admin_cap: &AdminCap, dispenser: &mut NootDispenser, traits: vector<String>, ctx: &mut TxContext) {
        let addr = tx_context::sender(ctx);

        let body = Traits {
            id: object::new(ctx),
            background: *vector::borrow(&traits, 0),
            skin: *vector::borrow(&traits, 1),
            specialty: *vector::borrow(&traits, 2),
            clothes: *vector::borrow(&traits, 3),
            neck: *vector::borrow(&traits, 4),
            head: *vector::borrow(&traits, 5),
            eyes: *vector::borrow(&traits, 6),
            mouth: *vector::borrow(&traits, 7),
            version: *vector::borrow(&traits, 8),
            y00t: false
        };

        let display = vec_map::empty<String, String>();
        vec_map::insert(&mut display, string::utf8(b"https:png"), *vector::borrow(&traits, 9));

        let noot_dna = NootDNA {
            display,
            body
        };

        vector::push_back(&mut dispenser.contents, noot_dna);
    }

    public entry fun craft_(coin: Coin<SUI>, send_to: address, dispenser: &mut NootDispenser, ctx: &mut TxContext) {
        let noot = craft(coin, send_to, dispenser, ctx);
        transfer::transfer(noot, send_to);
    }

    public fun craft(coin: Coin<SUI>, owner: address, dispenser: &mut NootDispenser, ctx: &mut TxContext): Noot<DEGODS> {
        assert!(!dispenser.locked, EDISPENSER_LOCKED);
        let price = dispenser.price;
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);

        noot::take_coin_and_transfer(dispenser.treasury_addr, &mut coin, price, ctx);
        noot::refund(coin, ctx);

        let length = vector::length(&dispenser.contents);
        let index = rand::rng(0, length);
        let NootDNA { display, body } = vector::remove(&mut dispenser.contents, index);

        let data = noot::create_data<DEGODS, Traits>(DEGODS {}, display, body, ctx);
        let noot = noot::craft(DEGODS {}, option::some(owner), &data, ctx);

        transfer::share_object(data);
        noot
    }
}