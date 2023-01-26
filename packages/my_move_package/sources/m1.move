module pauls_package::m1 {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct Sword has key, store {
        id: UID,
        attack: u64,
        durability: u64
    }

    public fun get_attack(self: &Sword): u64 {
        self.attack
    }

    public fun get_durability(self: &Sword): u64 {
        self.durability
    }

    public entry fun forge_sword(attack: u64, durability: u64, ctx: &mut TxContext) {
        let sword = Sword {
            id: object::new(ctx),
            attack,
            durability
        };
        transfer::transfer(sword, tx_context::sender(ctx));
    }

    public fun gimme_sword(attack: u64, durability: u64, ctx: &mut TxContext): Sword {
        Sword {
            id: object::new(ctx),
            attack,
            durability
        }
    }
}

module pauls_package::steal_it {

}

#[test_only]
module pauls_package::tests {
    use sui::test_scenario;
    // use sui::object;
    use sui::tx_context;
    use pauls_package::m1::{Self, Sword};
    use sui::transfer;

    #[test]
    fun test_create() {
        let owner = @0x69;
        let other_person = @0x420;

        // Create a Sword and transfer it to @owner.
        let scenario = &mut test_scenario::begin(&owner);
        {
            let ctx = test_scenario::ctx(scenario);
            let sword = m1::gimme_sword(9, 18, ctx);
            transfer::transfer(sword, tx_context::sender(ctx));

            let sword = m1::gimme_sword(9, 18, ctx);
            transfer::transfer(sword, tx_context::sender(ctx));

            // m1::forge_sword(10, 15, ctx);
            // m1::forge_sword(5, 6, ctx);
            // m1::forge_sword(1, 11, ctx);
        };

        // Check that @not_owner does not own the just-created ColorObject.
        test_scenario::next_tx(scenario, &other_person);
        {
            assert!(!test_scenario::can_take_owned<Sword>(scenario), 0);
        };

        // Check that @owner indeed owns the just-created ColorObject.
        // Also checks the value fields of the object.
        test_scenario::next_tx(scenario, &owner);
        {
            // let sword = test_scenario::take_owned<Sword>(scenario);
            // let durability = m1::get_durability(&sword);
            // assert!(durability == 15, 0);
            // test_scenario::return_owned(scenario, sword);
        };
    }
}
