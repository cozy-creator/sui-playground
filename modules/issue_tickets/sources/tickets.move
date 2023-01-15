module sui_playground::tickets {
    use sui::object::{Self, ID, UID};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use std::vector;

    const ENO_PERMISSION: u64 = 0;

    // Shared object?
    struct AuthorityObject<phantom C> has key, store {
        id: UID,
        allow_list: vector<address>,
        price: u64,
        coins: Coin<C>
    }

    // Single-use, cannot be stored. Pay-per-use
    struct Ticket has drop {
        for: ID
    }

    public fun issue_permission<C>(authority: &mut AuthorityObject<C>, coin: Coin<C>, ctx: &TxContext): Ticket {
        assert!(vector::contains(&authority.allow_list, &tx_context::sender(ctx)), ENO_PERMISSION);
        // assert price
        coin::join(&mut authority.coins, coin);

        Ticket {
            for: object::id(authority)
        }
    }
}