module openrails::noot {
    use sui::object::{Self, ID, UID};
    // use sui::coin::{Coin};
    use std::option::{Self, Option};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::balance;
    use sui::vec_map::VecMap;
    use std::vector;
    use std::string::String;

    const EBAD_WITNESS: u64 = 0;
    const ENOT_OWNER: u64 = 1;
    const ENO_TRANSFER_PERMISSION: u64 = 2;
    const EINSUFFICIENT_FUNDS: u64 = 3;

    struct TransferCap<phantom T> has store {
        for: ID
    }

    // Unbound generic type
    struct Noot<phantom T> has key {
        id: UID,
        owner: option::Option<address>,
        data: option::Option<ID>,
        transfer_cap: option::Option<TransferCap<T>>
    }

    // TODO: Replace VecMap with a more efficient data structure once one becomes a available within Sui
    // VecMap only has O(N) lookup time
    struct NootData<phantom T, D: store> has key {
        id: UID,
        display: VecMap<String, String>,
        body: D
    }

    // transfer_Cap is only optional until shared objects can be deleted in Sui.
    struct SellOffer<phantom C, phantom T> has key, store {
        id: UID,
        pay_to: address,
        price: u64,
        royalty_addr: address,
        seller_royalty: u64,
        market_fee: u64,
        transfer_cap: option::Option<TransferCap<T>>
    }

    struct BuyOffer<phantom C, phantom T> has key, store {
        id: UID,
        send_to: address,
        for: option::Option<ID>,
        offer: Coin<C>
    }

    struct ReclaimCapability<phantom T> has key, store {
        id: UID,
        transfer_cap: TransferCap<T>
    }

    // May be a shared or owned object. Used in the buy_noot function call to pay
    // royalties. Multiple Royalty objects may exist per `T`. Noots cannot be bought or
    // sold without access to a Royalty object.
    struct Royalty<phantom T> has key, store {
        id: UID,
        pay_to: address,
        fee_bps: u64
    }
    
    // Owned object, kept by the creator. Noots of type `T` cannot be created without
    // this. Only one will ever exist per `T`
    // struct CraftingCap<phantom T> has key, store {
    //     id: UID
    // }

    // Owned object, kept by the creator. Used to create Royalty objects of type `T`
    // or change them. Only one will ever exist per `T`
    struct RoyaltyCap<phantom T> has key, store {
        id: UID
    }

    // === Events ===

    // TODO: add events

    // === Admin Functions, for Collection Creators ===

    // Note that because one_time_witness and _witness (the noot's struct type) are different,
    // it's possible that the same collection could be created multiple times. Although
    // I don't know why a collection would want to do that. If that occurs, it's probably
    // a bug or a hack.

    // Create a new collection type `T` and return the `CraftingCap` and `RoyaltyCap` for
    // `T` to the caller. Can only be called with a `one-time-witness` type, ensuring
    // that there will only ever be one of each cap per `T`.
    public fun create_collection<W: drop, T: drop>(
        one_time_witness: W,
        _witness: T, 
        ctx: &mut TxContext
    ): RoyaltyCap<T> {
        // Make sure there's only one instance of the type T
        assert!(sui::types::is_one_time_witness(&one_time_witness), EBAD_WITNESS);

        // TODO: add events
        // event::emit(CollectionCreated<T> {
        // });

        RoyaltyCap<T> {
            id: object::new(ctx)
        }

        // let crafting_cap = CraftingCap<T> {
        //     id: object::new(ctx),
        // };
    }

    // Once the CraftingCap is destroyed, new dItems cannot be created within this collection
    // public entry fun destroy_crafting_cap<T>(crafting_cap: CraftingCap<T>) {
    //     let CraftingCap { id } = crafting_cap;
    //     object::delete(id);
    // }

    public entry fun create_royalty_<T>(pay_to: address, fee_bps: u64, royalty_cap: &RoyaltyCap<T>, ctx: &mut TxContext) {
        let royalty = create_royalty<T>(pay_to, fee_bps, royalty_cap, ctx);
        transfer::share_object(royalty);
    }

