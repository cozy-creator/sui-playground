module noot::dispenser {
    use sui::object::{UID, ID};
    use sui::vec_map::VecMap;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::object;
    use sui::coin::{Self, Coin};
    use noot::coin2;
    use noot::rand;
    use std::vector;
    use std::string::String;

    const ENOT_AUTHORIZED: u64 = 0;
    const EDISPENSER_LOCKED: u64 = 1;
    const EINSUFFICIENT_FUNDS: u64 = 2;

    struct Dispenser<phantom C, D> has key, store {
        id: UID,
        price: u64,
        treasury_addr: address,
        locked: bool,
        contents: vector<Capsule<D>>,
    }

    struct Capsule<D> has store, copy, drop {
        display: VecMap<String, String>,
        body: D
    }

    struct DispenserCap<phantom C, phantom D> has key, store {
        id: UID,
        for: ID
    }

    // ============ Admin Functions ===========

    public entry fun create_<C, D: store>(
        price: u64, 
        treasury_addr: address, 
        ctx: &mut TxContext) 
    {
        let (dispenser, dispenser_cap) = create<C, D>(price, treasury_addr, ctx);

        transfer::share_object(dispenser);
        transfer::transfer(dispenser_cap, tx_context::sender(ctx));
    }

    public fun create<C, D: store>(
        price: u64, 
        treasury_addr: address, 
        ctx: &mut TxContext): (Dispenser<C, D>, DispenserCap<C, D>) 
    {
        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);

        let dispenser = Dispenser<C, D> {
            id: uid,
            price,
            treasury_addr,
            locked: true,
            contents: vector::empty<Capsule<D>>()
        };

        let dispenser_cap = DispenserCap<C, D> {
            id: object::new(ctx),
            for: id
        };

        (dispenser, dispenser_cap)
    }

    public entry fun delete<D: store>() {}

    public entry fun load<C, D: store>(
        dispenser_cap: &DispenserCap<C, D>, 
        dispenser: &mut Dispenser<C, D>, 
        display: VecMap<String, String>, 
        body: D, 
        _ctx: &mut TxContext)
    {
        assert!(is_correct_dispenser_cap(dispenser_cap, dispenser), ENOT_AUTHORIZED);
        vector::push_back(&mut dispenser.contents, Capsule { display, body });
    }

    public entry fun unload_() {}

    public fun unload() {}

    public entry fun lock() {}

    public entry fun unlock() {}

    public entry fun change_price() {}

    public entry fun change_treasury_addr() {}

    // ============ User Functions ===========

    public fun buy_from<C, D: store>(
        coin: Coin<C>,
        dispenser: &mut Dispenser<C, D>,
        ctx: &mut TxContext): (VecMap<String, String>, D)
    {
        assert!(is_unlocked(dispenser), EDISPENSER_LOCKED);
        let price = dispenser.price;
        assert!(coin::value(&coin) >= price, EINSUFFICIENT_FUNDS);

        coin2::take_coin_and_transfer(dispenser.treasury_addr, &mut coin, price, ctx);
        coin2::refund(coin, ctx);

        let length = vector::length(&dispenser.contents);
        let index = rand::rng(0, length);
        let Capsule { display, body } = vector::remove(&mut dispenser.contents, index);

        (display, body)
    }

    // ============ Authority-Checking Functions ===========

    public fun is_correct_dispenser_cap<C, D: store>(
        dispenser_cap: &DispenserCap<C, D>, 
        dispenser: &Dispenser<C, D>): bool 
    {
        (dispenser_cap.for == object::id(dispenser))
    }

    public fun is_unlocked<C, D: store>(dispenser: &Dispenser<C, D>): bool {
        dispenser.locked
    }

    // ============ Read Functions ===========

    public fun get_dispenser_id<C, D: store>(dispenser_cap: &DispenserCap<C, D>): ID {
        dispenser_cap.for
    }
}