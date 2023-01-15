module ownership::ownership {
    use std::option::{Self, Option};
    use std::ascii::String;
    use sui::object::{Self, ID, UID};
    use sui::dynamic_field;
    use sui::tx_context::{Self, TxContext};
    use capsule::module_authority;
    use sui_utils::encode;
    use sui_utils::df_set;
    use metadata::metadata::Creator;

    // error enums
    const ECREATOR_ALREADY_SET: u64 = 0;
    const ENO_MODULE_AUTHORITY: u64 = 0;
    const ENOT_OWNER: u64 = 1;
    const EOWNER_ALREADY_SET: u64 = 2;
    const ENO_TRANSFER_AUTHORITY: u64 = 3;
    const EMISMATCHED_HOT_POTATO: u64 = 4;
    const EUID_AND_OBJECT_MISMATCH: u64 = 5;
    const EINCORRECT_PACKAGE_CREATOR: u64 = 6;
    const EOWNER_MUST_EXIST: u64 = 7;

    struct Key has store, copy, drop { slot: u8 } // = address

    // Slots for Key
    const OWNER: u8 = 0; // <address> Can open the Capsule, add/remove to delegates.
    const TRANSFER: u8 = 1; // <address> Can edit Owner field, which wipes delegates.
    const CREATOR_ID: u8 = 2; // <ID> ID of Creator Object, from which creator_auths are copied.
    const CREATOR_AUTHS: u8 = 3; // vector<address> Ceator authorites: must get creator consent to edit Metadata, Data, and Inventory.

    // convenience function for initialize_
    public fun initialize<W: drop, Object: key>(uid: &mut UID, obj: &Object, witness: W) {
        let module_auth = tx_authority::type_into_address<W>();
        initialize(uid, obj, witness, module_auth);
    }

    // This function must be run first to setup the asset
    public fun initialize_<W: drop, Object: key>(uid: &mut UID, obj: &Object, witness: W, module_auth: address) {
        assert!(!dynamic_field::exists_(uid, Key { slot: CREATOR_AUTH }), ECREATOR_ALREADY_SET);
        assert!(object::uid_to_inner(uid) == object::id_address(obj), EUID_AND_OBJECT_MISMATCH);

        let module_addr = encode::type_name_<Object>();
        assert!(is_module_witness(module_addr, &witness), EINCORRECT_MODULE_WITNESS);

        dynamic_field::add(id, Key { slot: CREATOR_AUTH }, module_auth);
    }

    // ======= Creator Authority =======
    // The ID-address of a creator object

    // You must present the UID _as well as_ the object itself in order for us to verify (1)
    // what package the object came from, and (2) that you are the creator of that package.
    // This prevents arbitrary people from claiming the creator-rights of arbitrary objects.
    // That is to say, even if uid has no 'creator' field set, there is still implicitly a creator
    // in existence that hasn't claimed their creator-status yet
    public fun claim_creator<Object: key>(uid: &mut UID, obj: &Object, creator: &Creator) {
        assert!(!dynamic_field::exists_(uid, Key { slot: CREATOR_ID }), ECREATOR_ALREADY_SET);
        assert!(object::uid_to_inner(uid) == object::id_address(obj), EUID_AND_OBJECT_MISMATCH);

        let package_id = encode::package_id<Object>();
        assert!(creator::has_package(creator, package_id), EINCORRECT_PACKAGE_CREATOR);

        dynamic_field::add(id, Key { slot: CREATOR_ID }, object::id_address(creator));
        dynamic_field::add(id, Key { slot: CREATOR_AUTHS }, creator::authorities(creator));
    }

    public fun update_creator_auths() {
        
    }

    // Claims and then nullifies creator authority. The owner now has full control
    public fun eject_creator(uid: &mut UID, obj: &Object, creator: &Creator, auth: &TxAuthority) {
        if (!dynamic_field::exists_(id, Key { slot: CREATOR_ID })) {
            claim_creator(uid, obj, creator);
        };

        eject_creator_(uid, auth);
    }

    // If the creator ID is set to @0x0, then we treat every call as valid by the creator.
    // Requires approval from the creator and owner. Owner must exist.
    public fun eject_creator_(uid: &mut UID, auth: &TxAuthority) {
        assert!(dynamic_field::exists_(id, Key { slot: OWNER }), EOWNER_MUST_EXIST);
        assert!(is_authorized_by_creator(uid, auth), ENO_CREATOR_AUTHORITY);
        assert!(is_authorized_by_owner(uid, auth), ENO_OWNER_AUTHORITY);

        df_set::set(uid, Key { slot: CREATOR_ID }, @0x0);
        df_set::drop<Key, vector<address>>(uid, Key { slot: CREATOR_AUTHS });
    }

    // If you want to give creator rights to a different package, claim it first yourself and then
    // transfer creator status to whatever other creator object you like
    public fun transfer_creator(uid: &mut UID, new: &Creator, auth: &TxAuthority) {
        assert!(is_authorized_by_creator(uid, auth), ENO_CREATOR_AUTHORITY);
        assert!(is_authorized_by_owner(uid, auth), ENO_OWNER_AUTHORITY);

        df_set::set(uid, Key { slot: CREATOR_ID }, object::id_address(new));
        df_set::set(uid, Key { slot: CREATOR_AUTHS }, creator::authorities(new));
    }

    // ======= Transfer Authority =======

    // Requires owner and creator authority.
    public fun bind_transfer_authority(uid: &mut UID, addr: address, auth: &TxAuthority) {
        assert!(is_authorized_by_creator(uid, auth), ENO_CREATOR_AUTHORITY);
        assert!(is_authorized_by_owner(uid, auth), ENO_OWNER_AUTHORITY);

        df_set::set(uid, Key { slot: TRANSFER }, addr);
    }

    // Convenience function
    public fun bind_transfer_authority_to_type<T>(uid: &mut UID, auth: &TxAuthority) {
        bind_transfer_authority(uid, tx_authority::type_into_address<T>(), auth);
    }

    // Convenience function
    public fun bind_transfer_authority_to_object<Object: key>(uid: &mut UID, obj: &Object, auth: &TxAuthority) {
        bind_transfer_authority(uid, object::id_address(obj), auth);
    }

    // Requires owner and creator authority.
    // This makes ownership non-transferrable until another transfer authority is bound.
    public fun unbind_transfer_authority(uid: &mut UID, auth: &TxAuthority) {
        assert!(is_authorized_by_creator(uid, auth), ENO_CREATOR_AUTHORITY);
        assert!(is_authorized_by_owner(uid, auth), ENO_OWNER_AUTHORITY);

        let key = Key { slot: TRANSFER };
        if (dynamic_field::exists_(uid, key)) {
            dynamic_field::remove<Key, address>(uid, key);
        };
    }

    // ========== Transfer Function =========

    // Requires transfer authority. Does NOT require ownership or creator authority.
    // This means the specified transfer authority can change ownership arbitrarily, without the current
    // owner being the sender of the transaction.
    // This is useful for marketplaces, reclaimers, and collateral-repossession
    public fun transfer(id: &mut UID, new_owner: address, auth: &TxAuthority) {
        assert!(is_authorized_by_transfer_authority(uid, auth), ENO_TRANSFER_AUTHORITY);

        let owner = dynamic_field::borrow_mut<Key, address>(id, Key { slot: OWNER });
        *owner = new_owner;
    }

    // ======= Ownership Authority =======
    // Binding requires (1) creator consent, and (2) that an owner does not already exist
    // In order to receive creator consent, the claim_creator function must be called first

    public fun bind_owner(uid: &mut UID, owner: address, auth: &TxAuthority) {
        assert!(is_authorized_by_creator(uid, auth), ENO_CREATOR_AUTHORITY);
        assert!(!dynamic_field::exists_(id, Key { slot: OWNER }), EOWNER_ALREADY_SET);

        dynamic_field::add(id, Key { slot: OWNER }, owner);        
    }

    // Convenience function
    public fun bind_owner_to_type<T>(&uid: &mut UID, auth: &TxAuthority) {
        bind_owner(uid, tx_authority::type_into_address<T>(), auth);
    }

    // Convenience function
    public fun bind_owner_to_object<Object: key>(&uid: &mut UID, obj: &Object, auth: TxAuthority) {
        bind_owner(uid, object::id_address(obj), auth);
    }

    // ========== Validity Checker Functions =========

    // If no Creator field is set, this defaults to false
    public fun is_authorized_by_creator(uid: &UID, auth: &TxAuthority): bool {
        let key = Key { slot: CREATOR_ID };
        if (!dynamic_field::exists_<Key, address>(uid, key)) { return false };

        let creator_addr = dynamic_field::borrow<Key, address>(uid, key);
        // @0x0 is the null-creator address, which we always approve
        if (creator_addr == @0x0) { return true };

        let key = Key { slot: CREATOR_AUTHS };
        if (!dynamic_field::exists_(uid, key)) { return false };
        let (i, auths) = (0, dynamic_field::borrow(uid, key));
        while (i < vector::length(auths)) {
            if (tx_authority::is_valid_address(creator_addr, *vector::borrow(auths, i))) { return true };
            i = i + 1;
        };
        return false
    }

    // If no transfer field is set, this defaults to false
    public fun is_authorized_by_transfer_authority(uid: &UID, auth: &TxAuthority): bool {
        let key = Key { slot: TRANSFER };
        if (dynamic_field::exists_<Key, address>(uid, key)) {
            let transfer_addr = dynamic_field::borrow<Key, address>(uid, key);
            tx_authority::is_valid_address(transfer_addr, auth)
        } else {
            return false
        }
    }

    // If no owner field is set, this defaults to true
    public fun is_authorized_by_owner(uid: &UID, auth: &TxAuthority): bool {
        let key = Key { slot: OWNER };
        if (dynamic_field::exists_<Key, address>(uid, key)) {
            let owner_addr = dynamic_field::borrow<Key, address>(uid, key);
            tx_authority::is_valid_address(creator_addr, auth)
        } else {
            return true
        }
    }

    // This is based on the convention that if your module_addr is 0x599::outlaw_sky, then your
    // witness struct must be 0x599::outlaw_sky::Outlaw_Sky (or some case variant of it, like outlaw_sky::OUtlAw_SkY
    public fun is_module_witness<Witness: drop>(module_addr: String, witness: &Witness) {
        let (witness_module_addr, struct_name) = encode::type_name_<W>();
        if (module_addr != witness_module_addr) false
        else {
            let struct_name_lc = encode::to_lower_case(struct_name);
            let (package_id, module_name) = encode::decompose_module_addr(module_addr);
            if (struct_name_lc == module_name) true 
            else false 
        }
    }

    // ========== Getter Functions =========

    public fun owner(uid: &UID): Option<address> {
        let key = Key { slot: OWNER };
        if (dynamic_field::exists_(uid, key)) {
            option::some(*dynamic_field::borrow<Key, address>(uid, key))
        } else {
            option::none()
        }
    }

    public fun transfer_authority(uid: &UID): Option<address> {
        let key = Key { slot: TRANSFER };
        if (dynamic_field::exists_(uid, key)) {
            option::some(*dynamic_field::borrow<Key, address>(uid, Key { slot: TRANSFER }))
        } else {
            option::none()
        }
    }

    public fun creator(uid: &UID): Option<address> {
        let key = Key { slot: CREATOR_ID };
        if (dynamic_field::exists_(uid, key)) {
            let addr = object::id_from_address(dynamic_field::borrow<Key, address>(uid, key))
            option::some(addr)
        } else {
            option::none()
        }
    }
}