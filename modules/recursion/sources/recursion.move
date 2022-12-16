module sui_playground::recursion {
    use std::vector;
    use std::debug;

    #[test_only]
    use sui::test_scenario;

    public fun call_me(vec: vector<u8>) {
        if (vector::length(&vec) > 0) {
            debug::print(&vector::remove(&mut vec, 0));
            call_me(vec);
        };
    }

    #[test]
    public fun test_it() {
        let scenario = test_scenario::begin(@0x59);
        let _ctx = test_scenario::ctx(&mut scenario);
        {
            call_me(vector[15u8, 9u8, 17u8, 100u8]);
        };
        test_scenario::end(scenario);
    }
}