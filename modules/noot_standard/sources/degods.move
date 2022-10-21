module openrails::degods {
    use sui::object::{Self, UID};
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

    struct Degods has drop {}

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
        let addr = tx_context::sender(ctx);
        let royalty_cap = noot::create_collection(witness, Degods {}, ctx);

        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, addr);
        transfer::transfer(royalty_cap, addr);
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

    public entry fun load_noot_dispenser(_admin_cap: &AdminCap, dispenser: &mut NootDispenser, traits: vector<vector<u8>>, ctx: &mut TxContext) {
        let body = Traits {
            id: object::new(ctx),
            background: string::utf8(*vector::borrow(&traits, 0)),
            skin: string::utf8(*vector::borrow(&traits, 1)),
            specialty: string::utf8(*vector::borrow(&traits, 2)),
            clothes: string::utf8(*vector::borrow(&traits, 3)),
            neck: string::utf8(*vector::borrow(&traits, 4)),
            head: string::utf8(*vector::borrow(&traits, 5)),
            eyes: string::utf8(*vector::borrow(&traits, 6)),
            mouth: string::utf8(*vector::borrow(&traits, 7)),
            version: string::utf8(*vector::borrow(&traits, 8)),
            y00t: false
        };

        let display = vec_map::empty<String, String>();
        vec_map::insert(&mut display, string::utf8(b"https:png"), string::utf8(*vector::borrow(&traits, 9)));

        let noot_dna = NootDNA {
            display,
            body
        };

        vector::push_back(&mut dispenser.contents, noot_dna);
    }

    public entry fun unload_noot_dispenser_() {}

    public fun unload_noot_dispenser() {}

    public entry fun lock_dispenser() {}

    public entry fun unlock_dispenser() {}

    public entry fun craft_(coin: Coin<SUI>, send_to: address, dispenser: &mut NootDispenser, ctx: &mut TxContext) {
        let noot = craft(coin, send_to, dispenser, ctx);
        noot::transfer(Degods {}, noot, send_to);
    }

    public fun craft(coin: Coin<SUI>, owner: address, dispenser: &mut NootDispenser, ctx: &mut TxContext): Noot<Degods> {
        assert!(!dispenser.locked, EDISPENSER_LOCKED);
        let price = dispenser.price;
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);

        noot::take_coin_and_transfer(dispenser.treasury_addr, &mut coin, price, ctx);
        noot::refund(coin, ctx);

        let length = vector::length(&dispenser.contents);
        let index = rand::rng(0, length);
        let NootDNA { display, body } = vector::remove(&mut dispenser.contents, index);

        let data = noot::create_data<Degods, Traits>(Degods {}, display, body, ctx);
        let noot = noot::craft(Degods {}, option::some(owner), &data, ctx);

        noot::share_data(Degods {}, data);
        noot
    }

    // public(friend) fun give_witness(): Degods {
    //     Degods {}
    // }
}