    public fun create_royalty<T>(pay_to: address, fee_bps: u64, _royalty_cap: &RoyaltyCap<T>, ctx: &mut TxContext): Royalty<T> {
        Royalty<T> {
            id: object::new(ctx),
            pay_to,
            fee_bps
        }
    }

    // This is of limited utility until shared objects can be destroyed in Sui; right now this can only
    // destroy royalties if they are owned objects
    public entry fun destroy_royalty<T>(royalty: Royalty<T>, _royalty_cap: &RoyaltyCap<T>) {
        let Royalty { id, pay_to: _, fee_bps: _ } = royalty;
        object::delete(id);
    }

    // Do we really need this function? Isn't creating and destroying enough?
    public entry fun change_royalty<T>(royalty: &mut Royalty<T>, new_pay_to: address, new_fee_bps: u64, _royalty_cap: &RoyaltyCap<T>) {
        royalty.pay_to = new_pay_to;
        royalty.fee_bps = new_fee_bps;    
    }

    public entry fun craft_<T: drop, D: store>(witness: T, send_to: address, data: &NootData<T, D>, ctx: &mut TxContext) {
        let noot = craft(witness, option::some(send_to), data, ctx);
        transfer::transfer(noot, send_to);
    }

    public fun craft<T: drop, D: store>(_witness: T, owner: Option<address>, data: &NootData<T, D>, ctx: &mut TxContext): Noot<T> {
        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);

