module sui_playground::thingy {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    struct KeyStore has key, store {
        id: UID,
        number: u64
    }

    struct Key has key {
        id: UID,
        number: u64
    }

    struct Store has store {
        id: UID,
        number: u64
    }

    public entry fun create_keystore(ctx: &mut TxContext) {
        let thingy = KeyStore {
            id: object::new(ctx),
            number: 16
        };

        transfer::transfer(thingy, tx_context::sender(ctx));
    }

    public entry fun create_key(ctx: &mut TxContext) {
        let thingy = Key {
            id: object::new(ctx),
            number: 0
        };

        transfer::transfer(thingy, tx_context::sender(ctx));
    }

    // Polymorphic transfer works ONLY for objects with the KEY property

    // public entry fun create_store(ctx: &mut TxContext) {
    //     let thingy = Store {
    //         id: object::new(ctx),
    //         number: 99
    //     };

    //     transfer::transfer(thingy, tx_context::sender(ctx));
    // }

    public fun read_key(key: &Key): u64 {
        key.number
    }

    public fun read_keystore(key_store: &KeyStore): u64 {
        key_store.number
    }

    // fun init(ctx: &mut TxContext) {
    //     let thingy = Thingy {
    //         id: object::new(ctx),
    //         number: 0 
    //     };

    //     transfer::transfer(thingy, tx_context::sender(ctx));
    // }
}

module sui_playground::moveit {
    use sui::transfer;
    use sui_playground::thingy::{KeyStore};
    use sui::tx_context::TxContext;

    public entry fun transfer_keystore(thingy: KeyStore, recipient: address, _ctx: &mut TxContext) {
        transfer::transfer(thingy, recipient);
    }

    // NOTE: this code will NOT compile. This transfer is NOT allowed

    // public entry fun transfer_key(thingy: Key, recipient: address, _ctx: &mut TxContext) {
    //     transfer::transfer(thingy, recipient);
    // }
}

#[test_only]
module sui_playground::test_it {
    use sui_playground::moveit;
    use sui_playground::thingy::{KeyStore, create_keystore, read_keystore};
    use sui::test_scenario;

    #[test]
    fun test_move_things() {
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let _boop = @0xDDD;

        let scenario = &mut test_scenario::begin(&initial_owner);
        {
            // create the item and transfer it to initial owner
            create_keystore(test_scenario::ctx(scenario));
        };

        // second transaction executed by the initial owner
        test_scenario::next_tx(scenario, &initial_owner);
        {
            let key = test_scenario::take_owned<KeyStore>(scenario);
            moveit::transfer_keystore(key, final_owner, test_scenario::ctx(scenario));
        };

        // third transaction executed by the final owner
        test_scenario::next_tx(scenario, &final_owner);
        {
            let key = test_scenario::take_owned<KeyStore>(scenario);
            assert!(read_keystore(&key) == 16, 1);
            test_scenario::return_owned(scenario, key);
        }
    }
}