module openrails::post_for_me {
    use sui::object;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::vector;
    use std::string;

    const ENOT_AUTHORIZED: u64 = 1;

    struct Post has copy, store {
        message: string::String
    }

    struct PostList has key {
        id: object::UID,
        inner: vector<Post>
    }

    struct WriterCap has key, store {
        id: object::UID,
        owner: address,
        post_list_addr: address
    }

    struct OwnerCap has key, store {
        id: object::UID,
        post_list_addr: address
    }

    // TO DO: implement read functions as well

    public entry fun create_post_list(ctx: &mut TxContext) {
        let addr = tx_context::sender(ctx);
        let (owner_cap, writer_cap, post_list) = create_post_list_(ctx);
        transfer::transfer(owner_cap, addr);
        transfer::share_object(writer_cap);
        transfer::share_object(post_list);
    }

    public fun create_post_list_(ctx: &mut TxContext): (OwnerCap, WriterCap, PostList) {
        let post_list = PostList {
            id: object::new(ctx),
            inner: vector::empty<Post>()
        };

        let post_list_addr = object::uid_to_address(&post_list.id);

        let owner_cap = OwnerCap {
            id: object::new(ctx),
            post_list_addr
        };

        let writer_cap = WriterCap {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            post_list_addr
        };

        (owner_cap, writer_cap, post_list)
    }

    public entry fun post(message_bytes: vector<u8>, post_list: &mut PostList, writer_cap: &WriterCap, ctx: &mut TxContext) {
        assert!(writer_cap.post_list_addr == object::uid_to_address(&post_list.id), ENOT_AUTHORIZED);
        assert!(writer_cap.owner == tx_context::sender(ctx), ENOT_AUTHORIZED);

        let message = string::utf8(message_bytes);
        let post = Post { message };
        vector::push_back(&mut post_list.inner, post);
    }
    
    public entry fun create_writer_cap(receiver_addr: address, owner_cap: &OwnerCap, ctx: &mut TxContext) {
        let writer_cap = WriterCap {
            id: object::new(ctx),
            owner: receiver_addr,
            post_list_addr: owner_cap.post_list_addr
        };
        transfer::share_object(writer_cap);
    }

    // This won't actually work because writer_cap is a shared object, and hence cannot be passed in
    // by value, only by reference
    public entry fun delete_writer_cap(writer_cap: WriterCap, owner_cap: &OwnerCap, _ctx: &mut TxContext) {
        let WriterCap {id, owner: _, post_list_addr } = writer_cap;
        assert!(post_list_addr == owner_cap.post_list_addr, ENOT_AUTHORIZED);
        object::delete(id);
    }

    // These two are both optional
    public entry fun delete_writer_cap_(writer_cap: WriterCap, ctx: &mut TxContext) {
        let WriterCap { id, owner, post_list_addr: _ } = writer_cap;
        assert!(tx_context::sender(ctx) == owner, ENOT_AUTHORIZED);
        object::delete(id);
    }

    public entry fun transfer_writer_cap(new_owner: address, writer_cap: &mut WriterCap, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == writer_cap.owner, ENOT_AUTHORIZED);
        writer_cap.owner = new_owner;
    }

}


    // This is impossible; references cannot be stored
    // struct OptionWithReference<Element> has copy, drop, store {
    //     vec: &mut vector<Element>
    // }

    // This is impossible, because an option can never contain a reference, and a
    // shared object cannot be passed as owned, only passed as a reference
    // public fun post_with_optional_postlist(message_bytes: vector<u8>, list: &mut Option<&mut PostList>, ctx: &mut TxContext) {
    //     let message = string::utf8(message_bytes);
    //     let post = Post { message };

    //     if (option::is_some(list)) {
    //         let post_list = option::borrow_mut(list);
    //         assert!(post_cap.for == object::uid_to_address(&post_list.id), 0);
    //         vector::push_back(&mut post_list.inner, post);
    //     } else {
    //         let new_list = PostList {
    //             id: object::new(ctx),
    //             inner: vector::empty()
    //         };
    //         vector::push_back(&mut new_list.inner, post);
    //         transfer::share_object(new_list);
    //     };
    // }

#[test_only]
module openrails::post_for_me_test {
    use openrails::post_for_me::{Self, OwnerCap, PostList, WriterCap};
    use sui::test_scenario;

    #[test]
    public fun test_someone_else_posts() {
        let owner = @0x99;
        let writer = @0x420;

        let scenario = &mut test_scenario::begin(&owner);
        {
            post_for_me::create_post_list(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, &owner);
        {
            let owner_cap = test_scenario::take_owned<OwnerCap>(scenario);
            post_for_me::create_writer_cap(writer, &owner_cap, test_scenario::ctx(scenario));
            test_scenario::return_owned<OwnerCap>(scenario, owner_cap);
        };

        test_scenario::next_tx(scenario, &writer);
        {
            let writer_cap_wrapper = test_scenario::take_last_created_shared<WriterCap>(scenario);
            let post_list_wrapper = test_scenario::take_shared<PostList>(scenario);

            let writer_cap_ref = test_scenario::borrow_mut(&mut writer_cap_wrapper);
            let post_list_ref = test_scenario::borrow_mut(&mut post_list_wrapper);

            post_for_me::post(b"Hello World", post_list_ref, writer_cap_ref, test_scenario::ctx(scenario));

            test_scenario::return_shared(scenario, writer_cap_wrapper);
            test_scenario::return_shared(scenario, post_list_wrapper);
        }
    }
}