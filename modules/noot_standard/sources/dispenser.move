module noot::dispenser {
    use sui::object::{UID, ID};
    use sui::vec_map::VecMap;
    use sui::tx_context::TxContext;
    use sui::transfer;
    use sui::object;
    use std::vector;
    use std::string::String;

    struct NootDNA<D> has store {
        display: VecMap<String, String>,
        body: D
    }

    struct NootDispenser<D> has key, store {
        id: UID,
        price: u64,
        treasury_addr: address,
        locked: bool,
        contents: vector<NootDNA<T, D>>,
    }

    struct DispenserCap<phantom T> has key, store {
        id: UID,
        for: ID
    }

    public entry fun create_dispenser_<T: drop, D>(dispenser_cap: &DispenserCap<T>, price: u64, treasury_addr: address, ctx: &mut TxContext) {
        let noot_dispenser = create_dispenser<T, D>(dispenser_cap, price, treasury_addr, ctx);
        transfer::share_object(noot_dispenser);
    }

    public fun create_dispenser<T, D>(dispenser_cap: &DispenserCap<T>, price: u64, treasury_addr: address, ctx: &mut TxContext): NootDispenser<T, D> {
        NootDispenser {
            id: object::new(ctx),
            price,
            treasury_addr,
            locked: true,
            contents: vector::empty<NootDNA<T, D>>()
        }
    }

    public entry fun load_noot_dispenser<D>(_admin_cap: &AdminCap, dispenser: &mut NootDispenser, display: , body: D, ctx: &mut TxContext) {

        vector::push_back(&mut dispenser.contents, noot_dna);
    }

    public entry fun unload_noot_dispenser_() {}

    public fun unload_noot_dispenser() {}

    public entry fun lock_dispenser() {}

    public entry fun unlock_dispenser() {}

    public fun is_correct_dispenser_cap<T>(dispenser_cap: &DispenserCap<T>, dispenser: &Dispenser<T>): bool {
        (dispenser_cap.for == object::id(dispenser))
    }
}