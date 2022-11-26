module sui_playground::tickets {
    // Shared object?
    struct AuthorityObject<C> has key, store {
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
        assert!(vector::contains(&authority.allow_list, tx_context::sender(ctx)), ENO_PERMISSION);
        // assert price
        coin::merge(&mut authority.coins, coin);

        Ticket {
            for: object::id(authority)
        }
    }
}