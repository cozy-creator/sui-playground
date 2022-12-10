module openrails::gas_benchmark {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use std::string;

    struct OwnedStruct has key {
        id: UID,
        data: string::String
    }

    struct SharedStruct has key {
        id: UID,
        data: string::String
    }

    struct Something has store {
        module: u64
    }

    public fun do_something(something: &mut Something) {
        something.module = 59;
    }

    public entry fun create_owned(data_raw: vector<u8>, ctx: &mut TxContext) {
        let data = string::utf8(data_raw);
        let owned_struct = OwnedStruct {
            id: object::new(ctx),
            data
        };
        transfer::transfer(owned_struct, tx_context::sender(ctx));
    }

    public entry fun create_shared(data_raw: vector<u8>, ctx: &mut TxContext) {
        let data = string::utf8(data_raw);
        let shared_struct = SharedStruct {
            id: object::new(ctx),
            data
        };
        transfer::share_object(shared_struct);
    }

    public entry fun edit_owned(owned_struct: &mut OwnedStruct, data_raw: vector<u8>) {
        let data = string::utf8(data_raw);
        owned_struct.data = data
    }

    public entry fun edit_shared(shared_struct: &mut SharedStruct, data_raw: vector<u8>) {
        let data = string::utf8(data_raw);
        shared_struct.data = data
    }

    public entry fun failure() {
        assert!(false, 0);
    }

    public fun not_entry() {
        // does nothing
        assert!(true, 0);
    }
}