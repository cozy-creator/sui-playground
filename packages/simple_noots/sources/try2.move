module sui_playground::try2 {
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::Coin;
    use std::option::{Self, Option};
    use std::vector;

    // shared object
    struct NootWrapper<phantom W> has key {
        id: UID,
        owner: address,
        authorizations: vector<address>, // Authorizations are namespaced
        noot: Option<Noot<W>>,
        claims: vector<vector<u8>>,
        transfer_cap: Option<TransferCap>,
    }

    // Stored, never owned
    struct Noot<phantom W> has key, store {
        id: UID,
        data: vector<u8>, // Expand this
        inventory: vector<u8>, // Expand this
        royalty_license: vector<u8> // Expand this
    }

    // Shared or Owned
    struct SellOffer has key, store {
        id: UID,
        price: u64,
        pay_to: address,
        transfer_cap: Option<TransferCap>
    }

    struct TransferCap has store {
        for: ID
    }

    public fun create_sell_offer<W>(noot_wrapper: &mut NootWrapper<W>, price: u64, ctx: &mut TxContext): SellOffer {
        let transfer_cap = option::extract(&mut noot_wrapper.transfer_cap);

        SellOffer {
            id: object::new(ctx),
            price,
            pay_to: tx_context::sender(ctx),
            transfer_cap: option::some(transfer_cap)
        }
    }

    public fun claim_sell_offer<W, C>(noot_wrapper: &mut NootWrapper<W>, sell_offer: &mut SellOffer, coin: Coin<C>, ctx: &TxContext) {
        // Assert coin value
        transfer::transfer(coin, sell_offer.pay_to);
        let transfer_cap = option::extract(&mut sell_offer.transfer_cap);
        option::fill(&mut noot_wrapper.transfer_cap, transfer_cap);

        noot_wrapper.owner = tx_context::sender(ctx);
        noot_wrapper.claims = vector::empty();
    }
}