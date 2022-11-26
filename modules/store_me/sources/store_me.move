// This doesn't work; you need to have 'store' ability to be stored, even within the module
// that defines the struct

module sui_playground::store_me {
    use sui::object::UID;
    use sui::tx_context::{Self, TxContext};
    use sui::object;
    use sui::transfer;

    struct Something has key {
        id: UID
    }

    struct Wrapper has key {
        id: UID,
        inside: Something
    }

    public fun store_it(ctx: &mut TxContext) {
        let something = Something { id: object::new(ctx) };
        let wrapper = Wrapper {
            id: object::new(ctx),
            inside: something
        };

        // transfer::transfer(wrapper, tx_context::sender(ctx));
    }
}