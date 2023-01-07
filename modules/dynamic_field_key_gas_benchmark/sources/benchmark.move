module sui_playground::benchmark {
    use std::vector;
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field;
    use sui::dynamic_object_field;
    use std::string::{Self, String};

    const LIST1: vector<u8> = vector[0u8, 1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 9u8, 10u8, 11u8, 12u8, 13u8, 14u8, 15u8, 16u8, 17u8, 18u8, 19u8, 20u8, 21u8, 22u8, 23u8, 24u8, 25u8, 26u8, 27u8, 28u8, 29u8, 30u8, 31u8, 32u8, 33u8, 34u8, 35u8, 36u8, 37u8, 38u8, 39u8, 40u8];

    const LIST2: vector<vector<u8>> = vector[b"image", b"name", b"description", b"url", b"attribute", b"schema_version", b"module_authority", b"uri", b"homepage", b"buy_now", b"interface", b"website", b"org", b"licensing_rights", b"ip_rights", b"image1", b"image2", b"image3", b"image4", b"image5", b"image6", b"image7", b"image8", b"image9", b"image10", b"image11", b"image12", b"image13", b"image14", b"image15", b"image16", b"image17", b"image18", b"image19", b"image20", b"image21", b"image22", b"image23", b"image24", b"image25"];

    struct Object has key {
        id: UID
    }

    struct Key has store, copy, drop { slot: u8 }
    struct Key2 has store, copy, drop { slot: String }
    struct Key3 has store, copy, drop { }

    struct Metadata has key, store {
        id: UID,
        schema_version: address
    }

    public entry fun create1(ctx: &mut TxContext) {
        let object = Object { id: object::new(ctx) };

        let i = 0;
        while (i < vector::length(&LIST1)) {
            dynamic_field::add(&mut object.id, Key { slot: *vector::borrow(&LIST1, i) }, true);
            i = i + 1;
        };

        transfer::transfer(object, tx_context::sender(ctx));
    }

    public entry fun create2(ctx: &mut TxContext) {
        let object = Object { id: object::new(ctx) };

        let i = 0;
        while (i < vector::length(&LIST2)) {
            dynamic_field::add(&mut object.id, Key2 { slot: string::utf8(*vector::borrow(&LIST2, i)) }, true);
            i = i + 1;
        };
        
        transfer::transfer(object, tx_context::sender(ctx));
    }

    public entry fun create3(ctx: &mut TxContext) {
        let object = Object { id: object::new(ctx) };

        let i = 0;
        while (i < vector::length(&LIST1)) {
            dynamic_field::add(&mut object.id, *vector::borrow(&LIST1, i), true);
            i = i + 1;
        };
        
        transfer::transfer(object, tx_context::sender(ctx));
    }

    public entry fun create4(ctx: &mut TxContext) {
        let object = Object { id: object::new(ctx) };
        let metadata = Metadata { id: object::new(ctx), schema_version: @0x58 };

        dynamic_object_field::add(&mut object.id, Key3 {}, metadata);
        let metadata = dynamic_object_field::borrow_mut<Key3, Metadata>(&mut object.id, Key3 {});

        let i = 0;
        while (i < vector::length(&LIST2)) {
            dynamic_field::add(&mut metadata.id, *vector::borrow(&LIST2, i), true);
            i = i + 1;
        };
        
        transfer::transfer(object, tx_context::sender(ctx));
    }
}