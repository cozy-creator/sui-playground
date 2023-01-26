module sui_playground::vector_gas_benchmark {
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};
    use sui::transfer;
    use sui_utils::vector2;

    struct Print has key {
        id: UID,
        slice: vector<u8>,
        remainder: vector<u8>
    }

    const TEST_VEC: vector<u8> = vector[7, 5, 101, 109, 112, 116, 121, 9, 122, 101, 114, 111, 32, 119, 111, 114, 100,  10, 102, 105, 114, 115, 116,  32, 119, 111, 114, 100, 15, 255, 254, 253, 252,  251, 250, 104, 105, 115,  32, 119, 111, 114, 107, 115,  19, 108,  97, 114, 103, 101, 32,  99, 104,  97, 114,  97,  99, 116, 101, 114, 32, 115, 101, 116,  11,  97, 110, 111, 116, 104, 101, 114, 32, 111, 110, 101,   9, 109, 111, 114, 101,  32, 109, 111, 114, 101, 7, 5, 101, 109, 112, 116, 121, 9, 122, 101, 114, 111, 32, 119, 111, 114, 100,  10, 102, 105, 114, 115, 116,  32, 119, 111, 114, 100,  15, 104, 111, 112, 101,  32, 116, 104, 105, 115,  32, 119, 111, 114, 107, 115,  19, 108,  97, 114, 103, 101,  32,  99, 104,  97, 114,  97, 99, 116, 101, 114, 32, 115, 101, 116,  11,  97, 110, 111, 116, 104, 101, 114, 32, 111, 110, 101,   9, 109, 111, 114, 101,  32, 109, 111, 114, 101];

    public entry fun slice1(ctx: &mut TxContext) {
        let sample = TEST_VEC;
        let slice = vector2::slice_mut(&mut sample, 3, 29);

        transfer::share_object(Print {
            id: object::new(ctx),
            slice,
            remainder: sample
        });
    }

    public entry fun slice2(ctx: &mut TxContext) {
        let sample = TEST_VEC;
        let slice = vector2::slice_mut2(&mut sample, 3, 29);

        transfer::share_object(Print {
            id: object::new(ctx),
            slice,
            remainder: sample
        });
    }
}