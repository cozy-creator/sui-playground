module sui_playground::authority {
    use sui::dynamic_field;
    use noot_utils::encode;
    
    // Error constants
    const ENO_AUTHORITY: u64 = 0;

    struct Key has store, copy, drop {}

    public fun bind_auth<Witness: drop>(_witness: Witness, id: &mut UID) {
        let type_name = encode::type_name<Witness>();
        dynamic_field::add(id, Key {}, witness_type);
    }

    public fun unbind_auth<Witness: drop>(_witness: Witness, id: &mut UID) {
        assert!(is_auth<Witness>(id), ENO_AUTHORITY);
        dynamic_field::remove<Key, String>(id, Key {});
    }

    public fun into_auth(id: &UID): String {
        *dynamic_field::borrow<Key, String>(id, Key {});
    }

    public fun is_auth<Witness>(id: &UID): bool {
        encode::type_name<Witness>() == *dynamic_field::borrow<Key, String>(id, Key {})
    }
}

// Transfer-cap based ownership
module sui_playground::owner {
    const ENOT_OWNER: u64 = 0;
    const EWRONG_OBJECT: u64 = 1;

    struct Key has store, drop {}
    struct OwnerKey has store, drop { for: ID, owner: address}

    public fun bind_owner(id: &mut UID, addr: address) {
        if (!dynamic_field::exists_with_type<Key, address>(id, Key {})) {
            dynamic_field::add(id, Key{}, addr);
        };
    }

    public fun get_owner_key(id: &UID, ctx: &TxContext): OwnerKey {
        assert!(is_owner(id, tx_context::sender(ctx), ENOT_OWNER));
        OwnerKey { 
            for: object::uid_to_inner(id),
            owner: *dynamic_field::borrow<Key, address>(id, Key{})
        }
    }

    // Disposable transfer-cap pattern
    public fun transfer(id: &mut UID, key: OwnerKey, addr: address) {
        let OwnerKey { for, owner } = key;
        assert!(is_owner(id, owner), ENOT_OWNER);
        assert!(object::uid_to_inner(id) == for, EWRONG_OBJECT);

        let owner = dynamic_field::borrow_mut(id, Key {});
        owner = addr;
    }

    public fun is_owner(id: &UID, addr: address): bool {
        if (!dynamic_field::exists_with_type<Key, address>(id, Key {})) { return true };
        addr == *dynamic_field::borrow(id, Key {})
    }
}

module sui_playground::plugin {
    // error enums
    const ENOT_OWNER: u64 = 0;
    const ENO_MARKET_AUTHORITY: u64 = 1;
    const EHIGHER_OFFER_REQUIRED: u64 = 2;

    struct Key has store, copy, drop { slot: u8 }

    // Slots for Key
    const OWNER: u8 = 0;
    const OFFER: u8 = 1;
    const OFFER_INFO: u8 = 1;
    const LIEN: u8 = 2;
    const LIEN_INFO: u8 = 3;

    struct OwnerAuth<phantom Market> has store { owner: address }

    struct OfferInfo has store, drop {
        coin_type: String,
        price: u64,
    }

    struct LienInfo has store, drop {
        witness_type: String,
        coin_type: String,
        amount: u64,
    }

    public fun initialize<M: drop>(id: &mut UID, owner: address) {
        dynamic_field::add(id, Key { slot: OWNER }, OwnerAuth<M> { owner });
    }

    public fun add_market<C, Market: drop, SellOffer: store, drop>(_witness: Market, id: &mut UID, price: u64, sell_offer: SellOffer, ctx: &Txcontext) {
        assert!(is_market_witness<Market>(id), ENO_MARKET_AUTHORITY);
        assert!(is_owner(id, tx_context::sender(ctx)), ENOT_OWNER);

        // In the future we want to be able to drop this without specifying the type;
        // this doesn't work right unless you can just drop whatever sort of SellOffer is being
        if (dynamic_field::exists_with_type<Key, SellOffer>(id, Key { slot: OFFER })) {
            dynamic_field::remove<Key, SellOffer>(id, Key { slot: OFFER });
        };

        // Ensure the listing can pay back any existing lien
        if (lien_exists(id)) {
            let (coin_type, amount) = into_lien_amount(id);
            assert!(coin_type == encode::type_name<C>(), EINCORRECT_COIN_TYPE);
            assert!(price >= amount, EHIGHER_OFFER_REQUIRED);
        }

        let offer_info = OfferInfo {
            coin_type: encode::type_name<C>,
            price
        };
        dynamic_field::add(id, Key { slot: OFFER }, sell_offer);
        dynamic_field::add(id, Key { slot: OFFER_INFO }, offer_info);
    }

