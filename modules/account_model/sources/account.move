module sui_playground::account {
    use sui::dynamic_field;
    use sui::object;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use ownership::tx_authority::{Self, TxAuthority};

    // error constants
    const ENOT_OWNER: u64 = 0;
    const ENOT_MODULE: u64 = 1;

    // shared object
    struct Account has key {
        id: UID,
        owner: address
    }

    struct Key<T> has store, copy, drop { }

    public fun create(ctx: &mut TxContext) {
        transfer::share_object(
            Account {
                id: object::new(ctx),
                owner: tx_context::sender(ctx)
            }
        )
    }

    // Destroy will cause stored objects to be permanently orphaned. Hence it's removed for now
    // public fun destroy() {}

    /// Aborts if there is already a `T` stored at this account
    public fun move_to_<T: store>(account: &mut Account, object: T, auth: &TxAuthority) {
        assert!(tx_authority::is_signed_by(account.owner, auth), ENOT_OWNER);
        assert!(tx_authority::is_signed_by_module<T>(auth), ENOT_MODULE);

        dynamic_field::add(&mut account.id, Key<T> {}, object);
    }

    public fun move_from<T: store>(account: &mut Account, auth: &TxAuthority): T {
        assert!(tx_authority::is_signed_by_module<T>(auth), ENOT_MODULE);

        dynamic_field::remove<Key<T>, T>(&mut account.id, Key<T> {})
    }

    public fun borrow_global_<T: store>(account: &Account, auth: &TxAuthority): &T {
        assert!(tx_authority::is_signed_by_module<T>(auth), ENOT_MODULE);

        dynamic_field::borrow<Key<T>, T>(&mut account.id, Key<T> {})
    }

    public fun borrow_global_mut_<T: store>(account: &mut Account, auth: &TxAuthority): &T {
        assert!(tx_authority::is_signed_by_module<T>(auth), ENOT_MODULE);

        dynamic_field::borrow_mut<Key<T>, T>(&mut account.id, Key<T> {})
    }

    public fun exists_<T: store>(account: &Account, auth: &TxAuthority): bool {
        dynamic_field::exists_(&mut account.id, Key<T> {})
    }
}