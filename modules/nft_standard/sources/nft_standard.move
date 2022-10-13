module openrails::nft_standard {
    use sui::object::{Self, ID, UID};
    // use sui::coin::{Coin};
    use std::option;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::balance;
    use std::vector;

    const EBAD_WITNESS: u64 = 0;
    const ENOT_OWNER: u64 = 1;
    const ENO_TRANSFER_PERMISSION: u64 = 2;
    const EINSUFFICIENT_FUNDS: u64 = 3;

    struct TransferCap<phantom T> has store {
        for: ID
    }

    // Unbound generic type
    struct NFT<phantom T> has key {
        id: UID,
        owner: option::Option<address>,
        data: option::Option<ID>,
        transfer_cap: option::Option<TransferCap<T>>
    }

    struct NFTData<phantom T> has key {
        id: UID,
        data: vector<u8>,
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
        id: UID
    }

    struct Loan<phantom T> has key, store {
        id: UID,
        transfer_cap: TransferCap<T>
    }

    // May be a shared or owned object. Used in the buy_nft function call to pay
    // royalties. Multiple Royalty objects may exist per `T`. NFTs cannot be bought or
    // sold without access to a Royalty object.
    struct Royalty<phantom T> has key, store {
        id: UID,
        pay_to: address,
        fee_bps: u64
    }
    
    // Owned object, kept by the creator. NFTs of type `T` cannot be created without
    // this. Only one will ever exist per `T`
    struct MintCap<phantom T> has key, store {
        id: UID
    }

    // Owned object, kept by the creator. Used to create Royalty objects of type `T`
    // or change them. Only one will ever exist per `T`
    struct RoyaltyCap<phantom T> has key, store {
        id: UID
    }

    struct AddressAmount<phantom C> has copy, drop {
        addr: address,
        amount: u64
    }

    // === Events ===

    // TODO: add events

    // === Admin Functions, for Collection Creators ===

    // Create a new collection type `T` and return the `MintCap` and `RoyaltyCap` for
    // `T` to the caller. Can only be called with a `one-time-witness` type, ensuring
    // that there will only ever be one of each cap per `T`.
    public fun create_collection<T: drop>(
        witness: T,
        ctx: &mut TxContext
    ): (RoyaltyCap<T>, MintCap<T>) {
        // Make sure there's only one instance of the type T
        assert!(sui::types::is_one_time_witness(&witness), EBAD_WITNESS);

        // TODO: add events
        // event::emit(CollectionCreated<T> {
        // });

        let royalty_cap = RoyaltyCap<T> {
            id: object::new(ctx)
        };

        let mint_cap = MintCap<T> {
            id: object::new(ctx),
        };

        (royalty_cap, mint_cap)
    }

    // Once the MintCap is destroyed, new NFTs cannot be created within this collection
    public entry fun destroy_mint_cap<T>(mint_cap: MintCap<T>) {
        let MintCap { id } = mint_cap;
        object::delete(id);
    }

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

    public entry fun mint_nft_<T>(send_to: address, data: &NFTData<T>, mint_cap: &MintCap<T>, ctx: &mut TxContext) {
        let nft = mint_nft(mint_cap, ctx);
        nft.owner = option::some(send_to);
        nft.data = option::some(object::id(data));
        transfer::share_object(nft);
    }

    public fun mint_nft<T>(_mint_cap: &MintCap<T>, ctx: &mut TxContext): NFT<T> {
        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);

        NFT<T> {
            id: uid,
            owner: option::none(),
            data: option::none(),
            transfer_cap: option::some(TransferCap<T> {
                for: id
            })
        }
    }

    // === User Functions, for NFT Holders ===

    public entry fun sell_nft_<C, T>(price: u64, nft: &mut NFT<T>, royalty: &Royalty<T>, market_bps: u64, ctx: &mut TxContext) {
        // Assert that the owner of this NFT is sending this tx
        assert!(is_owner(tx_context::sender(ctx), nft), ENOT_OWNER);
        // Assert that the transfer cap still exists within the NFT
        assert!(option::is_some(&nft.transfer_cap), ENO_TRANSFER_PERMISSION);

        let transfer_cap = option::extract(&mut nft.transfer_cap);
        let pay_to = tx_context::sender(ctx);
        sell_nft<C,T>(pay_to, price, transfer_cap, royalty, market_bps, ctx);
    }

    public entry fun sell_nft<C, T>(pay_to: address, price: u64, transfer_cap: TransferCap<T>, royalty: &Royalty<T>, market_bps: u64, ctx: &mut TxContext) {
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
    public entry fun buy_nft_<C, T>(for_sale: &mut SellOffer<C, T>, coin: Coin<C>, new_owner: address, royalty: &Royalty<T>, market_addr: address, nft: &mut NFT<T>, ctx: &mut TxContext) {
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

        // Refund the sender any extra balance they paid, or destroy the empty coin
        if (coin::value(&coin) > 0) { 
            coin::keep<C>(coin, ctx);
        } else {
            coin::destroy_zero(coin);
        };

        let transfer_cap = option::extract(&mut for_sale.transfer_cap);
        claim_with_transfer_cap(new_owner, nft, transfer_cap);
    }

    public fun claim_with_transfer_cap<T>(new_owner: address, nft: &mut NFT<T>, transfer_cap: TransferCap<T>) {
        assert!(is_linked(&transfer_cap, nft), ENO_TRANSFER_PERMISSION);
        nft.owner = option::some(new_owner);
        // Each NFT can only have one corresponding transfer_cap, so this will never abort
        option::fill(&mut nft.transfer_cap, transfer_cap);
    }

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

    public fun take_coin_and_transfer<C>(receiver: address, coin: &mut Coin<C>, value: u64, ctx: &mut TxContext) {
        if (value > 0) {
            let split_coin = take_from_coin<C>(coin, value, ctx);
            transfer::transfer(split_coin, receiver);
        }
    }

    // === Authority Checking Functions ===

    public fun is_owner<T>(addr: address, nft: &NFT<T>): bool {
        if (option::is_some(&nft.owner)) {
            *option::borrow(&nft.owner) == addr
        } else {
            true
        }
    }

    public fun is_linked<T>(transfer_cap: &TransferCap<T>, nft: &NFT<T>): bool {
        transfer_cap.for == object::id(nft)
    }

    // === Get functions, to read struct data ===

    public fun get_royalty_info<T>(royalty: &Royalty<T>): (address, u64) {
        (royalty.pay_to, royalty.fee_bps)
    }
}