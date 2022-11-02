module parent_child::parent_child {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::dynamic_object_field::{Self as ofield};

    struct Parent has key, store {
        id: UID,
        age: u64
    }

    struct Child has key, store {
        id: UID,
        grade: u64
    }

    public fun setup(ctx: &mut TxContext) {
        let parent = Parent { id: object::new(ctx), age: 37 };
        let child = Child { id: object::new(ctx), grade: 5 };

        transfer::transfer(parent, tx_context::sender(ctx));
        transfer::transfer(child, tx_context::sender(ctx));
    }

    public fun add_child(parent: &mut Parent, child: Child) {
        ofield::add(&mut parent.id, 15, child);
    }

    public fun borrow_child(parent: &mut Parent) {
        let child_ref = ofield::borrow_mut<u64, Child>(&mut parent.id, 15);
        child_ref.grade = child_ref.grade + 2;
    }

    public fun mutate_child(child: &mut Child) {
        child.grade = child.grade + 1;
    }
}

#[test_only]
module parent_child::tests {
    use parent_child::parent_child::{Self, Parent, Child};
    use sui::test_scenario;

    #[test]
    fun child_exists_outside_of_parent() {
        let sender = @0x0;
        let scenario = test_scenario::begin(sender);

        // Setup
        parent_child::setup(test_scenario::ctx(&mut scenario));

        // Add child to parent
        test_scenario::next_tx(&mut scenario, sender);
        let parent = test_scenario::take_from_address<Parent>(&mut scenario, sender);
        let child = test_scenario::take_from_address<Child>(&mut scenario, sender);
        parent_child::add_child(&mut parent, child);
        test_scenario::return_to_address(sender, parent);

        // Use the parent to access the child
        test_scenario::next_tx(&mut scenario, sender);
        let parent = test_scenario::take_from_address<Parent>(&mut scenario, sender);
        parent_child::borrow_child(&mut parent);
        test_scenario::return_to_address(sender, parent);

        // Create a new child, then borrow it and use it
        test_scenario::next_tx(&mut scenario, sender);
        parent_child::setup(test_scenario::ctx(&mut scenario));

        // Try again
        test_scenario::next_tx(&mut scenario, sender);
        let child = test_scenario::take_from_address<Child>(&mut scenario, sender);
        parent_child::mutate_child(&mut child);
        test_scenario::return_to_address(sender, child);

        // Access the child directly
        // test_scenario::next_tx(&mut scenario, sender);
        // let child = test_scenario::take_from_address<Child>(&mut scenario, sender);
        // parent_child::mutate_child(&mut child);
        // test_scenario::return_to_address(sender, child);

        test_scenario::end(scenario);
    }
}