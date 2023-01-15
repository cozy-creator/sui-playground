module sui_playground::malleability {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::dynamic_field;

    struct Something has key, store {
        id: UID,
        age: u64
    }

    public entry fun store(something: Something, ctx: &mut TxContext) {
        let something_new = Something { id: object::new(ctx), age: 1000 };
        dynamic_field::add(&mut something_new.id, 2, something);
        transfer::transfer(something_new, tx_context::sender(ctx));
    }

    fun init(ctx: &mut TxContext) {
        let something = Something { id: object::new(ctx), age: 99 };
        transfer::transfer(something, tx_context::sender(ctx));
    }
}