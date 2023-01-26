module sui_playground::bcs_maybe {
    use std::string::String;
    use sui::bcs;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui_utils::bcs2;

    struct Storage has key {
        id: UID,
        strings: vector<String>
    }

    struct Storage2 has key {
        id: UID,
        len1: u64,
        str: String,
        data: vector<u8>
    }

    // Improving vector2::slice_mut reduced gas from 7,000 nanoSUI to 3,500 nanoSUI
    // bcs_strings is assumed to be an array of utf8 strings
    public entry fun give_bcs(bcs_strings: vector<u8>, ctx: &mut TxContext) {
        let bcs = bcs::new(bcs_strings);
        let (strings, _) = bcs2::peel_vec_utf8(bcs);

        transfer::transfer(Storage { id: object::new(ctx), strings }, tx_context::sender(ctx));
    }

    public entry fun store_bytes(data: vector<u8>, ctx: &mut TxContext) {
        let bcs = bcs::new(data);
        let len1 = bcs::peel_vec_length(&mut bcs);
        let (str, bcs) = bcs2::peel_utf8(bcs);
        transfer::transfer(Storage2 { id: object::new(ctx), len1, str, data: bcs::into_remainder_bytes(bcs) }, tx_context::sender(ctx));
    }
}