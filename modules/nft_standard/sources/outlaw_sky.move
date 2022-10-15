module openrails::outlaw_sky {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use openrails::d_item::{Self, DItem};

    const EINSUFFICIENT_FUNDS: u64 = 1;

    struct OUTLAW_SKY has drop {}

    struct Data has key {
        id: UID,
        stuff: u64
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
        royalty_cap: d_item::RoyaltyCap<OUTLAW_SKY>,
        crafting_cap: d_item::CraftingCap<OUTLAW_SKY>
    }

    fun init(witness: OUTLAW_SKY, ctx: &mut TxContext) {
        let addr = tx_context::sender(ctx);

        let (royalty_cap, crafting_cap) = d_item::create_collection<OUTLAW_SKY>(witness, ctx);

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
        let d_item = craft(coin, send_to, cap_chest, craft_info, ctx);
        transfer::transfer(d_item, send_to);
    }

    public fun craft(coin: Coin<SUI>, send_to: address, cap_chest: &CapabilityChest, craft_info: &mut CraftInfo, ctx: &mut TxContext): DItem<OUTLAW_SKY> {
        let price = *&craft_info.price;
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);
        d_item::take_coin_and_transfer(craft_info.treasury_addr, &mut coin, price, ctx);
        d_item::refund(coin, ctx);

        let inner_data = Data {
            id: object::new(id),
            stuff: 5
        };
        let data = d_item::create_data(data, ctx);

        let addr = tx_context::sender(ctx);
        let d_item = d_item::craft(send_to, &data, &cap_chest.crafting_cap, ctx);

        transfer::share_object(data);
        d_item
    }
}