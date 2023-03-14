module sui_playground::view {
    use sui::object::{Self, UID};
    use sui::dynamic_field;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct Whatever has key, store {
        id: UID
    }

    public fun view1(uid: &UID): bool {
        *dynamic_field::borrow<bool, bool>(uid, true)
    }

    public fun view2(uid: UID): bool {
        let res = *dynamic_field::borrow<bool, bool>(&uid, true);
        object::delete(uid);
        res
    }

    // private function
    fun view3(): bool {
        true
    }

    fun init(ctx: &mut TxContext) {
        let whatever = Whatever {
            id: object::new(ctx)
        };
        dynamic_field::add(&mut whatever.id, true, true);
        transfer::transfer(whatever, tx_context::sender(ctx));
    }
}