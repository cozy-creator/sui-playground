module account_model::game_example {
    struct Skin has key, store {
        id: UID
    }

    struct Character has key, store {
        id: UID
    }

    struct Currency has key, store {
        id: UID,
        balance: u64
    }

    struct Witness {}

    public entry fun create(account: &mut Account, ctx: &mut TxContext) {
        let auth = tx_authority::begin_with_type(&Witness {});
        let namespace = tx_authority::type_into_address<Witness>();

        let skin = Skin { id: object::new(ctx) };

        account::store(account, namespace, skin, auth); // this pushes to a vector if one already exists
    }

    public entry fun create_foreign(account: &mut Account, namespace: address, delegation: &Delegation ctx: &mut TxContext) {
        let auth = tx_authority::begin_with-type(&Witness {});
        let auth = delegation::claim(namespace, delegation, &auth);

        let skin = Skin { id: object::new(ctx) };

        account::store(account, namespace, skin, auth);
    }

    public fun retrieve<T>(account: &mut Account, id: ID): &mut T {
        let auth = tx_authority::begin_with_type(&Witness {});

        account::borrow_mut(account, id, auth)
    }
}