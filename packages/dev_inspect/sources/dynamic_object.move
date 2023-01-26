module sui_playground::dynamic_object {
    use sui::dynamic_object_field;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::object::{Self, UID};
    use sui::transfer;

    struct Something has key, store {
        id: UID,
        name: String,
        age: u16
    }

    fun init(ctx: &mut TxContext) {
        let father = Something {
            id: object::new(ctx),
            name: string::utf8(b"Father Of All"),
            age: 99u16
        };

        let child1 = Something {
            id: object::new(ctx),
            name: string::utf8(b"Greed"),
            age: 16u16
        };

        let child2 = Something {
            id: object::new(ctx),
            name: string::utf8(b"Gluttony"),
            age: 16u16
        };

        let child3 = Something {
            id: object::new(ctx),
            name: string::utf8(b"Wrath"),
            age: 16u16
        };

        dynamic_object_field::add(&mut father.id, 0, child1);
        dynamic_object_field::add(&mut father.id, 1, child2);
        dynamic_object_field::add(&mut father.id, 2, child3);
        transfer::transfer(father, tx_context::sender(ctx));
    }
}