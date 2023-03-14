// If you give me an object with only key, I drop it, store it, transfer it (own), freeze, or share it.
// In fact, that only thing I can do is return it!

module sui_playground::my_stuff {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    struct MyStuff has key {
        id: UID
    }

    public fun create_one(ctx: &mut TxContext): MyStuff {
        MyStuff { id: object::new(ctx) }
    }
}

module sui_playground::no_way_back {
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui_playground::my_stuff;

    public entry fun whatever(ctx: &mut TxContext) {
        let stuff = my_stuff::create_one(ctx);
        transfer::share_object(stuff);
        // transfer::freeze_object(stuff);
    }
}