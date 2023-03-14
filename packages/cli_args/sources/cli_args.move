module sui_playground::cli_args {
    use std::vector;
    use sui_utils::deserialize;

    // Expected format is [ [u8], [u64] ]
    public entry fun simple(data: vector<vector<u8>>) {
        let _value1 = deserialize::u8_(*vector::borrow(&data, 0));
        let _value2 = deserialize::u64_(*vector::borrow(&data, 1));
    }

    public entry fun nested_string(data: vector<vector<u8>>) {
        let first_strings = *vector::borrow(&data, 0);
        let _strings = deserialize::vec_string(first_strings);
    }
}