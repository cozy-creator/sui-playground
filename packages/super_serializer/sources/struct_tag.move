module sui_playground::struct_tag {
    use std::ascii::String;
    use sui::object::ID;

    struct StructTag has store, copy, drop {
        address: ID,
        module_name: String,
        name: String,
        type_params: vector<String>,
    }
}