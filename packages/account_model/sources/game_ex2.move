module account_model::game_example2 {
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

    public entry fun create(account: &mut GameAccount, owner: address, ctx: &mut TxContext) {
        let skin = Skin { id: object::new(ctx) };
        let auth = tx_authority::being_with_type(&Witness {});

        account::store(account, skin, owner, &auth);
    }

    // We could implicitly store the delegation inside of the GameAccount
    public entry fun store_foreign(account: &mut GameAccount, owner: address, ctx: &mut TxContext) {
        let skin = Skin { id: object::new(ctx) };
        let auth = tx_authority::being_with_type(&Witness {});

        account::store(account, skin, owner, &auth);
    }

    public fun retrieve<T: store>(account: &mut GameAccount, id: ID): T {
        let auth = tx_authority::begin_with_type(&Witness {});

        account::remove(account, id, &auth)
    }
}