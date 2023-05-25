module sui_playground::bcs_gas_benchmark {
    use std::ascii;
    use std::string;
    use std::vector;
    use sui::bcs;
    use sui_utils::bcs2;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field;
    use sui::object::{Self, UID};

    public entry fun bcs_deserialize(data: vector<u8>, length: u64) {
        let bcs = bcs::new(data);
        let i = 0;
        while (i < length) {
            let _string = bcs2::peel_ascii(&mut bcs);
            i = i + 1;
        };
    }

    public entry fun parsed_deserialize(data: vector<vector<u8>>) {
        let i = 0;
        while (i < vector::length(&data)) {
            let _string = peel_ascii(*vector::borrow(&data, i));
            i = i + 1;
        };
    }

    public entry fun parsed_utf8(data: vector<vector<u8>>) {
        let i = 0;
        while (i < vector::length(&data)) {
            let _string = peel_utf8(*vector::borrow(&data, i));
            i = i + 1;
        };
    }

    public fun peel_ascii(data: vector<u8>): ascii::String {
        ascii::string(data)
    }

    public fun peel_utf8(data: vector<u8>): string::String {
        string::utf8(data)
    }

    public entry fun free_ascii(_data: vector<ascii::String>) {
    }

    public entry fun free_utf8(_data: vector<string::String>) {
    }

    struct Object has key {
        id: UID
    }

    struct Key has store, copy, drop { slot: u8 }

    public entry fun dynamic_field_1(num: u8, ctx: &mut TxContext) {
        let object = Object { id: object::new(ctx) };
        let i = 0u8;
        while (i < num) {
            dynamic_field::add(&mut object.id, i, true);
            let _ = dynamic_field::borrow<u8, bool>(&object.id, i);
            i = i + 1;
        };
        transfer::transfer(object, tx_context::sender(ctx));
    }

    public entry fun dynamic_field_2(num: u8, ctx: &mut TxContext) {
        let object = Object { id: object::new(ctx) };
        let i = 0u8;
        while (i < num) {
            dynamic_field::add(&mut object.id, Key { slot: i }, true);
            let _ = dynamic_field::borrow<Key, bool>(&object.id, Key { slot: i });
            i = i + 1;
        };
        transfer::transfer(object, tx_context::sender(ctx));
    }
}

#[test_only]
module sui_playground::test {
    use std::type_name;
    use std::debug;

    #[test]
    public fun type_name_for_primitives() {
        let type1 = type_name::get<u64>();
        let type2 = type_name::get<address>();
        let type3 = type_name::get<bool>();

        debug::print(&type1);
        debug::print(&type2);
        debug::print(&type3);
    }
}