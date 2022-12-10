module sui_playground::rebirth {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    struct Weird has key {
        id: UID,
        id2: UID,
        id3: UID
    }

    public fun rebirth(weird: Weird, ctx: &mut TxContext): Weird {
        let Weird { id, id2, id3 } = weird;

        object::delete(id);

        let reborn = Weird {id: id2, id2: id3, id3: object::new(ctx) };
        reborn
    }
}