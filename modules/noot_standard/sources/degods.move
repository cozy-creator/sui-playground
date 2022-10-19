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
    use openrails::noot::{Self};
    use openrails::rand;

    const EINSUFFICIENT_FUNDS: u64 = 1;

    struct DEGODS has drop {}

    struct Data has store {
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
        media: VecMap<String, String>,
        data: Data
    }

    struct VendingMachine has key {
        id: UID,
        price: u64,
        treasury_addr: address,
        noot_dna: vector<NootDNA>,
    }

    public entry fun create_vending_() {

    }

    public fun create_vending(): VendingCapability {
        
    }

    public entry fun load_vending(traits: vector<String>, vending_machine: &mut VendingMachine, ctx: &mut TxContext) {
        let addr = tx_context::sender(ctx);

        let data = Data {
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

        let media = vec_map::empty<String, String>();
        vec_map::insert(&mut media, string::utf8(b"https::png"), *vector::borrow(&traits, 9));

        let noot_dna = NootDNA {
            media,
            data
        };

        vector::push_back(&mut vending_machine.noot_dna, noot_dna);
    }

    public entry fun craft_(coin: Coin<SUI>, send_to: address, vending_machine: &mut VendingMachine, ctx: &mut TxContext) {
        let noot = craft(coin, send_to, cap_chest, craft_info, ctx);
        transfer::transfer(noot, send_to);
    }

    public fun craft(coin: Coin<SUI>, owner: address, vending_machine: &mut VendingMachine, ctx: &mut TxContext): DItem<DEGODS> {
        let price = vending_machine.price;
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);
        d_item::take_coin_and_transfer(vending_machine.treasury_addr, &mut coin, price, ctx);
        d_item::refund(coin, ctx);

        let length = vector::length(&vending_machine.noot_dna);
        let index = rand::rng(0, length);
        let noot_dna = vector::remove(&mut vending_machine.noot_dna, index);
        let NootDNA { media, data } = noot_dna;

        let data = d_item::create_data<DEGODS, Data>(data, media, ctx);

        let d_item = d_item::craft(owner, &data, &cap_chest.crafting_cap, ctx);

        transfer::share_object(data);
        d_item
    }
}