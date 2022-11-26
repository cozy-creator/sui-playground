module sui_playground::function_key {
    use sui::object::UID;
    use std::bit_vector::{Self, BitVector};
    use std::vector;
    use sui::tx_context::{Self, TxContext};
    use std::option::Option;

    // enums to specify the vector index for each corresponding permission
    const TRANSFER: u8 = 0;
    const SELL: u8 = 1;
    const CREATE_DATA: u8 = 2;
    const UPDATE_DATA: u8 = 3;
    const DELETE_DATA: u8 = 4;
    const DEPOSIT_INVENTORY: u8 = 5;
    const USE_INVENTORY: u8 = 6;
    const WITHDRAW_INVENTORY: u8 = 7;
    const OWNER: u8 = 8;

    // error enums
    const EWRONG_SIZE: u64 = 0;
    const ENO_PERMISSION: u64 = 1;
    const EONLY_ONE_OWNER: u64 = 2;

    // stored object
    struct Authorization has store, drop {
        user: address,
        permissions: BitVector
    }

    // shared object
    struct Noot has key, store {
        id: UID,
        keys: vector<Authorization>,
        claims: vector<vector<u8>>
    }

    public entry fun add_authorization(noot: &mut Noot, user: address, _none: Option<u8>, ctx: &mut TxContext) {
        let permissions = bit_vector::new(9);
        assert!(bit_vector::length(&permissions) == 9, EWRONG_SIZE);
        assert!(check_permission(noot, ctx, OWNER), ENO_PERMISSION);

        // There can only be one owner at a time
        assert!(!bit_vector::is_index_set(&permissions, (OWNER as u64)), EONLY_ONE_OWNER);

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

    public entry fun transfer(noot: &mut Noot, new_address: address, claim: vector<u8>, ctx: &mut TxContext) {
        assert!(check_permission(noot, ctx, OWNER), ENO_PERMISSION);
        let new_keys = vector[ Authorization { user: new_address, permissions: bit_vector::new(9) }];
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

    public fun check_permission(noot: &Noot, ctx: &mut TxContext, index: u8): bool {
        let addr = tx_context::sender(ctx);
        let (exists, i) = index_of(&noot.keys, addr);
        if (!exists) { false }
        else {
            let authorization = vector::borrow(&noot.keys, i);
            bit_vector::is_index_set(&authorization.permissions, (index as u64))
        }
    }
}