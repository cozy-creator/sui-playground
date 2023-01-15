module sui_playground::outlaw_sky {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui_playground::capsule;
    use sui_playground::royalty_market::Royalty_Market;

    // Error constants
    const ENOT_OWNER: u64 = 0;

    // Genesis-witness and witness
    struct OUTLAW_SKY has drop {}
    struct Outlaw_Sky has drop {}

    struct Outlaw has key, store {
        id: UID
    }

    public fun craft_outlaw(ctx: &mut TxContext) {
        let outlaw = Outlaw { id: object::new(ctx) };

        capsule::create_<Outlaw_Sky, Royalty_Market, Outlaw>(
            Outlaw_Sky {}, outlaw, tx_context::sender(ctx), ctx);
    }

    public fun extend<T: store>(outlaw: &mut Outlaw): (&mut UID) {
        &mut outlaw.id
    }
}

module sui_playground::capsule {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui_playground::ownership::{Self};
    use sui_playground::module_authority;

    const ENOT_OWNER: u64 = 0;

    struct Capsule<T> has key, store {
        id: UID,
        contents: T
    }

    public fun create<T: store>(id: UID, contents: T) {
        transfer::share_object(Capsule { id, contents });
    }

    public fun create_<World: drop, Transfer: drop, T: store>(
        witness: World,
        contents: T,
        owner: address,
        ctx: &mut TxContext
    ) {
        let id = object::new(ctx);

        module_authority::bind<World>(&mut id);
        let witness = ownership::bind_owner(witness, &mut id, owner);
        ownership::bind_transfer_authority<World, Transfer>(witness, &mut id, ctx);

        create(id, contents);
    }

    public fun open<T: store>(capsule: &mut Capsule<T>, ctx: &TxContext): (&mut UID, &mut T) {
        assert!(ownership::is_valid_owner(&capsule.id, tx_context::sender(ctx)), ENOT_OWNER);

        (&mut capsule.id, &mut capsule.contents)
    }

    // When Sui supports optional reference arguments, we might be able to cobine open and open_
    // into one function.
    // Note that if the caller wants to use capsule.id as an owner, they should call into
    // `owner::borrow_ownership()` to change the owner from their auth-object ID to the address
    // calling into the function
    public fun open_<T: store, Object: key>(capsule: &mut Capsule<T>, auth: &Object): (&mut UID, &mut T) {
        assert!(ownership::is_valid_owner_(&capsule.id, auth), ENOT_OWNER);

        (&mut capsule.id, &mut capsule.contents)
    }

    // Perhaps we can add an open_and_own function as well? Might be 

    public fun extend<T: store>(capsule: &mut Capsule<T>): (&mut UID) {
        &mut capsule.id
    }
}

module sui_playground::module_authority {
    use std::string::String;
    use std::option::{Self, Option};
    use sui::object::UID;
    use sui::dynamic_field;
    use noot_utils::encode;
    
    // Error constants
    const ENO_AUTHORITY: u64 = 0;

    struct Key has store, copy, drop {}

    // Note that modules can bind authority to a witness type without actually being able to produce
    // that witness type; this effectively allows modules to create objects, and then 'delegate' the
    // authority of that object to another module entirely 
    public fun bind<World: drop>(id: &mut UID) {
        dynamic_field::add(id, Key {}, encode::type_name<World>());
    }

    public fun unbind<World: drop>(_witness: World, id: &mut UID) {
        assert!(is_valid<World>(id), ENO_AUTHORITY);
        dynamic_field::remove<Key, String>(id, Key {});
    }

    public fun into_module_type(id: &UID): Option<String> {
        if (dynamic_field::exists_(id, Key {})) {
            option::some(*dynamic_field::borrow<Key, String>(id, Key {}))
        } else {
            option::none()
        }
    }

    // Returns false if no module is bound
    public fun is_valid<World: drop>(id: &UID): bool {
        let module_maybe = into_module_type(id);

        if (option::is_none(&module_maybe)) { 
            false
        } else {
            encode::type_name<World>() == option::destroy_some(module_maybe)
        }
    }
}

module sui_playground::ownership {
    use std::option::{Self, Option};
    use std::string::String;
    use sui::object::{Self, ID, UID};
    use sui::dynamic_field;
    use sui::tx_context::{Self, TxContext};
    use sui_playground::module_authority;
    use noot_utils::encode;

    // error enums
    const ENO_MODULE_AUTHORITY: u64 = 0;
    const ENOT_OWNER: u64 = 1;
    const EOWNER_ALREADY_SET: u64 = 2;
    const ENO_TRANSFER_AUTHORITY: u64 = 3;
    const EMISMATCHED_HOT_POTATO: u64 = 4;

    struct Key has store, copy, drop { slot: u8 }

    // Slots for Key
    const OWNER: u8 = 1; // address
    const TRANSFER: u8 = 0; // string referencing a witness type

    // Used to borrow and return ownership. capsule_id ensures you cannot mismatch HotPotato's
    // and capsules, and obj_addr is the address of the original authority object
    struct HotPotato { 
        capsule_id: ID, 
        original_addr: Option<address> 
    }

    // ======= Ownership Authority =======

