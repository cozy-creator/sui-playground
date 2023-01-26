// This does not work; once an object is bound to a type, it cannot be changed to
// another type, even if the value it was storing changes.

module sui_playground::transmoguration {
    use std::option::{Self, Option};
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};

    struct Flexible<A> has key, store {
        id: UID,
        something: Option<A>
    }

    struct ThingA has store, drop {}

    struct ThingB has store, drop {}

    public fun create<A>(ctx: &mut TxContext): Flexible<ThingA> {
        Flexible {
            id: object::new(ctx),
            something: option::some(ThingA {})
        }
    }

    public fun transmoguration(flexible: Flexible<ThingA>): Flexible<ThingB> {
        option::extract(&mut flexible.something);
        flexible.something = option::some(ThingB {});
        flexible
    }
}