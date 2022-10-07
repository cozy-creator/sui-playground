module openrails::post_simple {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string;
    use std::vector;

    const ENOT_AUTHORIZED: u64 = 0;

    // We can't a post as being authored by you if it is stored in your account
    // To prevent polymorphic transfer, we avoid using store here
    struct Post has key {
        id: UID,
        body: string::String
    }

    // Shared Object
    struct DelegatedPosters has key {
        for: address,
        posters: vector<address>
    }

    public entry fun post(body_bytes: vector<u8>, ctx: &mut TxContext) {
        let post = post_(body_bytes, ctx);
        transfer::transfer(post, tx_context::sender(ctx));
    }

    public fun post_(body_bytes: vector<u8>, ctx: &mut TxContext): Post {
        let body = string::utf8(body_bytes);

        Post {
            id: object::new(ctx),
            body
        }
    }

    // Delegated Posters is a shared object
    public fun post_delegated(delegated_posters: &DelegatedPosters, body_bytes: vector<u8>, ctx: &mut TxContext) {
        let sender_addr = tx_context::sender(ctx);
        assert!(vector::contains(&delegated_posters.posters, &sender_addr), ENOT_AUTHORIZED);
        let post = post_(body_bytes, ctx);
        transfer::transfer(post, delegated_posters.for);
    }

    public entry fun create_delegation() {
        
    }

    public entry fun add_delegate() {

    }

    public entry fun remove_delegate() {

    }
}