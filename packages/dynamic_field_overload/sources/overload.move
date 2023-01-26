module sui_playground::overload {
    use std::string::utf8;
    use sui::object::{Self, UID};
    use sui::dynamic_field;
    use sui::tx_context::{TxContext};
    use sui::transfer;

    struct Object has key, store {
        id: UID
    }

    public entry fun use_twice(ctx: &mut TxContext) {
        let id = object::new(ctx);

        dynamic_field::add(&mut id, 0, 99999);
        if (!dynamic_field::exists_with_type<u64, u64>(&mut id, 0)) {
            dynamic_field::add(&mut id, 0, utf8(b"Whatever I want"));
        };

        let object = Object { id };

        transfer::share_object(object);
    }

    public entry fun long_key(object: &mut Object) {
        let key = b"I am going to type a ton of text here, but nonetheless I believe the gas cost will be roughly constant, this is because the keys are hashed together with their type, and so hashes always us up 32 bytes rather than a linear amount of bytes, like this one right here that I'm typing up. Pretty cool right? I think so for sure. I am going to type a ton of text here, but nonetheless I believe the gas cost will be roughly constant, this is because the keys are hashed together with their type, and so hashes always us up 32 bytes rather than a linear amount of bytes, like this one right here that I'm typing up. Pretty cool right? I think so for sure. I am going to type a ton of text here, but nonetheless I believe the gas cost will be roughly constant, this is because the keys are hashed together with their type, and so hashes always us up 32 bytes rather than a linear amount of bytes, like this one right here that I'm typing up. Pretty cool right? I think so for sure. I am going to type a ton of text here, but nonetheless I believe the gas cost will be roughly constant, this is because the keys are hashed together with their type, and so hashes always us up 32 bytes rather than a linear amount of bytes, like this one right here that I'm typing up. Pretty cool right? I think so for sure.";
        dynamic_field::add(&mut object.id, key, 9);
    }

    public entry fun short_key(object: &mut Object) {
        let key = 3;
        dynamic_field::add(&mut object.id, key, 9);
    }
}