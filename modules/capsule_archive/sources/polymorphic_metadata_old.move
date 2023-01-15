// // Old code from an old metadata module

module sui_playground::polymorphic_metaadata {
        // ========= Modify Attributes =========

    public entry fun add_world_attribute<G: drop>(
        cap: &MetadataCap<G>,
        world: &mut WorldMetadata<G>,
        slot: String,
        bytes: vector<u8>
    ) {
        remove_world_attribute<G, Value>(cap, world, slot);
        dynamic_field::add(&mut world.id, Key { slot }, bytes);
    }

    public entry fun remove_world_attribute<G: drop>(
        _cap: &MetadataCap<G>,
        world: &mut WorldMetadata<G>,
        slot: String
    ) {
        if (dynamic_field::exists_(&world.id, Key { slot })) {
            dynamic_field::remove<Key, vector<u8>>(&mut world.id, Key { slot });
        };
    }

    public entry fun add_type_attribute<G: drop, T>(
        cap: &MetadataCap<G>,
        type: &mut Type<T>,
        slot: String,
        bytes: vector<u8>
    ) {
        remove_type_attribute<G, T, Value>(cap, type, slot);
        dynamic_field::add(&mut type.id, Key { slot }, bytes);
    }

    public entry fun remove_type_attribute<G: drop, T>(
        _cap: &MetadataCap<G>,
        type: &mut Type<T>,
        slot: String
    ) {
        assert!(is_valid(cap, type), EINVALID_METADATA_CAP);

        if (dynamic_field::exists_(&type.id, Key { slot })) {
            dynamic_field::remove<Key, vector<u8>>(&mut type.id, Key { slot });
        };dule_attribute
    }

    // ========= Batch-Add Attributes =========

    // Encoded as: [ key: String, value_type: vector<u8> ]
    // Unfortunately bcs does not support peeling strings, so we're just working with raw types
    public entry fun add_world_attributes<G: drop>(
        cap: &MetadataCap<G>,
        world: &mut WorldMetadata<G>,
        attribute_pairs: vector<vector<u8>>
    ) {
        let (i, length) = (0, vector::length(&attribute_pairs));
        assert!(length % 2 == 0, EIMPROPERLY_SERIALIZED_BATCH_BYTES);

        while (i < length) {
            let slot = utf8(*vector::borrow(&attribute_pairs, i));
            let bytes = *vector::borrow(&attribute_pairs, i + 1);
            add_world_attribute(cap, world, slot, bytes);
            i = i + 2;
        };
    }

    public entry fun add_type_attributes() {

    }

    // Requires module authority
    // Requires ownership authority if there is an owner
    public fun batch_add_attributes<World: drop>(
        witness: World,
        id: &mut UID,
        attributes: vector<vector<u8>>,
        schema: &Schema,
        ctx: &TxContext
    ): World {
        assert!(module_authority::is_valid<World>(id), ENO_MODULE_AUTHORITY);
        assert!(ownership::is_valid_owner(id, tx_context::sender(ctx)), ENOT_OWNER);

        let (i, length) = (0, vector::length(&attributes));
        assert!(length % 2 == 0, EIMPROPERLY_SERIALIZED_BATCH_BYTES);

        while (i < length) {
            let slot = utf8(*vector::borrow(&attributes, i));
            let bytes = *vector::borrow(&attributes, i + 1);
            dynamic_field::add(id, slot, bytes);
            i = i + 2;
        };

        witness
    }

    // ========= Make Metadata Immutable =========

    // Being able to freeze shared objects is currently being worked on; when it's available, freeze the module here along with
    // the metadata_cap being destroyed.
    public fun destroy_metadata_cap<G: drop>(metadata_cap: MetadataCap<G>) {
        let MetadataCap { id } = metadata_cap;
        object::delete(id);
    }

    // Not currently possible
    public fun freeze_world_metadata<G: drop>(cap: &MetadataCap<G>, world: WorldMetadata<G>) {
        transfer::freeze_object(world);
    }

    // Not currently possible
    public fun freeze_type<T>(cap: &MetadataCap<G>, type: Type<T>) {
        assert!(is_valid(cap, type), EINVALID_METADATA_CAP);
        transfer::freeze_object(type);
    }

    // ============== View Functions for Client apps ============== 

    // Should we return the keys (query_slots) back along with the bytes?
    public fun get_world_attributes(world: &WorldMetadata, query_slots: vector<vector<u8>>): vector<vector<u8>> {
        let (i, response) = (0, vector::empty<vector<u8>>());

        while (i < vector::length(&query_slots)) {
            let slot = utf8(*vector::borrow(&query_slots, i));

            // We leave an empty vector of bytes if the slot does not have any value
            if (dynamic_field::exists_(&world.id, Key { slot })) {
                vector::push_back(&mut response, *dynamic_field::borrow<Key, vector<u8>>(&world.id, slot));
            } else {
                vector::push_back(&mut response, vector::empty<u8>());
            };
            i = i + 1;
        };

        response
    }

    public fun get_world_attribute<G>(world: &WorldMetadata<G>, slot_raw: vector<u8>): Option<vector<u8>> {
        let key = Key { slot: utf8(slot_raw) };
        if (!dynamic_field::exists_(&world.id, key)) { 
            return option::none()
        };
        
        option::some(*dynamic_field::borrow<Key, vector<u8>>(&world.id, key))
    }

    // [ (slot), (value), ]
    // 
    public entry fun add_attributes<Value: store + copy + drop>(
        schema: &MetadataSchema,
        slots: vector<vector<u8>>,
        bytes: vector<vector<u8>>
    ) {
        assert!(vector::length(&slots) == vector::length(&bytes), EKEY_VALUE_LENGTH_MISMATCH);

        // bools, address, ascii, utf8 strings, u8, u16, u32, u64, u128, u256, url, array<> for all of them
        if (utf8(b"0x2::string::String") == encode::type_name<Value>()) {
            let i = 0;
            while (i < vectr::length(&bytes)) {

            }
        } else if (u64) {

        };
    }

    public fun get_type_attribute<T>(type: &Type<T>, slot_raw: vector<u8>): Option<vector<u8>> {
        let key = Key { slot: utf8(slot_raw) };
        if (!dynamic_field::exists_(&type.id, key)) { 
            return option::none() 
        };

        option::some(*dynamic_field::borrow<Key, vector<u8>>(&type.id, key))
    }

    // This first checks id for module_addr + data = Data. That is, a record stored on UID that
    // corresponds to module_addr G, with the corresponding Data type. If it's not found, it falls
    // back to using the Type object for module G.
    public fun for_object<G, Data: store + copy + drop>(
        id: &UID,
        type_name: String,
        metadata: &Type<G>
    ): Data {
        let (key, _) = encode::type_name_<G>();
        string::append(&mut key, encode::type_name<Data>());

        if (dynamic_field::exists_with_type<String, Data>(id, key)) {
            dynamic_field::borrow<String, Data>(id, key)
        } else {
            get_<G, Data>(metadata, type_name)
        }
    }

    public fun for_object_cannonical<G, Data: store + copy + drop>(
        id: &UID,
        type_name: String,
        metadata: &Type<G>
    ): Data {
        let (module_addr1, _) = encode::type_name_<G>();
        let (module_addr2, _) = encode::decompose_type_name(type_name);
        assert!(module_addr1 == module_addr2, ENOT_CANONICAL_TYPE);

        for_object<G, Data>(id, type_name, metadata)
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(PackageRegistry { id: object::new(ctx) });
    }
}