    // Bind ownership to an arbitrary address
    // Requires module authority. Only works if no owner is currently set
    public fun bind_owner<World: drop>(witness: World, id: &mut UID, addr: address): World {
        assert!(module_authority::is_valid<World>(id), ENO_MODULE_AUTHORITY);
        assert!(!dynamic_field::exists_(id, Key { slot: OWNER }), EOWNER_ALREADY_SET);

        dynamic_field::add(id, Key { slot: OWNER}, addr);

        witness
    }

    // Bind ownership to an arbitrary authority object
    public fun bind_owner_<World: drop, Object: key>(witness: World, id: &mut UID, auth: &Object): World {
        bind_owner(witness, id, object::id_address(auth))
    }

    // Takes a capsule id, and if the authority object is valid, it changes the owner to be the
    // sender of this transaction. Returns a hot potato to make sure the ownership is set back to
    // the original authority object by calling `return_ownership()`
    public fun borrow_ownership<Object: key>(id: &mut UID, auth: &Object, ctx: &TxContext): HotPotato {
        assert!(is_valid_owner_(id, auth), ENOT_OWNER);

        let key = Key { slot: OWNER };

        let original_addr = if (dynamic_field::exists_(id, key)) {
            option::some(dynamic_field::remove<Key, address>(id, key))
        } else { 
            option::none()
        };

        dynamic_field::add(id, key, tx_context::sender(ctx));

        HotPotato { 
            capsule_id: object::uid_to_inner(id),
            original_addr
        }
    }

    public fun return_ownership(id: &mut UID, hot_potato: HotPotato) {
        let HotPotato { capsule_id, original_addr } = hot_potato;

        assert!(object::uid_to_inner(id) == capsule_id, EMISMATCHED_HOT_POTATO);

        if (option::is_some(&original_addr)) {
            let addr = option::destroy_some(original_addr);
            *dynamic_field::borrow_mut<Key, address>(id, Key { slot: OWNER }) = addr;
        } else {
            dynamic_field::remove<Key, address>(id, Key { slot: OWNER});
        };
    }

    public fun into_owner_address(id: &UID): Option<address> {
        if (dynamic_field::exists_(id, Key { slot: OWNER })) {
            option::some(*dynamic_field::borrow(id, Key { slot: OWNER}))
        } else {
            option::none()
        }
    }

    public fun is_valid_owner(id: &UID, addr: address): bool {
        if (!dynamic_field::exists_(id, Key { slot: OWNER})) { 
            return true 
        };

        addr == *dynamic_field::borrow<Key, address>(id, Key { slot: OWNER })
    }

    public fun is_valid_owner_<Object: key>(id: &UID, auth: &Object): bool {
        let addr = object::id_address(auth);
        is_valid_owner(id, addr)
    }

    // ======= Transfer Authority =======

    // Requires module authority.
    // Requires owner authority if a transfer authority is already set
    public fun bind_transfer_authority<World: drop, Transfer: drop>(
        witness: World,
        id: &mut UID,
        ctx: &TxContext
    ): World {
        let witness = unbind_transfer_authority(witness, id, ctx);
        let transfer_witness = encode::type_name<Transfer>();

        dynamic_field::add(id, Key { slot: TRANSFER }, transfer_witness);

        witness
    }

    // Requires both module and owner authority
    public fun unbind_transfer_authority<World: drop>(
        witness: World,
        id: &mut UID,
        ctx: &TxContext
    ): World {
        assert!(module_authority::is_valid<World>(id), ENO_MODULE_AUTHORITY);

        if (dynamic_field::exists_with_type<Key, String>(id, Key { slot: TRANSFER })) {
            assert!(is_valid_owner(id, tx_context::sender(ctx)), ENOT_OWNER);

            dynamic_field::remove<Key, String>(id, Key { slot: TRANSFER });
        };

        witness
    }

    public fun into_transfer_type(id: &UID): Option<String> {
        let key = Key { slot: TRANSFER };

        if (dynamic_field::exists_with_type<Key, String>(id, key)) {
            option::some(*dynamic_field::borrow<Key, String>(id, key))
        }
        else {
           option::none()
        }
    }

    // If there is no transfer module set, then transfers are not allowed
    public fun is_valid_transfer_authority<Transfer: drop>(id: &UID): bool {
        let key = Key { slot: TRANSFER };

        if (!dynamic_field::exists_with_type<Key, String>(id, key)) {
            false 
        } else {
            encode::type_name<Transfer>() == *dynamic_field::borrow<Key, String>(id, key)
        }
    }

    // Requires transfer authority.
    // Does NOT require ownership authority or module authority; meaning the delegated transfer module
    // can transfer arbitrarily, without the owner being the sender of the transaction. This is useful for
    // marketplace sales, reclaimers, and collateral-repossession
    public fun transfer<Transfer: drop>(witness: Transfer, id: &mut UID, new_owner: address): Transfer {
        assert!(is_valid_transfer_authority<Transfer>(id), ENO_TRANSFER_AUTHORITY);

        let owner = dynamic_field::borrow_mut<Key, address>(id, Key { slot: OWNER });
        *owner = new_owner;

        witness
    }
}

module sui_playground::royalty_market {

    // witness
    struct Royalty_Market has drop {}
}
