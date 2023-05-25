module sui_playground::non_store {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use std::vector;

    struct NonStore has drop {}

    struct TryAnyway has drop {
        nonstore: vector<NonStore>
    }

    public entry fun execute(_ctx: &mut TxContext) {
        let i = 0;
        let vec = vector::empty();
        while (i < 10) {
            vector::push_back(&mut vec, NonStore {});
            i = i + 1;
        };


    }
}