    public fun remove_market<M: drop, SellOffer: store, drop>(_witness: M, id: &mut UID): SellOffer {
        assert!(is_market_witness<M>(id), ENO_MARKET_AUTHORITY);
        dynamic_field::remove<Key, SellOffer>(id, Key { slot: OFFER })
    }

    // Fails if a lien already exists
    // Witness is the witness-authority that can be used later to remove the lien
    public fun add_lien<Witness: drop, C, Lien: store>(id: &mut UID, lien: Lien, amount: u64, ctx: &TxContext) {
        assert!(is_owner(id, tx_context::sender(ctx)));

        let lien_info = LienInfo {
            witness_type: encode::type_name<Witness>,
            coin_type: encode::type_name<C>(),
            amount
        };
        dynamic_field::add(id, Key { slot: LEIN }, lien_store);
        dynamic_field::add(id, Key { slot: LEIN_INFO }, lien_info);
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

    // ============ Checking Functions ===============

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
        addr == *dynamic_field::borrow<Key, OwnerAuth>(id, Key { slot: OWNER}).owner
    }
}

module sui_playground::outlaw_sky {
    use sui::tx_context::{Self, TxContext};

    // Error constants
    const ENOT_OWNER: u64 = 0;

    // Genesis-witness and witness
    struct OUTLAW_SKY has drop {}
    struct Outlaw_Sky has drop {}

    struct Outlaw has key, store {
        id: UID,
        owner: address
    }

    public fun create_outlaw(ctx: &mut TxContext): Outlaw {
        let id = object::new(ctx);
        authority::bind_authority(Outlaw_Sky {}, &mut id);
        Outlaw { id, owner: tx_context::sender(ctx) }
    }

    public fun extend(outlaw: &mut Outlaw, ctx: &TxContext): &mut UID {
        assert!(tx_context::sender == outlaw.owner, ENOT_OWNER);
        &mut outlaw.id
    }
}

// Auth: Owner can attach
module sui_playground::permissionless_attach {
    use sui::object::UID;
    use sui::dynamic_field;

    // Key slots
    const SLOT1: u8 = 0;
    const SLOT2: u8 = 1;

    struct Key has store, copy, drop { slot: u8 }

    struct KeyCap has store {}

    public fun attach_data<Data: store + copy + drop>(id: &mut UID, data_shape: Data) {
        dynamic_field::add(id, Key { slot: SLOT1 }, data_shape);
    }

    public fun get_data<Data: store + copy + drop>(id: &mut UID): Data {
        dynamic_field::borrow<Key, Data>(id, Key { slot: SLOT1 }, data_shape)
    }

    public fun whatever(_key_cap: &KeyCap): Key {
        Key { slot: SLOT2 }
    }
}

// Auth: Owner + Project can attach
module sui_playground::permissioned_attach {
    use sui::object::UID;
    use sui::dynamic_field;
    use sui_playground::authority;

    // Key slots
    const SLOT1: u8 = 0;
    const SLOT2: u8 = 1;

    // Error constants
    const ENO_AUTHORITY: u64 = 0;

    struct Key has store, copy, drop { slot: u8 }

    public fun attach_data<Witness: drop, Data: store + copy + drop>(
        _witness: Witness,
        id: &mut UID,
        data_shape: Data
    ) {
        assert!(authority::is_auth<Witness>(id), ENO_AUTHORITY);

        dynamic_field::add(id, Key { slot: SLOT1 }, data_shape);
    }

    public fun export_key(): Key {
        Key { slot: SLOT3 }
    }
}

module sui_playground::data_shape {
    struct Display has store, copy, drop {
        name: String,
        description: String,
        image: String
    }
}

module sui_playground::marketplace {
    use sui_playground::owner::OwnerKey;
    use sui_playground::plugin;
    use noot_utils::encode;

    const EINSUFFICIENT_FUNDS: u64 = 0;
    const EINCORRECT_COIN_TYPE: u64 = 1;

    // Witness
    struct Market has drop {}

    struct SellOffer has store, drop {
        coin_type: String,
        price: u64,
        pay_to: address
    }

    // Ovewrites any prior existing offer
    public fun create_sell_offer<C>(id: &mut UID, price: u64, ctx: &TxContext) {
        let sell_offer = SellOffer {
            coin_type: encode::type_name<C>(),
            price, 
            pay_to: tx_context::sender(ctx),
        };
        plugin::add_market(Market {}, id, sell_offer);
    }

    public fun fill_sell_offer<C>(id: &mut UID, coin: Coin<C>, ctx: &TxContext) {
        let SellOffer { coin_type, price, pay_to } = plugin::remove_market(Market {}, id);

        assert!(coin_type == encode::type_name<C>, EINCORRECT_COIN_TYPE);
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);

        transfer::transfer(coin, pay_to);

        plugin::transfer(Market {}, id, tx_sender::sender(ctx));
    }
}