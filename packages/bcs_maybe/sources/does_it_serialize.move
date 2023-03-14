module sui_playground::does_it_serialize {
     #[test]
    public fun bcs_encoding() {
        let test_strings = vector[ascii::string(b"hello"), ascii::string(b"world")];

        let bytes = bcs::to_bytes(&test_strings);

        let i = 0;
        while (i < vector::length(&bytes)) {
            // debug::print(vector::borrow(&bytes, i));
            i = i + 1;
        };

        let vec = vec_map::empty();
        vec_map::insert(&mut vec, ascii::string(b"key1"), ascii::string(b"hello"));
        vec_map::insert(&mut vec, ascii::string(b"key2"), ascii::string(b"world"));

        let bytes = bcs::to_bytes(&vec);

        let i = 0;
        while (i < vector::length(&bytes)) {
            // debug::print(vector::borrow(&bytes, i));
            i = i + 1;
        };
    }

    struct Something has drop {
        elsie: Else
    }

    struct Else has drop {
        more: More,
        and: More
    }

    struct More has drop {
        stuff: u64,
        here: ascii::String
    }


    #[test]
    public fun nested_structs() {
        let something = Something {
            elsie: Else {
                more: More {
                    stuff: 42,
                    here: ascii::string(b"hello")
                },
                and: More {
                    stuff: 19,
                    here: ascii::string(b"world")
                }
            }
        };

        let bytes = bcs::to_bytes(&something);

        let i = 0;
        while (i < vector::length(&bytes)) {
            // debug::print(vector::borrow(&bytes, i));
            i = i + 1;
        };
    }
}