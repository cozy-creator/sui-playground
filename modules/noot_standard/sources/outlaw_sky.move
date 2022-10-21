module openrails::outlaw_sky {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::vec_map;
    use openrails::noot::{Self, Noot, NootData};
    use std::string::{Self, String};
    use std::option;

    const EINSUFFICIENT_FUNDS: u64 = 1;
    const ENOT_OWNER: u64 = 2;
    const EWRONG_DATA: u64 = 3;

    struct WITNESS has drop {}

    struct OUTLAW_SKY has drop {}

    // NOTE: this data is meant to be compact, rather than explanative. For the indexer, we'll
    // have to add some sort of file which maps data to human-readable format. Perhaps a simple
    // javascript function?
    struct Data has store {
        traits: vec_map::VecMap<String, Trait>
    }

    struct Trait has store {
        base: u8,
        variant: u8
    }

    struct CraftInfo has key {
        id: UID,
        treasury_addr: address,
        price: u64,
        total_supply: u64,
        max_supply: u64
    }

    struct CapabilityChest has key {
        id: UID,
        royalty_cap: noot::RoyaltyCap<OUTLAW_SKY>,
    }

    fun init(one_time_witness: WITNESS, ctx: &mut TxContext) {
        let _addr = tx_context::sender(ctx);

        let royalty_cap = noot::create_collection(one_time_witness, OUTLAW_SKY {}, ctx);

        let cap_chest = CapabilityChest {
            id: object::new(ctx),
            royalty_cap
        };

        let craft_info = CraftInfo {
            id: object::new(ctx),
            treasury_addr: tx_context::sender(ctx),
            price: 10,
            total_supply: 0,
            max_supply: 10000
        };

        transfer::share_object(cap_chest);
        transfer::share_object(craft_info);
    }

    public entry fun craft_(coin: Coin<SUI>, send_to: address, craft_info: &mut CraftInfo, ctx: &mut TxContext) {
        let noot = craft(coin, send_to, craft_info, ctx);
        transfer::transfer(noot, send_to);
    }

    public fun craft(coin: Coin<SUI>, owner: address, craft_info: &mut CraftInfo, ctx: &mut TxContext): Noot<OUTLAW_SKY> {
        let price = *&craft_info.price;
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);
        noot::take_coin_and_transfer(craft_info.treasury_addr, &mut coin, price, ctx);
        noot::refund(coin, ctx);

        let (display, body) = generate_data(ctx);

        let noot_data = noot::create_data(OUTLAW_SKY {}, display, body, ctx);

        let noot = noot::craft(OUTLAW_SKY {}, option::some(owner), &noot_data, ctx);

        transfer::share_object(noot_data);
        noot
    }

    public fun generate_data(_ctx: &mut TxContext): (vec_map::VecMap<String, String>, Data) {
        let display = vec_map::empty<String, String>();
        let url = string::utf8(b"https://website.com/some/image1000.png");
        vec_map::insert(&mut display, string::utf8(b"https:png"), url);

        let traits = vec_map::empty<String, Trait>();
        vec_map::insert(&mut traits, string::utf8(b"overlay"), Trait { base: 0, variant: 0 });
        vec_map::insert(&mut traits, string::utf8(b"headwear"), Trait { base: 0, variant: 0 });
        vec_map::insert(&mut traits, string::utf8(b"hair"), Trait { base: 0, variant: 0 });
        vec_map::insert(&mut traits, string::utf8(b"earrings"), Trait { base: 0, variant: 0 });
        
        let body = Data {
            traits
        };

        (display, body)
    }

    // This would allow owners of a noot to modify their data arbitrarily
    public entry fun modify_data(noot: &Noot<OUTLAW_SKY>, noot_data: &mut NootData<OUTLAW_SKY, Data>, key: String, base: u8, variant: u8, ctx: &mut TxContext) {
        // Make sure the transaction sender owns the noot
        assert!(noot::is_owner(tx_context::sender(ctx), noot), ENOT_OWNER);
        // Make sure the data corresponds to the noot
        assert!(noot::is_correct_data(noot, noot_data), EWRONG_DATA);

        let body_ref = noot::borrow_data_body(OUTLAW_SKY {}, noot_data);

        if (vec_map::contains(&body_ref.traits, &key)) {
            let (_old_key, old_trait) = vec_map::remove(&mut body_ref.traits, &key);
            let Trait { base: _, variant: _ } = old_trait;
        };

        vec_map::insert(&mut body_ref.traits, key, Trait { base, variant });
    }
}