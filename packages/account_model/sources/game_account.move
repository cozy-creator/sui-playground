// TO DO: We could change this such that we use raw-keys rather than struct-keys
// This would make GameAccount to be non-extendable however
// We should test to see if there are any tradeoffs. Otherwise we could use separate UIDs

module account_model::game_account {

    // Permission constants (for delegation)
    const INSERT: u8 = 0;
    const BORROW_MUT: u8 = 1;
    const EJECT: u8 = 2;

    // To save gas, we use separate UIDs to store objects and owner-addresses, rather than key-addresses
    // That way accounts can still be extendable + safe + efficient
    struct GameAccount has key {
        id: UID,
        objects: UID,
        owner_addrs: UID
    }

    // Module authority
    struct Witness has drop {}

    struct Key has store, copy, drop { id: ID } // -> object
    struct KeyOwner has store, copy drop { id: ID } // -> owner address

    // ======== Create / Destroy Accounts ========

    public entry fun create<Owner>(ctx: &mut TxContext) {
        let owner = tx_context::type_into_address<Owner>();
        create_(owner, ctx);
    }

    public entry fun create_(owner: address, ctx: &mut TxContext) {
        let account = GameAccount { id: object::new(ctx) };

        let typed_id = typed_id::new(&account);
        let auth = tx_authority::begin_with_type(&Witness { });
        ownership::as_shared_object<SimpleTransfer>(&mut account.id, typed_id, owner, &auth);

        transfer::share_object(account);
    }

    // ======== Primary API ======== 

    // Requires insert authority. We could make this permissionless, which wouldn't cause any harm other than
    // lots of spam.
    public fun insert<T: store>(account: &mut GameAccount, object: T, owner: address, auth: &TxAuthority) {
        assert(delegation::has_permission_from_owner(&account.id, INSERT, auth), ENO_INSERT_PERMISSION);
        // assert!(tx_authority::is_signed_by(account.owner, auth), ENOT_OWNER);

        let id = object::id(&object);
        dynamic_field::add(account, KeyOwner { id }, owner);
        dynamic_field::add(account, Key { id }, object);
    }

    public fun eject<T, store>(account: &mut GameAccount, id: ID, auth: &TxAuthority): (T, address) {
        assert!(tx_authority::is_signed_by(account.owner, auth), ENOT_OWNER);

        (
            dynamic_field::remove<Key, T>(account, Key { id }), 
            dynamic_field::remove<Key, T>(account, KeyOwner { id })
        )
    }

    // Requires eject authority from account-1, and insert authority from account-2
    public fun transfer<T: store>(from: &mut GameAccount, into &mut GameAccount, id: ID, auth: &TxAuthority) {
        let (obj, owner) = eject(from, id, auth);
        insert(into, obj, owner, auth);
    }

    // Requires no authority
    public fun borrow<T: store>(account: &mut GameAccount, id: ID): &T {
        dynamic_field::borrow<Key, T>(account, Key { id })
    }

    public fun borrow_mut<T: store>(account: &mut GameAccount, id: ID, auth: &TxAuthority): &mut T {
        assert!(tx_authority::is_signed_by(account.owner, auth), ENOT_OWNER);

        dynamic_field::borrow_mut<Key, T>(account, Key { id })
    }

    // ======== Getter Functions ======== 

    public fun owner(account: &GameAccount, id: ID): address {
        *dynamic_field::borrow<Key, address>(account, KeyOwner { id })
    }

    public fun exists(account: &GameAccount, id: ID): bool {
        dynamic_field::exists_(account, Key { id })
    }

    public fun exists_with_type<T: store>(account: &GameAccount, id: ID): bool {
        dynamic_field::exists_with_type<Key, T>(account, Key { id })
    }

    // ======== Extend Pattern ========

    public fun uid(account: &GameAccount): &UID {
        &account.id
    }

    public fun uid_mut(account: &mut GameAccount, auth: &TxAuthority): &mut UID {
        assert!(ownership::has_permission_from_owner(&account.id, ???, auth), ENO_OWNER_PERMISSION);

        &mut account.id
    }

    // View function ??? 
}