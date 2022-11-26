module sui_playground::conditional_type {
    use sui::object::{UID};
    use sui::dynamic_object_field;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct ChildType1 has key, store {
        id: UID
    }

    struct ChildType2 has key, store {
        id: UID
    }

    struct Parent has key {
        id: UID
    }

    // Our application assumes ChildType1 will be stored at the key b"1", Childtype2 is stored with any
    // other vector<u8> key
    public fun store<AnyChild: key + store>(parent: &mut Parent, key: vector<u8>, child: AnyChild) {
        dynamic_object_field::add(&mut parent.id, key, child);
    }

    // Does not work
    public fun retrieve(parent: &mut Parent, key: vector<u8>, ctx: &mut TxContext) {
        let child = if (key == b"1") {
            dynamic_object_field::remove<vector<u8>, ChildType1>(&mut parent.id, key)
        } else {
            dynamic_object_field::remove<vector<u8>, ChildType2>(&mut parent.id, key)
        };

        transfer::transfer(child, tx_context::sender(ctx));
    }

    // Does not work either
    public fun retrieve2(parent: &mut Parent, key: vector<u8>, ctx: &mut TxContext) {
        let child = dynamic_object_field::remove(&mut parent.id, key);

        transfer::transfer(child, tx_context::sender(ctx));
    }
}