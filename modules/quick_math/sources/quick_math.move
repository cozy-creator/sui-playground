module sui_playground::quick_math {

    const SOMETHING: u64 = 69;

    public fun modulo(number: u64): u64 {
        number % 5
    }

    public fun fail() {
        abort(SOMETHING)
    }

    #[test]
    public fun test1() {
        use sui::test_scenario;
        use std::debug;
        
        let scenario = test_scenario::begin(@55);
        let _ctx = test_scenario::ctx(&mut scenario);
        {
            // 000000101
            let x: u8 = 3;
            let y: u8 = 4;
            debug::print(&(x | y));
        };
        test_scenario::end(scenario);
    }
}

#[test_only]
module sui_playground::import_constant {
    use sui_playground::quick_math;

    #[test]
    #[expected_failure(abort_code = quick_math::SOMETHING)]
    public fun test2() {
        use sui::test_scenario;

        let scenario = test_scenario::begin(@55);
        let _ctx = test_scenario::ctx(&mut scenario);
        {
            quick_math::fail();
        };
        test_scenario::end(scenario);
    }
}