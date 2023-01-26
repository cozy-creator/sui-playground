module sui_playground::auth_cargo {
    use sui_playground::data_store;

    struct Cargo has key, store {
        id: UID,
        key: data_store::Key,
        value: vector<u8>,
        schema: ID
    }
}

module sui_playground::data_store {
    struct Key has store, copy, drop { slot: u8 }
}