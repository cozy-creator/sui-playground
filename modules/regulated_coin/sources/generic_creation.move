// This code will not compile; this overloading behavior using types is not allowed

// module rc::generic_creation {
//     use sui::tx_context::{TxContext};
//     use sui::object::{Self, UID};

//     struct Dog has key {
//         id: UID,
//         age: u64
//     }

//     struct Cat has key {
//         id: UID,
//         lives: u128
//     }

//     public fun create_generic<T: key>(ctx: &mut TxContext): T {
//         let animal = new<T>(ctx);
//         animal
//     }

//     fun new<Dog>(ctx: &mut TxContext): Dog {
//         let dog = Dog { id: object::new(ctx), age: 1 };
//         dog
//     }

//     fun new<Cat>(ctx: &mut TxContext): Cat {
//         let cat = Cat { id: object::new(ctx), lives: 9 };
//         cat
//     }
// }