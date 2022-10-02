module sui_playground::thingy {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    /// The RegulatedCoin struct; holds a common `Balance<T>` which is compatible
    /// with all the other Coins and methods, as well as the `creator` field, which
    /// can be used for additional security/regulation implementations.
    struct Thingy has key, store {
        id: UID,
        number: u64
    }

    public entry fun create(ctx: &mut TxContext) {
        let thingy = Thingy {
            id: object::new(ctx),
            number: 16
        };

        transfer::transfer(thingy, tx_context::sender(ctx));
    }

    public fun read_number(thingy: &Thingy, _ctx: &TxContext): u64 {
        thingy.number
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
    use sui_playground::thingy::Thingy;
    use sui::tx_context::TxContext;

    public entry fun transfer_it(thingy: Thingy, recipient: address, _ctx: &mut TxContext) {
        transfer::transfer(thingy, recipient);
    }
}

#[test_only]
module sui_playground::test_it {
    use sui_playground::moveit;
    use sui_playground::thingy::{Thingy, create, read_number};
    use sui::test_scenario;

    #[test]
    fun test_move_things() {
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let _boop = @0xDDD;

        let scenario = &mut test_scenario::begin(&initial_owner);
        {
            // create the item and transfer it to initial owner
            create(test_scenario::ctx(scenario));
        };

        // second transaction executed by the initial owner
        test_scenario::next_tx(scenario, &initial_owner);
        {
            // extract the sword owned by the initial owner
            let thingy = test_scenario::take_owned<Thingy>(scenario);
            moveit::transfer_it(thingy, final_owner, test_scenario::ctx(scenario));
        };

        // third transaction executed by the final sword owner
        test_scenario::next_tx(scenario, &final_owner);
        {
            // extract the sword owned by the final owner
            let thingy = test_scenario::take_owned<Thingy>(scenario);
            // verify that the sword has expected properties
            assert!(read_number(&thingy, test_scenario::ctx(scenario)) == 16, 1);
            // return the sword to the object pool (it cannot be simply "dropped")
            test_scenario::return_owned(scenario, thingy);
        }
    }
}