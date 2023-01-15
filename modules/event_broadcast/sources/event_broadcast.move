module sui_playground::event_broadcast {
    use std::string::{Self, String};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};

    struct MyEvent has copy, drop {
        text: String
    }

    struct MyStore has key {
        id: UID,
        text: String
    }

    public entry fun broadcast(message: vector<u8>) {
        let text = string::utf8(message);
        event::emit(
            MyEvent { text }
        );
    }

    public entry fun store(message: vector<u8>, ctx: &mut TxContext) {
        let text = string::utf8(message);
        transfer::transfer(MyStore { id: object::new(ctx), text }, tx_context::sender(ctx));
    }
}