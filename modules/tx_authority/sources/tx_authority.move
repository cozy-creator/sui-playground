module sui_playground::tx_authority {
    use std::vector;
    use std::string::String;
    use sui::tx_context::{Self, TxContext};
    use sui::object;
    use sui_utils::encode;

    struct TxAuthority has drop {
        addresses: vector<address>,
        modules: vector<String>
    }

    public fun create(ctx: &mut TxContext): TxAuthority {
        let auth = TxAuthority {
            addresses: vector::empty(),
            modules: vector::empty()
        };

        add_address_(&mut auth, ctx);
        
        auth
    }

    public fun add_address<Object: key>(object: &Object, auth: &mut TxAuthority) {
        add_address_internal(object::id_address(object), auth);
    }

    public fun add_address_(auth: &mut TxAuthority, ctx: &TxContext) {
        add_address_internal(tx_context::sender(ctx), auth);
    }

    public fun remove_address<Object: key>(object: &Object, auth: &mut TxAuthority) {
        let addr = object::id_address(object);

        let (exists, i) = vector::index_of(&auth.addresses, &addr);
        if (exists) { vector::remove(&mut auth.addresses, i); };
    }

    // Instead of storing the witness type here, we could store the module address itself
    // We would need a Link in order to prove that, and this would assume modules only ever
    // use one witness, which is a reasonable assumption
    public fun add_module<Witness: drop>(_witness: Witness, auth: &mut TxAuthority) {
        let witness_type = encode::type_name<Witness>();

        if (!vector::contains(&auth.modules, &witness_type)) {
            vector::push_back(&mut auth.modules, witness_type);
        };
    }

    public fun remove_module<Witness: drop>(auth: &mut TxAuthority) {
        let witness_type = encode::type_name<Witness>();

        let (exists, i) = vector::index_of(&auth.modules, &witness_type);
        if (exists) { vector::remove(&mut auth.modules, i); };
    }

    // ========= Internal Functions =========

    public fun is_valid_address<Object: key>(object: &Object, auth: &TxAuthority): bool {
        let addr = object::id_address(object);
        is_valid_address_(addr, auth)
    }

    public fun is_valid_address_(addr: address, auth: &TxAuthority): bool {
        let (exists, _) = vector::index_of(&auth.addresses, &addr);
        exists
    }

    public fun is_valid_module<Witness: drop>(auth: &TxAuthority): bool {
        let witness_type = encode::type_name<Witness>();
        is_valid_module_(witness_type, auth)
    }

    public fun is_valid_module_(witness_type: String, auth: &TxAuthority): bool {
        let (exists, _) = vector::index_of(&auth.modules, &witness_type);
        exists
    }

    // ========= Internal Functions =========

    fun add_address_internal(addr: address, auth: &mut TxAuthority) {
        if (!vector::contains(&auth.addresses, &addr)) {
            vector::push_back(&mut auth.addresses, addr);
        };
    }
}