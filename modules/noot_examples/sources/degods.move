module noot_examples::degods {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use std::string::{Self, String};
    use std::option;
    use std::vector;
    use noot::noot::{Self, Noot};
    use noot::rand;
    use noot::dispenser;

    const EINSUFFICIENT_FUNDS: u64 = 1;
    const EDISPENSER_LOCKED: u64 = 2;

    struct WITNESS has drop {}

    // Noot type
    struct Degods has drop {}

    // Noot data type
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

    // Give admin capabilities to the address that deployed this module
    fun init(witness: WITNESS, ctx: &mut TxContext) {
        let addr = tx_context::sender(ctx);

        let noot_type_info = noot::create_type(witness, Degods {}, ctx);
        let royalty_cap = market::create_market(Degods {}, ctx);
        let dispenser_cap = dispenser::create_dispenser(Degods {});

        transfer::transfer(noot_type_info, addr);
        transfer::transfer(royalty_cap, addr);
        transfer::transfer(dispenser_cap, addr);
    }

    public entry fun load_dispenser(_dispenser_cap: &AdminCap, dispenser: &mut NootDispenser, traits: vector<vector<u8>>, ctx: &mut TxContext) {
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
        vec_map::insert(&mut display, string::utf8(b"name"), string::utf8(*vector::borrow(&traits, 9)));
        vec_map::insert(&mut display, string::utf8(b"https:png"), string::utf8(*vector::borrow(&traits, 10)));

        dispenser::load_dispenser(dispenser, display, body);
    }

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