// module pauls_package::cat_hat {
//     use sui::object::{Self, Info};
//     use sui::tx_context::{Self, TxContext};
//     use sui::transfer;
//     use sui::utf8;

//     struct CatHat has key, store {
//         info: Info,
//         catchphrase: utf8::String
//     }

//     public entry fun create(catchphrase: vector<u8>, ctx: &mut TxContext) {
//         let hat = CatHat {
//             info: object::new(ctx),
//             catchphrase: utf8::string_unsafe(catchphrase)
//         };
//         transfer::transfer(hat, tx_context::sender(ctx));
//     }

//     public fun call(hat: &CatHat): utf8::String {
//         hat.catchphrase
//     }
// }

// module pauls_package::capability_test {
//     use sui::object::{Self, ID, Info};
//     use sui::tx_context::{Self, TxContext};
//     use sui::transfer;
//     use std::option::{Self, Option};

//     const ENotPermitted: u64 = 1;

//     struct PermissionWrapper<T: key + store> has key, store {
//         info: Info,
//         owner: address,
//         who_can_use: address,
//         item: Option<T>
//     }

//     struct HotPotato {
//         /// ID of the wrapper from which it was taken
//         wrapper_id: ID,
//         // ID of the original item, so it can't be swapped with another item of the same type
//         item_id: ID
//     }

//     public entry fun wrap_item<T: key + store>(item: T, who_can_use: address, ctx: &mut TxContext) {
//         let wrapped_item = PermissionWrapper<T> {
//             info: object::new(ctx),
//             owner: tx_context::sender(ctx),
//             who_can_use,
//             item: option::some(item)
//         };
//         transfer::share_object(wrapped_item);
//     }

//     public fun unwrap_item<T: key + store>(wrapped_item: &mut PermissionWrapper<T>, ctx: &mut TxContext): (T, HotPotato) {
//         assert!(tx_context::sender(ctx) == wrapped_item.who_can_use, ENotPermitted);
//         let item = option::extract<T>(&mut wrapped_item.item);
//         let potato = HotPotato { wrapper_id: *object::id<T>(wrapped_item), item_id: *object::id<T>(item) };
//         (item, potato)
//     }

//     public fun return_item<T: key + store>(wrapper: &mut PermissionWrapper<T>, item: T, potato: HotPotato) {
//         let HotPotato { wrapper_id, item_id } = potato;
//         assert!(object::id(wrapper) == &wrapper_id, ENotPermitted);
//         assert!(object::id<T>(item) == &item_id, ENotPermitted);

//         wrapper.item = option::some<T>(item);
//     }

//     public entry fun remove_item<T: key + store>(wrapped_item: PermissionWrapper<T>, ctx: &mut TxContext) {
//         assert!(tx_context::sender(ctx) == wrapped_item.owner, ENotPermitted);
//         let PermissionWrapper { _i, owner, _w, item} = wrapped_item;
//         transfer::transfer(item, owner);
//     }
// }

// #[test_only]
// module pauls_package::tests2 {
//     use sui::test_scenario;
//     // use sui::object;
//     use sui::tx_context;
//     use sui::transfer;
//     use pauls_package::capability_test::{Self, PermissionWrapper};
//     use pauls_package::cat_hat;

//     #[test]
//     fun test_create() {
//         let owner = @0x1;
//         let borrower = @0x2;

//         // Create a cathat and transfer it to @owner.
//         let scenario = &mut test_scenario::begin(&owner);
//         {
//             let ctx = test_scenario::ctx(scenario);
//             cat_hat::create(b"Hey there buddy", ctx);
//             let hat = test_scenario::take_owned<cat_hat::CatHat>(scenario);
//             capability_test::wrap_item(hat, borrower, ctx);
//         };

//         // Check that @not_owner does not own the just-created ColorObject.
//         test_scenario::next_tx(scenario, &other_person);
//         {
//             // assert!(!test_scenario::can_take_owned<Sword>(scenario), 0);
//         };

//         // Check that @owner indeed owns the just-created ColorObject.
//         // Also checks the value fields of the object.
//         test_scenario::next_tx(scenario, &owner);
//         {
//             // let sword = test_scenario::take_owned<Sword>(scenario);
//             // let durability = m1::get_durability(&sword);
//             // assert!(durability == 15, 0);
//             // test_scenario::return_owned(scenario, sword);
//         };
//     }
// }