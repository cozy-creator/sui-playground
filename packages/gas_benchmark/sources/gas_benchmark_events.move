module capsules::gas_benchmark_events {
    use std::string::String;

    use sui::event;
    use sui::object::{Self, ID};
    use sui::tx_context::TxContext;

    use capsules::gas_benchmark::{Self, OwnedStruct, SharedStruct};

    struct OwnedStructCreated has copy, drop {
        data: String
    }

    struct SharedStructCreated has copy, drop {
        data: String
    }

    struct OwnedStructEdited has copy, drop {
        id: ID,
        data: String
    }

    struct SharedStructEdited has copy, drop {
        id: ID,
        data: String
    }

    struct OwnedStructDeleted has copy, drop {
        id: ID
    }

    public entry fun create_owned(data: String, ctx: &mut TxContext) {
        gas_benchmark::create_owned(data, ctx);
        event::emit( OwnedStructCreated { data } );
    }

    public entry fun create_shared(data: String, ctx: &mut TxContext) {
        gas_benchmark::create_shared(data, ctx);
        event::emit( SharedStructCreated { data } );
    }

    public entry fun edit_owned(owned_struct: &mut OwnedStruct, data: String) {
        gas_benchmark::edit_owned(owned_struct, data);
        event::emit( OwnedStructEdited { id: object::id(owned_struct), data } );
    }

    public entry fun edit_shared(shared_struct: &mut SharedStruct, data: String) {
        gas_benchmark::edit_shared(shared_struct, data);
        event::emit( SharedStructEdited { id: object::id(shared_struct), data } );
    }

    public entry fun delete_owned(owned_struct: OwnedStruct) {
        event::emit( OwnedStructDeleted { id: object::id(&owned_struct) } );
        gas_benchmark::delete_owned(owned_struct);
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