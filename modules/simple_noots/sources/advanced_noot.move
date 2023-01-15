module sui_playground::advanced_noot {
    use sui::object::{UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::Coin;
    use sui::dynamic_field;
    use std::option::{Self, Option};
    use std::vector;

    const EALREADY_RENTED: u64 = 0;
    const ENOT_CLAIMER: u64 = 1;

    // Shared object; when we want to store it we have to destroy it and then recreate it from
    // scratch because we cannot unshare objects. This means UIDs are not durable, but this should
    // be okay.
    // We can ditch the sell_offer entirely by making it a dynamic field, so that it's not bound
    // to any one coin type and so that we can switch between thse sell_offers rather easily.
    struct Noot<phantom W> has key, store {
        id: UID,
        owner: address,
        authorizations: vector<address>, // These are namespaced
        claims: vector<vector<u8>>,
        data: vector<u8>, // Expand this
        inventory: vector<u8>, // Expand this
        royalty_license: vector<u8>, // Expand this
    }

    // Shared or Owned
    struct Market<phantom C> has store, drop {
        price: u64
    }

    public fun create_sell_offer<W, C>(noot: &mut Noot<W>, price: u64, _ctx: &TxContext) {
        dynamic_field::add(&mut noot.id, vector[0], Market<C> {
            price
        });
    }

    public fun claim_sell_offer<W, C>(noot: &mut Noot<W>, coin: Coin<C>, ctx: &TxContext) {
        // Assert coin value
        let _sell_offer = dynamic_field::remove<vector<u8>, Market<C>>(&mut noot.id, vector[0]);
        transfer::transfer(coin, noot.owner);

        // Instead of dropping it, we can return the sell-offer to pay a royalty or something

        noot.owner = tx_context::sender(ctx);
        noot.claims = vector::empty();
    }

    struct SingleRental<phantom C> has store, drop {
        can_claim: Option<address>,
        price: u64
    }

    public fun create_rental<W, C>(noot: &mut Noot<W>, price: u64, _ctx: &mut TxContext) {
        // assert that it doesn't already exist and isn't already being claimable

        dynamic_field::add(&mut noot.id, vector[1], SingleRental<C> {
            can_claim: option::none<address>(),
            price
        })
    }

    public fun rent_out<W, C>(noot: &mut Noot<W>, coin: Coin<C>, ctx: &TxContext) {
        let single_rental = dynamic_field::borrow_mut<vector<u8>, SingleRental<C>>(&mut noot.id, vector[1]);

        // assert price
        assert!(option::is_none(&single_rental.can_claim), EALREADY_RENTED);

        transfer::transfer(coin, noot.owner);
        option::fill(&mut single_rental.can_claim, noot.owner);
        noot.owner = tx_context::sender(ctx);
    }

    public fun reclaim<W, C>(noot: &mut Noot<W>, ctx: &TxContext) {
        let single_rental = dynamic_field::remove<vector<u8>, SingleRental<C>>(&mut noot.id, vector[1]);

        let claimer_address = option::extract(&mut single_rental.can_claim);
        assert!(claimer_address == tx_context::sender(ctx), ENOT_CLAIMER);

        noot.owner = tx_context::sender(ctx);
    }
}