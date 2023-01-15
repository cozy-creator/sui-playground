module sui_playground::rick {
    use std::bcs;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui_playground::metadata;
    use sui_playground::schema::{Self, Schema};

    struct Rick has key {
        id: UID
        // name -> utf8 String
        // age -> u8
        // universe -> u64
        // morty -> Option<u128>
    }

    public entry fun create_rick(schema: &Schema, ctx: &mut TxContext) {
        let rick = Rick {
            id: object::new(ctx)
        };

        let data = vector[b"Rick Sanchez", bcs::to_bytes(&70u8), bcs::to_bytes(&1377), vector[0u8]];
        metadata::add(&mut rick.id, schema, data);

        transfer::transfer(rick, tx_context::sender(ctx));
    }

    // We need to use this until more generic options are available, and clients call call metadata::view_all directly
    public fun view(rick: &Rick, schema_: &Schema): (vector<vector<u8>>, ID) {
        metadata::view_all(&rick.id, schema_)
    }

    fun init(ctx: &mut TxContext) {
        let keys = vector[b"name", b"age", b"universe", b"morty"];
        let types = vector[b"0x1::string::String", b"u8", b"u64", b"u128"];
        let optionals = vector[false, false, false, true];
        schema::create(keys, types, optionals, ctx);
    }
}

#[test_only]
module sui_playground::test_rick {
    use sui::test_scenario;
    use sui_playground::rick;
    use sui_playground::schema;

    #[test]
    public fun test_this() {

        let scenario = test_scenario::begin(@0x599);
        {
            let keys = vector[b"name", b"age", b"universe", b"morty"];
            let types = vector[b"0x1::string::String", b"u8", b"u64", b"u128"];
            let optionals = vector[false, false, false, true];
            schema::create(keys, types, optionals, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, @0x599);
        // let frozen = test_scenario::frozen(&tx_effects);
        let schema = test_scenario::take_immutable(&scenario);
        {
            rick::create_rick(&schema, test_scenario::ctx(&mut scenario));
        };

        test_scenario::return_immutable(schema);
        test_scenario::end(scenario);
    }
}