module sui_playground::size_test {
    use std::string::String;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::dynamic_field;

    struct StaticStore has key, store {
        id: UID,
        data: String
    }

    struct DynamicStore has key, store {
        id: UID
    }

    public entry fun store1(data: String, ctx: &mut TxContext) {
        let store = StaticStore {
            id: object::new(ctx),
            data
        };
        transfer::transfer(store, tx_context::sender(ctx));
    }

    public entry fun store2(data: String, ctx: &mut TxContext) {
        let store = DynamicStore {
            id: object::new(ctx)
        };
        dynamic_field::add(&mut store.id, 0, data);
        transfer::transfer(store, tx_context::sender(ctx));
    }
}