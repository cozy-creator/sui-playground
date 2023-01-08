// may bring this back at some point

module sui_playground::retired {

    // Validate that the data type is correct. Do not use with optionals; this assumes option::some()
    // Currently supported types: address, bool, u8, u64, u128
    // To support: u32, u256, vector<everything>
    // public fun is_correct_type(type: ascii::String, bytes: vector<u8>): bool {
    //     let length = vector::length(&bytes);
    //
    //     if (type == ascii::string(b"address") || type == ascii::string(b"ID")) {
    //         if (length == SUI_ADDRESS_LENGTH) true
    //         else false
    //     } else if (type == ascii::string(b"bool")) {
    //         if (length != 1) return false;
    //         let value = *vector::borrow(&bytes, 0);
    //         if (value == 0 || value == 1) true
    //         else false
    //     } else if (type == ascii::string(b"u8")) {
    //         if (length == 1) true
    //         else false
    //     } else if (type == ascii::string(b"u64")) {
    //         if (length == 8) true
    //         else false
    //     } else if (type == ascii::string(b"u128")) {
    //         if (length == 16) true
    //         else false
    //     } else if (type == ascii::string(b"0x1::string::String")) {
    //         let maybe_string = string::try_utf8(bytes);
    //         if (option::is_some(&maybe_string)) true
    //         else false
    //     } else if (type == ascii::string(b"0x1::ascii::String")) {
    //         let string_maybe = ascii::try_string(bytes);
    //         if (option::is_some(&string_maybe)) true
    //         else false
    //     } else if (type == ascii::string(b"vector<bool>")) {
    //         true
    //     } else {
    //         false
    //     }
    // }
}