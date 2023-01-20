module sui_playground::vec_map {
    use std::string::{Self, String};
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::bcs;

    struct Holder has key {
        id: UID,
        inner: VecMap<String, String>
    }

    public entry fun create(ctx: &mut TxContext) {
        let holder = Holder {
            id: object::new(ctx),
            inner: vec_map::empty<String, String>()
        };
        let map = &mut holder.inner;

        vec_map::insert(map, string::utf8(b"name"), string::utf8(b"Paul Fidika"));
        vec_map::insert(map, string::utf8(b"age"), string::utf8(b"28"));
        vec_map::insert(map, string::utf8(b"gender"), string::utf8(b"male"));
        vec_map::insert(map, string::utf8(b"location"), string::utf8(b"Denver"));

        transfer::transfer(holder, tx_context::sender(ctx));
    }

    public fun view_bcs(holder: &Holder): vector<u8> {
        bcs::to_bytes(holder)
    }

    public fun view_ref(holder: &Holder): &VecMap<String, String> {
        &holder.inner
    }

    public fun view_value(holder: &Holder): VecMap<String, String> {
        holder.inner
    }

    public fun get_vec(): vector<u8> {
        let expecting = vector[b"123", b"456", b"123", b"456", b"123", b"456"];
        bcs::to_bytes(&expecting)
    }
}