        Noot<T> {
            id: uid,
            owner: owner,
            data: option::some(object::id(data)),
            transfer_cap: option::some(TransferCap<T> {
                for: id
            })
        }
    }

    public fun create_data<T: drop, D: store>(_witness: T, display: VecMap<String, String>, body: D, ctx: &mut TxContext): NootData<T, D> {
        NootData {
            id: object::new(ctx),
            display,
            body
        }
    }

    // === User Functions, for Noot Holders ===

    public entry fun create_sell_offer_<C, T>(price: u64, noot: &mut Noot<T>, royalty: &Royalty<T>, market_bps: u64, ctx: &mut TxContext) {
        // Assert that the owner of this Noot is sending this tx
        assert!(is_owner(tx_context::sender(ctx), noot), ENOT_OWNER);
        // Assert that the transfer cap still exists within the Noot
        assert!(option::is_some(&noot.transfer_cap), ENO_TRANSFER_PERMISSION);

        let transfer_cap = option::extract(&mut noot.transfer_cap);
        let pay_to = tx_context::sender(ctx);
        create_sell_offer<C,T>(pay_to, price, transfer_cap, royalty, market_bps, ctx);
    }

    public entry fun create_sell_offer<C, T>(pay_to: address, price: u64, transfer_cap: TransferCap<T>, royalty: &Royalty<T>, market_bps: u64, ctx: &mut TxContext) {
        let for_sale = SellOffer<C, T> {
            id: object::new(ctx),
            pay_to,
            price,
            royalty_addr: royalty.pay_to,
            seller_royalty: (((price as u128) * (royalty.fee_bps as u128) / 10000) as u64),
            market_fee: (((price as u128) * (market_bps as u128) / 10000) as u64),
            transfer_cap: option::some(transfer_cap)
        };

        transfer::share_object(for_sale);
    }

    // Once Sui supports passing shared objects by value, rather than just reference, this function
    // will change to consume the shared SellOffer wrapper, and delete it.
    // Note that the new_owner does not necessarily have to be the sender of the transaction
    public entry fun fill_seller_offer<C, T>(for_sale: &mut SellOffer<C, T>, coin: Coin<C>, new_owner: address, royalty: &Royalty<T>, market_addr: address, noot: &mut Noot<T>, ctx: &mut TxContext) {
        assert!(option::is_some(&for_sale.transfer_cap), ENO_TRANSFER_PERMISSION);

        let buyer_royalty = ((for_sale.price as u128) * (royalty.fee_bps as u128) / 10000 / 2 as u64);
        assert!(coin::value(&coin) >= (for_sale.price + buyer_royalty), EINSUFFICIENT_FUNDS);

        // Buyer's part of the royalty. This is not included in for_sale.price.
        take_coin_and_transfer(royalty.pay_to, &mut coin, buyer_royalty, ctx);

        // Seller's part of the royalty. Note that the seller and buy royalty addresses and
        // amounts need not be the same.
        take_coin_and_transfer(for_sale.royalty_addr, &mut coin, for_sale.seller_royalty, ctx);

        // Marketplace fee
        take_coin_and_transfer(market_addr, &mut coin, for_sale.market_fee, ctx);

        // Remainder goes to the seller
        take_coin_and_transfer(for_sale.pay_to, &mut coin, for_sale.price - for_sale.seller_royalty - for_sale.market_fee, ctx);

        refund(coin, ctx);

        let transfer_cap = option::extract(&mut for_sale.transfer_cap);
        claim_with_transfer_cap(new_owner, noot, transfer_cap);
    }

    // In the future, this will delete the SellOffer
    public entry fun cancel_sell_offer<C, T>(for_sale: &mut SellOffer<C,T>, noot: &mut Noot<T>, ctx: &TxContext) {
        let addr = tx_context::sender(ctx);
        assert!(addr == *option::borrow(&noot.owner), ENOT_OWNER);

        let transfer_cap = option::extract(&mut for_sale.transfer_cap);
        assert!(transfer_cap.for == object::id(noot), ENO_TRANSFER_PERMISSION);
        option::fill(&mut noot.transfer_cap, transfer_cap);
    }

    public entry fun claim_with_transfer_cap<T>(new_owner: address, noot: &mut Noot<T>, transfer_cap: TransferCap<T>) {
        assert!(is_linked(&transfer_cap, noot), ENO_TRANSFER_PERMISSION);
        noot.owner = option::some(new_owner);
        // Each Noot can only have one corresponding transfer_cap, so this will never abort
        option::fill(&mut noot.transfer_cap, transfer_cap);
    }

    public entry fun create_buy_offer() {}

    public entry fun fill_buy_offer() {}

    public entry fun cancel_buy_offer() {}

    // === Helper Utility Functions ===

    // These functions should be included in the sui::coin module; I'll create a PR later

    /// Split coin `self` into multiple coins, each with balance specified
    /// in `split_amounts`. Remaining balance is left in `self`.
    public fun split_to_coin_vec<C>(self: &mut Coin<C>, split_amounts: vector<u64>, ctx: &mut TxContext): vector<Coin<C>> {
        let split_coin = vector::empty<Coin<C>>();
        let i = 0;
        let len = vector::length(&split_amounts);
        while (i < len) {
            let coin = take_from_coin(self, *vector::borrow(&split_amounts, i), ctx);
            vector::push_back(&mut split_coin, coin);
            i = i + 1;
        };
        split_coin
    }

    public fun take_from_coin<C>(coin: &mut Coin<C>, value: u64, ctx: &mut TxContext): Coin<C> {
        let balance_mut = coin::balance_mut(coin);
        let sub_balance = balance::split(balance_mut, value);
        coin::from_balance(sub_balance, ctx)
    }

    public entry fun take_coin_and_transfer<C>(receiver: address, coin: &mut Coin<C>, value: u64, ctx: &mut TxContext) {
        if (value > 0) {
            let split_coin = take_from_coin<C>(coin, value, ctx);
            transfer::transfer(split_coin, receiver);
        }
    }

    // Refund the sender any extra balance they paid, or destroy the empty coin
    public entry fun refund<C>(coin: Coin<C>, ctx: &TxContext) {
        if (coin::value(&coin) > 0) { 
            coin::keep<C>(coin, ctx);
        } else {
            coin::destroy_zero(coin);
        };
    }

    // === Authority Checking Functions ===

    public fun is_owner<T>(addr: address, noot: &Noot<T>): bool {
        if (option::is_some(&noot.owner)) {
            *option::borrow(&noot.owner) == addr
        } else {
            true
        }
    }

    public fun has_transfer_cap<T>(noot: &Noot<T>): bool {
        option::is_some(&noot.transfer_cap)
    }

    public fun is_linked<T>(transfer_cap: &TransferCap<T>, noot: &Noot<T>): bool {
        transfer_cap.for == object::id(noot)
    }

    // === Get functions, to read struct data ===

    public fun get_royalty_info<T>(royalty: &Royalty<T>): (address, u64) {
        (royalty.pay_to, royalty.fee_bps)
    }
}