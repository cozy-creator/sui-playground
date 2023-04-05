module capsules::gas_benchmark {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use std::string::String;

    struct OwnedStruct has key, store {
        id: UID,
        data: String
    }

    struct SharedStruct has key, store {
        id: UID,
        data: String
    }

    public entry fun create_owned(data: String, ctx: &mut TxContext) {
        let owned_struct = OwnedStruct {
            id: object::new(ctx),
            data
        };
        transfer::transfer(owned_struct, tx_context::sender(ctx));
    }

    public entry fun create_shared(data: String, ctx: &mut TxContext) {
        let shared_struct = SharedStruct {
            id: object::new(ctx),
            data
        };
        transfer::share_object(shared_struct);
    }

    public entry fun edit_owned(owned_struct: &mut OwnedStruct, data: String) {
        owned_struct.data = data
    }

    public entry fun edit_shared(shared_struct: &mut SharedStruct, data: String) {
        shared_struct.data = data
    }

    public entry fun delete_owned(owned_struct: OwnedStruct) {
        let OwnedStruct { id, data: _ } = owned_struct;
        object::delete(id);
    }

    public entry fun create_many_owned(data: String, number: u64, ctx: &mut TxContext) {
        let i = 0;
        while (i < number) {
            create_owned(data, ctx);
            i = i + 1;
        };
    }

    public entry fun create_many_shared(data: String, number: u64, ctx: &mut TxContext) {
        let i = 0;
        while (i < number) {
            create_shared(data, ctx);
            i = i + 1;
        };
    }

    public entry fun failure() {
        assert!(false, 0);
    }

    public fun not_entry() {
        assert!(true, 0);
    }
}