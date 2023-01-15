
module sui_playground::old_marketplace {
    use sui_playground::owner::OwnerKey;

    struct Key has store, copy, drop {};

    struct SellOffer<phantom C> has store, drop {
        price: u64,
        pay_to: address,
        owner_key: OwnerKey
    }

    public fun add_sell_offer<C>(id: &mut UID, price: u64, ctx: &TxContext) {
        let sell_offer = SellOffer<C> { 
            price, 
            pay_to: tx_context::sender(ctx),
            owner_key: ???
        };
        dynamic_field::add(id, Key {}, sell_offer);
    }

    public fun fulfill_offer<C>(id: &mut UID, coin: Coin<C>, ctx: &TxContext) {
        let SellOffer { price, pay_to, owner_key } = dynamic_field::remove(id, Key {});
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);
        transfer::transfer(coin, pay_to);
        authority::transfer(owner_key, id, tx_context::sender(ctx));
    }
}
