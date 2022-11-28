module sui_playground::function_key {
    use std::vector;
    use sui::object::UID;
    use sui::tx_context::{Self, TxContext};
    use sui::math;

    // enums to specify the vector index for each corresponding permission
    // There must be one, and only one, owner at a time.
    // Owner = can add and remove other authorizations.
    // Transfer = can remove owner and all authorizations, add new owner.
    // 
    // There must be one, and only one, owner at a time. Only the owner can transfer, sell, or store the noot.
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

    // shared object
    struct Noot has key, store {
        id: UID,
        keys: vector<Authorization>,
        lock: Authorization,
        claims: vector<vector<u8>>
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

    public entry fun create_sell_offer(noot: &mut Noot, _price: u64, _ctx: &mut TxContext) {
        *vector::borrow_mut(&mut noot.lock.permissions, WITHDRAW_INVENTORY) = false;
    }

    public entry fun transfer(noot: &mut Noot, new_address: address, claim: vector<u8>, ctx: &mut TxContext) {
        assert!(check_permission(noot, ctx, OWNER), ENO_PERMISSION);
        let new_keys = vector[ Authorization { user: new_address, permissions: FULL_PERMISSION }];
        noot.keys = new_keys;
        vector::push_back(&mut noot.claims, claim);
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

    public fun get_permission(noot: &Noot, ctx: &TxContext): vector<bool> {
        let addr = tx_context::sender(ctx);
        let (exists, i) = index_of(&noot.keys, addr);
        if (!exists) { NO_PERMISSION }
        else {
            logical_and_join(&noot.lock.permissions, &vector::borrow(&noot.keys, i).permissions)
        }
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