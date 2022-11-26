module sui_playground::stored_sale {
    use sui::object::{UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::Coin;
    use std::option::{Self, Option};
    use std::vector;

    const EALREADY_RENTED: u64 = 0;
    const ENOT_CLAIMER: u64 = 1;

    // Shared object; when we want to store it we have to destroy it and then recreate it from
    // scratch because we cannot unshare objects. This means UIDs are not durable, but this should
    // be okay.
    // We can ditch the sell_offer entirely by making it a dynamic field, so that it's not bound
    // to any one coin type and so that we can switch between thse sell_offers rather easily.
    struct Noot<phantom W, M: drop> has key, store {
        id: UID,
        owner: address,
        authorizations: vector<address>, // These are namespaced
        claims: vector<vector<u8>>,
        data: vector<u8>, // Expand this
        inventory: vector<u8>, // Expand this
        royalty_license: vector<u8>, // Expand this
        sell_offer: Option<M>
    }

    // Shared or Owned
    struct Market<phantom C> has store, drop {
        price: u64
    }

    public fun create_sell_offer<W, C>(noot: &mut Noot<W, Market<C>>, price: u64, _ctx: &TxContext) {
        option::extract(&mut noot.sell_offer);
        option::fill(&mut noot.sell_offer, Market<C> {
            price
        });
    }

    public fun claim_sell_offer<W, C>(noot: &mut Noot<W, Market<C>>, coin: Coin<C>, ctx: &TxContext) {
        // Assert coin value
        transfer::transfer(coin, noot.owner);
        option::extract(&mut noot.sell_offer);

        noot.owner = tx_context::sender(ctx);
        noot.claims = vector::empty();
    }

    struct SingleRental<phantom C> has store, drop {
        can_claim: Option<address>,
        price: u64
    }

    public fun rent_out<W, C>(noot: &mut Noot<W, SingleRental<C>>, coin: Coin<C>, ctx: &TxContext) {
        // assert price
        assert!(option::is_none(&option::borrow(&noot.sell_offer).can_claim), EALREADY_RENTED);
        transfer::transfer(coin, noot.owner);
        let sell_offer = option::borrow_mut(&mut noot.sell_offer);
        option::fill(&mut sell_offer.can_claim, noot.owner);
        noot.owner = tx_context::sender(ctx);
    }

    public fun reclaim<W, C>(noot: &mut Noot<W, SingleRental<C>>, ctx: &TxContext) {
        let sell_offer = option::borrow(&noot.sell_offer);
        let claimer_address = option::borrow(&sell_offer.can_claim);
        assert!(*claimer_address == tx_context::sender(ctx), ENOT_CLAIMER);
        noot.owner = tx_context::sender(ctx);
    }
}