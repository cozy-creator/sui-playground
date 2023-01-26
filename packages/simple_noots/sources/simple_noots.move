module sui_playground::simple_noots {
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::Coin;
    use std::option::{Self, Option};
    use std::vector;

    // Shared
    // Can't be owned; otherwise games cannot write to this unless I send it to them, in which case
    // I am dependent upon the server's honesty + security + availability to retrieve my item.
    // A reverse client-server model could result in updates being censored by the client (player)
    //
    // The problem with this is that because it's shared, ANYONE can get a mutable reference to it.
    // This means that whenever someone wants to use an API to modify a noot, such as add_authorization,
    // we'll have to request a ctx, which will be checked against the owner.
    // All noot::functions will need to receive a ctx and check the sender against the owner.
    //
    // This means that mut references have no AUTHORITY. The AUTHORITY is inside of the ctx.
    // This also means that noots CANNOT BE STORED in some other object which could gate authority to it;
    // first shared objects cannot be shared at all, but even if they could it will be useless because
    // sending out references have no authority over a noot.
    // -
    // If we wanted a 'DAO sharing noot' object, we would need to (1) set the owner to be a 
    struct SimpleNoot<phantom World> has key, store {
        id: UID,
        owner: address,
        authorizations: vector<address>,
        claims: vector<vector<u8>>,
        transfer_cap: Option<TransferCap>,
        data: vector<u8>, // Expand this
        inventory: vector<u8>, // Expand this
        royalty_license: vector<u8> // Expand this
    }

    // ========= Lock Noot method ==============

    // Shared or Owned
    struct SellOffer2<phantom World> has key, store {
        id: UID,
        price: u64,
        pay_to: address,
        noot: Option<SimpleNoot<World>>
    }

    // The problem with this is if the noot is shared then we have to delete it and re-create it entirely
    // just to list it here
    public fun create_sell_offer2<W>(noot: SimpleNoot<W>, price: u64, ctx: &mut TxContext): SellOffer2<W> {
        SellOffer2 {
            id: object::new(ctx),
            price,
            pay_to: tx_context::sender(ctx),
            noot: option::some(noot)
        }
    }

    public fun claim_sell_offer2<W, C>(
        noot: &mut SimpleNoot<W>, 
        sell_offer: &mut SellOffer<C>, 
        coin: Coin<C>, 
        ctx: &TxContext
    ) {
        // assert coin value
        transfer::transfer(coin, sell_offer.pay_to);
        noot.owner = tx_context::sender(ctx);
        noot.claims = vector::empty();
    }

    // ========= Lock Transfer Cap method ==============

    struct TransferCap has key, store {
        id: UID,
        for: ID
    }

    // Shared or Owned
    struct SellOffer<phantom World> has key, store {
        id: UID,
        price: u64,
        pay_to: address,
        transfer_cap: Option<TransferCap>
    }

    public fun transfer<W>(noot: &mut SimpleNoot<W>, new_owner: address, claim: vector<u8>) {
        noot.owner = new_owner;
        vector::push_back(&mut noot.claims, claim);
    }

    // The problem with this is that if the noot is stored somewhere which is impossible to access
    // it will be impossible for someone to complete this purchase
    public fun create_sell_offer<W>(noot: &mut SimpleNoot<W>, price: u64, ctx: &mut TxContext): SellOffer<W> {
        let transfer_cap = option::extract(&mut noot.transfer_cap);

        SellOffer {
            id: object::new(ctx),
            price,
            pay_to: tx_context::sender(ctx),
            transfer_cap: option::some(transfer_cap)
        }
    }

    public fun claim_sell_offer<W, C>(
        noot: &mut SimpleNoot<W>, 
        sell_offer: &mut SellOffer<C>, 
        coin: Coin<C>, 
        ctx: &TxContext
    ) {
        // assert coin value
        transfer::transfer(coin, sell_offer.pay_to);
        noot.owner = tx_context::sender(ctx);
        noot.claims = vector::empty();
    }
}