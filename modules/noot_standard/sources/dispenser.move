module noot::dispenser {
    use sui::object::{UID, ID};
    use sui::vec_map::VecMap;
    use sui::tx_context::TxContext;
    use sui::transfer;
    use sui::object;
    use std::vector;
    use std::string::String;

    struct Dispenser<D> has key, store {
        id: UID,
        price: u64,
        treasury_addr: address,
        locked: bool,
        contents: vector<Container<D>>,
    }

    struct Container<D> has store {
        display: VecMap<String, String>,
        body: D
    }

    struct DispenserCap has key, store {
        id: UID,
        for: ID
    }

    // ============ Admin Functions ===========

    public entry fun create_dispenser_<D: store>(dispenser_cap: &DispenserCap, price: u64, treasury_addr: address, ctx: &mut TxContext) {
        let noot_dispenser = create_dispenser<D>(dispenser_cap, price, treasury_addr, ctx);
        transfer::share_object(noot_dispenser);
    }

    public fun create_dispenser<D: store>(dispenser_cap: &DispenserCap, price: u64, treasury_addr: address, ctx: &mut TxContext): Dispenser<D> {
        Dispenser {
            id: object::new(ctx),
            price,
            treasury_addr,
            locked: true,
            contents: vector::empty<Container<D>>()
        }
    }

    public entry fun load_noot_dispenser<D: store>(
        _admin_cap: &DispenserCap, 
        dispenser: &mut Dispenser<D>, 
        display: VecMap<String, String>, 
        body: D, 
        ctx: &mut TxContext)
    {
        vector::push_back(&mut dispenser.contents, Container { display, body });
    }

    public entry fun unload_dispenser_() {}

    public fun unload_dispenser() {}

    public entry fun lock_dispenser() {}

    public entry fun unlock_dispenser() {}

    // ============ User Functions ===========

    public entry fun craft_from_dispenser() {

    }

    // Authority Checking function
    public fun is_correct_dispenser_cap<D: store>(dispenser_cap: &DispenserCap, dispenser: &Dispenser<D>): bool {
        (dispenser_cap.for == object::id(dispenser))
    }
}