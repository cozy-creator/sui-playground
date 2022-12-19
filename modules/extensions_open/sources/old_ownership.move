module sui_playground::ownership {
    use std::vector;

    // error enums
    const ENO_MODULE_AUTHORITY: u64 = 0;
    const ENOT_OWNER: u64 = 1;
    const ENO_MARKET_AUTHORITY: u64 = 2;
    const EHIGHER_OFFER_REQUIRED: u64 = 3;

    struct Key has store, copy, drop { slot: u8 }

    // Slots for Key
    const TRANSFER: u8 = 0;
    const OWNER: u8 = 1;
    const OFFER: u8 = 2;
    const OFFER_INFO: u8 = 3;
    const LIEN_INFO: u8 = 4;

    struct OwnerAuth<phantom Market> has store { owner: address }

    struct OfferInfo has store, drop {
        coin_type: String,
        price: u64,
        pay_to: address
    }

    struct LienInfo has store, drop {
        coin_type: String,
        amount: u64,
        pay_to: address
    }

    // Requires module permission. Only works if no owner is currently set
    public fun bind_owner<Witness: drop>(_witness: Witness, id: &mut UID, addr: address) {
        assert!(module_authority::is_authority<Witness>(id), ENO_MODULE_AUTHORITY);

        if (!dynamic_field::exists_with_type<Key, address>(id, Key { slot: OWNER })) {
            dynamic_field::add(id, Key { slot: OWNER}, addr);
        };
    }

    // Requires module permission. Requires owner permission if a transfer authority is already set
    public fun bind_transfer_authority<Witness: drop, Transfer: drop>(
        _witness: Witness,
        id: &mut UID,
        ctx: &TxContext
    ) {
        assert!(module_authority::is_authority<Witness>(id), ENO_MODULE_AUTHORITY);
        assert!(is_owner(id, tx_context::sender(ctx)), ENOT_OWNER);

        let transfer_witness = encode::type_name<Transfer>();
        let key = Key { slot: TRANSFER };

        if (dynamic_field::exists_with_type<Key, vector<String>>(id, key)) {
            let witness_list = dynamic_field::borrow_mut(id, key);
            
            // No need to add this witness type again if it's already been added
            let (exists, i) = vector::index_of(witness_list, witness_type);
            if (!exists) {
                vector::push_back(witness_list, transfer_witness); 
            };
        } else {
            dynamic_field::add(id, key, vector[transfer_witness]);
        };
    }

    // Requires both module and owner permission
    public fun unbind_transfer_module<Witness: drop, Transfer: drop>(_witness: Witness, id: &mut UID, ctx: &TxContext) {
        assert!(module_authority::is_authority<Witness>(id), ENO_MODULE_AUTHORITY);
        assert!(is_owner(id, tx_context::sender(ctx)), ENOT_OWNER);

        let key = Key { slot: TRANSFER };

        if (dynamic_field::exists_with_type<Key, vector<String>>(id, key)) {
            let witness_list = dynamic_field::borrow_mut(id, key);

            let (exists, i) = vector::index_of(witness_list, encode::type_name<Transfer>());
            if (exists) {
                vector::remove(witness_list, i);
            }
        }
    }

    public fun into_transfer_witnesses(id: &UID): vector<String> {
        let key = Key { slot: TRANSFER };

        if (dynamic_field::exists_with_type<Key, vector<String>>(id, key)) {
            *dynamic_field::borrow<Key, vector<String>>(id, key)
        }
        else {
            vector::empty<String>()
        }
    }

    public fun is_valid_transfer_witness<Transfer: drop>(id: &UID): bool {
        let key = Key { slot: TRANSFER };

        if (dynamic_field::exists_with_type<Key, vector<String>>(id, key)) {
            let witness_list = dynamic_field::borrow<Key, vector<String>>(id, key);
            let (exists, i) = vector::index_of(witness_list, encode::type_name<Transfer>());
            exists
        } else {
            false
        }
    }

    public fun initialize<M: drop>(id: &mut UID, owner: address) {
        dynamic_field::add(id, Key { slot: OWNER }, OwnerAuth<M> { owner });
    }

    public fun add_offer<C, Market: drop, SellOffer: store, drop>(_witness: Market, id: &mut UID, price: u64, sell_offer: SellOffer, ctx: &Txcontext) {
        assert!(is_market_witness<Market>(id), ENO_MARKET_AUTHORITY);
        assert!(is_owner(id, tx_context::sender(ctx)), ENOT_OWNER);

        // In the future we want to be able to drop this without specifying the type;
        // this doesn't work right unless you can just drop whatever sort of SellOffer is being
        if (dynamic_field::exists_with_type<Key, SellOffer>(id, Key { slot: OFFER })) {
            dynamic_field::remove<Key, SellOffer>(id, Key { slot: OFFER });
            dynamic_field::remove<Key, SellOffer>(id, Key { slot: OFFER });
        };

        let offer_info = OfferInfo {
            coin_type: encode::type_name<C>,
            price
        };
        dynamic_field::add(id, Key { slot: OFFER }, sell_offer);
        dynamic_field::add(id, Key { slot: OFFER_INFO }, offer_info);

        // Ensure the listing can pay back any existing lien
        assert!(is_lien_and_offer_compatible(id), EOFFER_INCOMPATIBLE_WITH_EXISTING_LIEN);
    }

    public fun remove_offer<M: drop, SellOffer: store, drop>(_witness: M, id: &mut UID): SellOffer {
        assert!(is_market_witness<M>(id), ENO_MARKET_AUTHORITY);
        dynamic_field::remove<Key, SellOffer>(id, Key { slot: OFFER })
    }

    // Fails if a lien already exists
    // Witness is the witness-authority that can be used later to remove the lien
    public fun add_lien<Witness: drop, C, Lien: store>(id: &mut UID, amount: u64, pay_to: address ctx: &TxContext) {
        assert!(is_owner(id, tx_context::sender(ctx)));

        let lien_info = LienInfo {
            witness_type: encode::type_name<Witness>,
            coin_type: encode::type_name<C>(),
            amount,
            pay_to
        };
        dynamic_field::add(id, Key { slot: LEIN_INFO }, lien_info);

        // Check to see if the sell offer is sufficient

    }

    public fun remove_lien<Witness: drop, C, Lien: store>(_witness: Witness, id: &mut UID): Lien {
        let lien_info = dynamic_field::remove<Key, LienInfo>(id, Key { slot: LIEN_INFO });
        let LienInfo { witness_type, coin: _, amount: _ };

        assert!(witness_type == encode::type_name<Witness>(), EINCORRECT_WITNESS);

        dynamic_field::remove<Key, Lien>(id, Key { slot: LIEN })
    }

    fun remove_lien_internal<Lien>(id: &mut UID): Lien {
        dynamic_field::remove<Key, LienInfo>(id, Key { slot: LIEN_INFO });
        dynamic_field::remove<Key, Lien>(id, Key { slot: LIEN })
    }

    public fun payback_lien<C>(id: &mut UID, coin: Coin<C>) {
        remove_lien_id()
    }

    public fun transfer<M: drop>(_witness: M, id: &mut UID, new_owner: address) {
        let owner_auth = dynamic_field::borrow_mut<Key, OwnerAuth<M>>(id, Key { slot: OWNER });
        owner_auth.owner = new_owner;
    }

    // public fun fulfill_market_badass(id: &mut UID, coin: Coin<SUI>) {
    // }

    public fun into_lien_amount(id: &UID): (String, u64) {
        let lien_info = dynamic_field::borrow<Key, LienInfo>(id, Key { slot: LIEN_INFO });
        (lien_info.coin_type, lien_info.amount )
    }

    public fun into_offer_amount(id: &UID): (String, u64) {
        let offer_info = dynamic_field::borrow<Key, OfferInfo>(id, Key { slot: OFFER_INFO });
        (offer_info.coin_type, offer_info.amount )
    }

    // ============ Checking Functions ===============

    public fun is_lien_and_offer_compatible(id: &UID): bool {
        if (lien_exists(id) && offer_exists(id)) {
            let (coin_type1, amount) = into_lien_amount(id);
            let (coin_type2, price) = into_offer(id);
            (coin_type1 == coin_type2) && (price >= amount)
        } else {
            true
        }
    }

    // In the future, be able to answer this without specifying the value
    public fun lien_exists(id: &UID): bool {
        dynamic_field::exists_with_type<Key, LienInfo>(id, Key { slot: LIEN_INFO })
    }

    public fun offer_exists(id: &UID): bool {
        dynamic_field::exists_with_type<Key, OfferInfo>(id, Key { slot: OFFER_INFO })
    }

    public fun is_market_witness<M: drop>(id: &UID): bool {
        dynamic_field::exists_with_type<OwnerKey, OwnerAuth<M>>(id, OwnerKey {} );
    }

    public fun is_owner(id: &UID, addr: address): bool {
        addr == *dynamic_field::borrow<Key, address>(id, Key { slot: OWNER })
    }
}