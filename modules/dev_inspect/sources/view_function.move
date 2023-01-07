module sui_playground::view_function {
    use std::ascii::String;
    use sui::object::ID;

    // root-level object (owned or shared)
    struct Rick {
        name: String,
        universe: u64,
        age: u16,
        morty: ID
    }

    struct Result {
        universe: u64,
        morty: ID
    }

    // Here we specify a Schema type, like 0x77::metadata::ERC721
    // 
    // public fun get_view<Schema: drop>(rick: &Rick, ): Result {
    //     let schema = metadata::create<Schema>()
    // }

    // public fun get_view<Schema: drop>(rick: &Rick, schema: String): Result {
    //     let schema = metadata::create<Schema>();
    // }
}