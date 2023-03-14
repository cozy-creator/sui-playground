// This does not work; the object being frozen T must have key + store; if it has just
// key, it can only be frozen within the defining module!

// module sui_playground::my_stuff {
//     use sui::object::{Self, UID};
//     use sui::tx_context::{Self, TxContext};
//     use sui::transfer;

//     struct MyStuff has key, store {
//         id: UID
//     }

//     public entry fun create_one(ctx: &mut TxContext) {
//         let stuff = MyStuff { id: object::new(ctx) };
//         transfer::transfer(stuff, tx_context::sender(ctx));
//     }
// }

// module sui_playground::freeze_any {
//     use sui::transfer;

//     public entry fun freeze_any<T: key + store>(x: T) {
//         transfer::freeze_object(x);
//     }
// }