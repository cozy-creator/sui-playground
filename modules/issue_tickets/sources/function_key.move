module sui_playground::function_key {
    use std::vector;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::math;
    use sui::dynamic_object_field;
    use sui::transfer;
    use sui::coin::Coin;

    // enums to specify the vector index for each corresponding permission
    // There must be one, and only one, owner at a time.
    // Owner = can add and remove other authorizations.
    // Transfer = can remove owner and all authorizations, add new owner.
    // 
    // There must be one, and only one, owner at a time. Only the owner can transfer, sell, or store the noot.
    // For sale = no withdrawing from inventory, no consumption
    // Loaned to a friend = no withdraw from inventory, no consumption, no selling, no transfer
    // Borrowed Against = no withdraw from inventory, no consumption, no selling (or sale must be > loan, and repay loan)
    // Loaded into game = no transfer, no selling
    const OWNER: u64 = 0;
    const SELL: u64 = 1;
    const CREATE_DATA: u64 = 2;
    const UPDATE_DATA: u64 = 3;
    const DELETE_DATA: u64 = 4;
    const DEPOSIT_INVENTORY: u64 = 5;
    const MUT_INVENTORY: u64 = 6;
    const WITHDRAW_INVENTORY: u64 = 7;
    const PERMISSION_LENGTH: u64 = 8;
    const FULL_PERMISSION: vector<bool> = vector[true, true, true, true, true, true, true, true];
    const NO_PERMISSION: vector<bool> = vector[false, false, false, false, false, false, false, false];

    // error enums
    const EWRONG_SIZE: u64 = 0;
    const ENO_PERMISSION: u64 = 1;
    const EONLY_ONE_OWNER: u64 = 2;

    // stored object
    struct Authorization has store, drop {
        user: address,
        permissions: vector<bool>
    }

    struct Auth {}

    struct Plugins has key, store {
        id: UID
    }

    // shared object
    struct Noot has key, store {
        id: UID,
        keys: vector<Authorization>,
        lock: Authorization,
        claims: vector<vector<u8>>,
        plugins: Plugins
    }

    public fun craft_noot(ctx: &mut TxContext): Noot {
        Noot {
            id: object::new(ctx),
            keys: vector::empty<Authorization>(),
            lock: Authorization { user: tx_context::sender(ctx), permissions: vector::empty() },
            claims: vector::empty<vector<u8>>(),
            plugins: Plugins { id: object::new(ctx) }
        }
    }

    public entry fun add_authorization(noot: &mut Noot, user: address, permissions: vector<bool>, ctx: &mut TxContext) {
        assert!(vector::length(&permissions) == PERMISSION_LENGTH, EWRONG_SIZE);
        assert!(check_permission(noot, ctx, OWNER), ENO_PERMISSION);

        // There can only be one owner at a time
        assert!(!*vector::borrow(&permissions, OWNER), EONLY_ONE_OWNER);

        let (exists, i) = index_of(&noot.keys, user);

        if (!exists) { 
            // No existing authorization found; add one
            let authorization = Authorization {
                user,
                permissions
            };
            vector::push_back(&mut noot.keys, authorization);
        } else {
            // Overwrites existing authorization
            let authorization = vector::borrow_mut(&mut noot.keys, i);
            authorization.permissions = permissions;
        }
    }

    public entry fun remove_authorization(noot: &mut Noot, user: address, ctx: &mut TxContext) {
        assert!(check_permission(noot, ctx, OWNER), ENO_PERMISSION);

        let (exists, i) = index_of(&noot.keys, user);
        if (exists) {
            vector::remove(&mut noot.keys, i);
        }
    }

    public entry fun create_data(noot: &mut Noot, ctx: &mut TxContext) {
        assert!(check_permission(noot, ctx, CREATE_DATA), ENO_PERMISSION);
        // allow data to be modified
    }

    public entry fun update_data(noot: &mut Noot, ctx: &mut TxContext) {
        assert!(check_permission(noot, ctx, UPDATE_DATA), ENO_PERMISSION);
        // allow data to be modified
    }

    public entry fun update_data_auth<Auth: key>(noot: &mut Noot, auth: &Auth) {
        assert!(check_permission_auth(noot, auth, UPDATE_DATA), ENO_PERMISSION);
        // proceed to modify data
    }

    public entry fun transfer(noot: &mut Noot, new_address: address, claim: vector<u8>, ctx: &mut TxContext) {
        assert!(check_permission(noot, ctx, OWNER), ENO_PERMISSION);
        let new_keys = vector[ Authorization { user: new_address, permissions: FULL_PERMISSION }];
        noot.keys = new_keys;
        vector::push_back(&mut noot.claims, claim);
    }

    // ============ Market functions =================

    // Stored
    // Should we add drop to this, rather than key?
    struct SellOffer<phantom C> has key, store {
        id: UID,
        price: u64,
        pay_to: address
    }

    public entry fun create_sell_offer<W, C>(noot: &mut Noot, price: u64, ctx: &mut TxContext) {
        let sell_offer = SellOffer<C> {
            id: object::new(ctx),
            price,
            pay_to: tx_context::sender(ctx)
        };

        dynamic_object_field::add(&mut noot.plugins.id, 0, sell_offer);
    }

    public entry fun fill_sell_offer<W, C>(noot: &mut Noot, coin: Coin<C>, ctx: &mut TxContext) {
        let sell_offer = dynamic_object_field::remove<u64, SellOffer<C>>(&mut noot.plugins.id, 0);
        let SellOffer { id, price: _, pay_to } = sell_offer;
        object::delete(id);

        // Assert coin value
        transfer::transfer(coin, pay_to);

        noot.keys = vector[ Authorization { user: tx_context::sender(ctx), permissions: FULL_PERMISSION }];
        noot.claims = vector::empty();
    }

    // struct SingleRental<phantom C> has store, drop {
    //     can_claim: Option<address>,
    //     price: u64
    // }

    // public fun rent_out<W, C>(noot: &mut Noot<W, SingleRental<C>>, coin: Coin<C>, ctx: &TxContext) {
    //     // assert price
    //     assert!(option::is_none(&option::borrow(&noot.sell_offer).can_claim), EALREADY_RENTED);
    //     transfer::transfer(coin, noot.owner);
    //     let sell_offer = option::borrow_mut(&mut noot.sell_offer);
    //     option::fill(&mut sell_offer.can_claim, noot.owner);
    //     noot.owner = tx_context::sender(ctx);
    // }

    // public fun reclaim<W, C>(noot: &mut Noot<W, SingleRental<C>>, ctx: &TxContext) {
    //     let sell_offer = option::borrow(&noot.sell_offer);
    //     let claimer_address = option::borrow(&sell_offer.can_claim);
    //     assert!(*claimer_address == tx_context::sender(ctx), ENOT_CLAIMER);
    //     noot.owner = tx_context::sender(ctx);
    // }

    // public entry fun create_sell_offer(noot: &mut Noot, price: u64, ctx: &mut TxContext) {
    //     *vector::borrow_mut(&mut noot.lock.permissions, WITHDRAW_INVENTORY) = false;
    // }

    // ============ Permission Checker Functions =================

    public fun check_permission(noot: &Noot, ctx: &mut TxContext, index: u64): bool {
        let addr = tx_context::sender(ctx);
        let (exists, i) = index_of(&noot.keys, addr);
        if (!exists) { false }
        else {
            let authorization = vector::borrow(&noot.keys, i);
            if (!*vector::borrow(&noot.lock.permissions, index)) { false }
            else { *vector::borrow(&authorization.permissions, index) }
        }
    }

    public fun check_permission_auth<Auth>(_noot: &Noot, _auth: &Auth, _index: u64): bool {
        true
    }

    fun check_permission_internal(_noot: &Noot): bool {
        true
    }

    public fun get_permission(noot: &Noot, ctx: &TxContext): vector<bool> {
        let addr = tx_context::sender(ctx);
        let (exists, i) = index_of(&noot.keys, addr);
        if (!exists) { NO_PERMISSION }
        else {
            logical_and_join(&noot.lock.permissions, &vector::borrow(&noot.keys, i).permissions)
        }
    }

    // ============ Helper functions =================

    public fun index_of(v: &vector<Authorization>, addr: address): (bool, u64) {
        let i = 0;
        let len = vector::length(v);
        while (i < len) {
            if (vector::borrow(v, i).user == addr) return (true, i);
            i = i + 1;
        };
        (false, 0)
    }

    // The longer vector will be kept, and its values that do not overlap with the shorter vector will not be modified 
    public fun logical_and_join(v1: &vector<bool>, v2: &vector<bool>): vector<bool> {
        let len1 = vector::length(v1);
        let len2 = vector::length(v2);
        let length = math::min(len1, len2);

        let v = vector::empty<bool>();

        let i = 0;
        while (i < length) {
            vector::push_back(&mut v, *vector::borrow(v1, i) && *vector::borrow(v2, i));
            i = i + 1;
        };

        v
    }
}