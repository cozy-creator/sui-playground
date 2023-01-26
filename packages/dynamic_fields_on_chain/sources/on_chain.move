module sui_playground::on_chain {
    use std::ascii;
    use std::string::{String, utf8};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field;
    use sui::dynamic_object_field;

    struct Something has key {
        id: UID,
        namaiwa: ascii::String
    }

    struct ThingToStore has store {
        description: String,
        size: u64
    }

    struct ObjectToStore has key, store {
        id: UID,
        text: ascii::String,
        more_text: String
    }
    
    fun init(ctx: &mut TxContext) {
        let addr = tx_context::sender(ctx);

        let something1 = Something { id: object::new(ctx), namaiwa: ascii::string(b"Paul Fidika") };

        let something2 = Something { id: object::new(ctx), namaiwa: ascii::string(b"Shawn Fidika") };

        let key = b"key-as-vector-of-bytes";
        dynamic_field::add(&mut something1.id, key, ThingToStore { description: utf8(b"more words here"), size: 57} );

        let key2 = utf8(b"key as a utf8");
        dynamic_field::add(&mut something1.id, key2, ThingToStore { description: utf8(b"something about long text"), size: 99999} );

        let key3 = ascii::string(b"key as an ascii");
        dynamic_field::add(&mut something1.id, key3, ThingToStore { description: utf8(b"blah blah balh"), size: 286});

        let key3 = 696900000000000;
        dynamic_field::add(&mut something1.id, key3, ThingToStore { description: utf8(b"...and such"), size: 88877});

        let key4  = b"key-as-vector-of-bytes";
        dynamic_object_field::add(&mut something2.id, key4, ObjectToStore {
            id: object::new(ctx),
            text: ascii::string(b"This is real ascii"),
            more_text: utf8(b"UTF8 string here bro")
        });

        let key5  = 973;
        dynamic_object_field::add(&mut something2.id, key5, ObjectToStore {
            id: object::new(ctx),
            text: ascii::string(b"This is ascii again"),
            more_text: utf8(b"UTF8 string here my man")
        });

        let key6  = 199999000;
        dynamic_object_field::add(&mut something2.id, key6, ObjectToStore {
            id: object::new(ctx),
            text: ascii::string(b"This is ascii again ==========="),
            more_text: utf8(b"UTF8 string here my man ========")
        });

        transfer::transfer(something1, addr);
        transfer::transfer(something2, addr);
    }
}