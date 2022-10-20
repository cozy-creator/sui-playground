module openrails::outlaw_sky {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::vec_map;
    use openrails::noot::{Self, Noot};
    use std::string::{Self, String};

    const EINSUFFICIENT_FUNDS: u64 = 1;
    const ENOT_OWNER: u64 = 2;

    struct WITNESS<phantom T> has drop {}

    struct OUTLAW_SKY has drop {}

    // NOTE: this data is meant to be compact, rather than explanative. For the indexer, we'll
    // have to add some sort of file which maps data to human-readable format. Perhaps a simple
    // javascript function?
    struct Data has key {
        id: UID,
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
        crafting_cap: noot::CraftingCap<OUTLAW_SKY>
    }

    fun init(witness: OUTLAW_SKY, ctx: &mut TxContext) {
        let _addr = tx_context::sender(ctx);

        let (royalty_cap, crafting_cap) = noot::create_collection<OUTLAW_SKY>(witness, ctx);

        let cap_chest = CapabilityChest {
            id: object::new(ctx),
            royalty_cap,
            crafting_cap
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

    public entry fun craft_(coin: Coin<SUI>, send_to: address, cap_chest: &CapabilityChest, craft_info: &mut CraftInfo, ctx: &mut TxContext) {
        let noot = craft(coin, send_to, cap_chest, craft_info, ctx);
        transfer::transfer(noot, send_to);
    }

    public fun craft(coin: Coin<SUI>, owner: address, cap_chest: &CapabilityChest, craft_info: &mut CraftInfo, ctx: &mut TxContext): Noot<OUTLAW_SKY> {
        let price = *&craft_info.price;
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);
        noot::take_coin_and_transfer(craft_info.treasury_addr, &mut coin, price, ctx);
        noot::refund(coin, ctx);

        let (media, inner_data) = generate_data(ctx);

        let data = noot::create_data<OUTLAW_SKY, Data>(inner_data, media, ctx);

        let noot = noot::craft(owner, &data, &cap_chest.crafting_cap, ctx);

        transfer::share_object(data);
        noot
    }

    public fun generate_data(ctx: &mut TxContext): (vec_map::VecMap<String, String>, Data) {
        let media = vec_map::empty<String, String>();
        let url = string::utf8(b"https://website.com/some/image1000.png");
        vec_map::insert(&mut media, string::utf8(b"https::png"), url);

        let traits = vec_map::empty<String, Trait>();
        vec_map::insert(&mut traits, string::utf8(b"overlay"), Trait { base: 0, variant: 0 });
        vec_map::insert(&mut traits, string::utf8(b"headwear"), Trait { base: 0, variant: 0 });
        vec_map::insert(&mut traits, string::utf8(b"hair"), Trait { base: 0, variant: 0 });
        vec_map::insert(&mut traits, string::utf8(b"earrings"), Trait { base: 0, variant: 0 });
        
        let inner_data = Data {
            id: object::new(ctx),
            traits
        };

        (media, inner_data)
    }

    public entry fun modify_data(noot: &Noot<OUTLAW_SKY>, data: &mut Data, new_value: u64, ctx: &TxContext) {
        assert!(noot::is_owner(tx_context::sender(ctx), noot), ENOT_OWNER);
        data.stuff = new_value;
    }
}