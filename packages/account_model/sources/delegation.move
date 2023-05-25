// A delegation is:
// A specification of a function which can be called
// By an agent
// On behalf of the principle


module account_model::delegation {
    // Convenience function
    public fun has_permission<Principal>(uid: &UID, permission: u8, auth: &TxAuthority): bool {
        has_permission_(uid, tx_authority::type_to_address<Principal>(), permission, auth)
    }

    public fun has_permission_(uid: &UID, principal: address, permission: u8, auth: &TxAuthority): bool {
        let signers = tx_authority::signers(auth);
        let i = 0;
        while (i < vector::length(&signers)) {
            let addr = vector::borrow(signers, i);
            let acl = dynamic_field::borrow<Key, u16>(uid, Key { addr });
            if (acl::has_permission(acl, permission)) { return true };
            i = i + 1;
        };

        false
    }
}