// Currently, this stores metadata as raw-bytes. For example, a ascii::String will simply be stored as bytes, rather than
// a type. Should we change this, and store the actual objects instead? It might be more useful for on-chain programs trying to
// read values, or for explorers examining dynamic fields.
//
// Additionally we are storing each schema as a root-level immutable object. Inside of each object we are merely storing the ID
// of that object, rather than the object itself. Perhaps we should store the schema itself inside the object?

module sui_playground::metadata {
    use std::ascii;
    use std::string;
    use std::option;
    use std::vector;
    use sui::dynamic_field;
    use sui::object::{Self, UID, ID};
    use sui_playground::schema::{Self, Schema};

    // Error enums
    const EINCORRECT_DATA_LENGTH: u64 = 0;
    const ESCHEMA_VIOLATED: u64 = 1;
    const EREQUIRED_TYPE_MISSING: u64 = 2;
    const EMISSING_OPTION_BYTE: u64 = 3;

    /// Address length in Sui is 20 bytes.
    const SUI_ADDRESS_LENGTH: u64 = 20;

    struct SchemaID has store, copy, drop { }
    struct Key has store, copy, drop { slot: ascii::String }

    // Schema = vector<ascii::String> = [slot_name, slot_type, optional]
    // for example: "age", "u8", "0", where 0 = required, 1 = optional
    // That is, Schema is a vector with 3 items per item in the schema
    public fun add(id: &mut UID, schema_: &Schema, data: vector<vector<u8>>) {
        let schema = schema::get(schema_);
        assert!(vector::length(&schema) == vector::length(&data), EINCORRECT_DATA_LENGTH);

        let i = 0;
        while (i < vector::length(&schema)) {
            let item = vector::borrow(&schema, i);
            let (key, type, optional) = schema::item(item);
            let value = *vector::borrow(&data, i);

            // All optional items must be prepended with an option byte, otherwise an abort will occur
            if (optional) {
                if (is_some(value)) {
                    vector::remove(&mut value, 0); // remove the optional-byte
                } else {
                    i = i + 1;
                    continue
                }
            };

            assert!(is_correct_type(type, value), ESCHEMA_VIOLATED);
            
            dynamic_field::add(id, Key { slot: key }, value );
            i = i + 1;
        };

        dynamic_field::add(id, SchemaID { }, object::id(schema_));
    }

    // ============= devInspect Functions ============= 

    // convenience function so you can supply ascii-bytes rather than ascii types
    public fun view(id: &UID, keys: vector<vector<u8>>): (vector<vector<u8>>, ID) {
        let (ascii_keys, i) = (vector::empty<ascii::String>(), 0);
        while (i < vector::length(&keys)) {
            vector::push_back(&mut ascii_keys, ascii::string(*vector::borrow(&keys, i)));
            i = i + 1;
        };
        view_(id, ascii_keys)
    }

    // This prepends every item with an option byte: 1 (exists) or 0 (doesn't exist)
    // The response we're turning is just raw bytes; it's up to the client app to figure out what the value-types should be,
    // which is why we provide an ID for the object's schema, which is needed in order to deserialize the bytes.
    // Perhaps there is a more convenient way to do this for the client?
    public fun view_(id: &UID, keys: vector<ascii::String>): (vector<vector<u8>>, ID) {
        let (i, response) = (0, vector::empty<vector<u8>>());

        while (i < vector::length(&keys)) {
            let slot = *vector::borrow(&keys, i);
            if (dynamic_field::exists_(id, Key { slot })) {
                let bytes = *dynamic_field::borrow<Key, vector<u8>>(id, Key { slot });
                // Devnet doesn't have this function yet
                // vector::insert(&mut bytes, 1u8, 0);
                vector::reverse(&mut bytes);
                vector::push_back(&mut bytes, 1u8);
                vector::reverse(&mut bytes);
                // So we use these three ugly lines instead for now ^^^
                vector::push_back(&mut response, bytes);
            } else {
                vector::push_back(&mut response, vector[0u8]);
            };
            i = i + 1;
        };

        let schema_id = *dynamic_field::borrow<SchemaID, ID>(id, SchemaID { } );
        (response, schema_id)
    }

    // The schema you supply is not necessarily compatible with the Schema this object is using, for example,
    // "url" could be ascii::String in your supplied schema, but string::String in this object's schema
    // Maybe we could add some type coercian or abort if that's not possible?
    public fun view_all(id: &UID, reader_schema_: &Schema): (vector<vector<u8>>, ID) {
        let (reader_schema, i, keys) = (schema::get(reader_schema_), 0, vector::empty<ascii::String>());

        while (i < vector::length(&reader_schema)) {
            let (key, _, _) = schema::item(vector::borrow(&reader_schema, i));
            vector::push_back(&mut keys, key);
            i = i + 1;
        };
        view_(id, keys)
    }

    // ============ Input Validation ============ 

    // BCS serialization for optionals:
    // option::some<u8>() = [1,(8 bytes)]
    // option::none<anything>() = [0]
    // Options prepend a single byte, which is either 0 or 1.
    // Meaning option::some<u64>() has an extra preceeding byte compared to just u64
    // If you are passing in non-optional bytes, such as just u64, rather than Option<u64>, this function will probably abort
    public fun is_some(bytes: vector<u8>): bool {
        let first_byte = *vector::borrow(&bytes, 0);

        if (first_byte == 1) {
            true
        } else if (first_byte == 0) {
            false
        } else {
            abort EMISSING_OPTION_BYTE
        }
    }

    // Validate that the data type is correct. Do not use with optionals; this assumes option::some()
    // Currently supported types: address, bool, u8, u64, u128
    // To support: ascii::String, string::String (utf8), u32, u256, ObjectID, vector<everything>
    public fun is_correct_type(type: ascii::String, bytes: vector<u8>): bool {
        let length = vector::length(&bytes);

        if (type == ascii::string(b"address")) {
            if (length != SUI_ADDRESS_LENGTH) false
            else true
        } else if (type == ascii::string(b"bool")) {
            if (length != 1) return false;
            let value = *vector::borrow(&bytes, 0);
            if (value == 0 || value == 1) true
            else false
        } else if (type == ascii::string(b"u8")) {
            if (length != 1) false
            else true
        } else if (type == ascii::string(b"u64")) {
            if (length != 8) false
            else true
        } else if (type == ascii::string(b"u128")) {
            if (length != 16) false
            else true
        } else if (type == ascii::string(b"0x1::string::String")) {
            let maybe_string = string::try_utf8(bytes);
            if (option::is_some(&maybe_string)) true
            else false
        } else {
            false
        }
    }
}