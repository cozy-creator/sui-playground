module sui_playground::comparison {
    use std::string::{Self, String};
    use std::option::Option;

    struct Compare has store, copy, drop {
        a: String,
        b: u64,
        c: Option<u8>
    }

    public fun create(a: vector<u8>, b: u64, c: Option<u8>): Compare {
        Compare {
            a: string::utf8(a), 
            b, c
        }
    }
}

#[test_only]
module sui_playground::test_comparison {
    use sui_playground::comparison;
    use std::debug;
    use std::option;
    // use sui::test_scenario;
    
    #[test]
    public fun test() {
        let g = comparison::create(b"Monkey", 19, option::none<u8>());
        let f = comparison::create(b"Monkey", 19, option::none<u8>());
        debug::print(&(g == f)); // true

        let g = comparison::create(b"Monkey", 19, option::none<u8>());
        let f = comparison::create(b"Monkey", 17, option::none<u8>());
        debug::print(&(g == f)); // false

        let g = comparison::create(b"Monkey", 19, option::none<u8>());
        let f = comparison::create(b"Donkey Kong", 19, option::none<u8>());
        debug::print(&(g == f)); // false

        let g = comparison::create(b"Monkey", 19, option::none<u8>());
        let f = comparison::create(b"Monkey", 19, option::some(99u8));
        debug::print(&(g == f)); // false
    }
}