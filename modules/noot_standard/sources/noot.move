module noot::noot {
    use sui::object::{Self, ID, UID};
    use std::option::{Self, Option};
    use sui::tx_context::{TxContext};
    use sui::transfer;
    use sui::vec_map::{Self, VecMap};
    use std::string::String;

    const EBAD_WITNESS: u64 = 0;
    const ENOT_OWNER: u64 = 1;
    const ENO_TRANSFER_PERMISSION: u64 = 2;
    const EINSUFFICIENT_FUNDS: u64 = 3;

    // Do not add 'store' to Noot or NootData. Keeping them non-storable means that they cannot be
    // transferred using polymorphic transfer (transfer::transfer), meaning the market can define its
    // own transfer function.
    // Unbound generic type
    struct Noot<phantom T> has key {
        id: UID,
        owner: option::Option<address>,
        data_id: option::Option<ID>,
        transfer_cap: option::Option<TransferCap<T>>
    }

    // TODO: Replace VecMap with a more efficient data structure once one becomes a available within Sui
    // VecMap only has O(N) lookup time
    struct NootData<phantom T, D: store> has key {
        id: UID,
        display: VecMap<String, String>,
        body: D
    }

    struct TransferCap<phantom T> has store {
        for: ID
    }

    struct NootTypeInfo<phantom T> has key {
        id: UID,
        display: VecMap<String, String>
    }

    // === Events ===

    // TODO: add events

    // === Admin Functions, for Noot Creators ===

    // A module will define a noot type, using the witness pattern. This is a droppable
    // type

    // Create a new collection type `T` and return the `CraftingCap` and `RoyaltyCap` for
    // `T` to the caller. Can only be called with a `one-time-witness` type, ensuring
    // that there will only ever be one of each cap per `T`.
    public fun create_collection<W: drop, T: drop>(
        one_time_witness: W,
        _witness: T, 
        ctx: &mut TxContext
    ): NootTypeInfo<T> {
        // Make sure there's only one instance of the type T
        assert!(sui::types::is_one_time_witness(&one_time_witness), EBAD_WITNESS);

        // TODO: add events
        // event::emit(CollectionCreated<T> {
        // });

        NootTypeInfo<T> {
            id: object::new(ctx),
            display: vec_map::empty<String, String>()
        }
    }

    // Once the CraftingCap is destroyed, new dItems cannot be created within this collection
    // public entry fun destroy_crafting_cap<T>(crafting_cap: CraftingCap<T>) {
    //     let CraftingCap { id } = crafting_cap;
    //     object::delete(id);
    // }

    public entry fun craft_<T: drop, D: store>(witness: T, send_to: address, data: &NootData<T, D>, ctx: &mut TxContext) {
        let noot = craft(witness, option::some(send_to), data, ctx);
        transfer::transfer(noot, send_to);
    }

    public fun craft<T: drop, D: store>(_witness: T, owner: Option<address>, data: &NootData<T, D>, ctx: &mut TxContext): Noot<T> {
        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);

        Noot<T> {
            id: uid,
            owner: owner,
            data_id: option::some(object::id(data)),
            transfer_cap: option::some(TransferCap<T> {
                for: id
            })
        }
    }

    public fun create_data<T: drop, D: store>(_witness: T, display: VecMap<String, String>, body: D, ctx: &mut TxContext): NootData<T, D> {
        NootData {
            id: object::new(ctx),
            display,
            body
        }
    }

    public fun borrow_data_body<T: drop, D: store>(_witness: T, noot_data: &mut NootData<T, D>): &mut D {
        &mut noot_data.body
    }

    // === User Functions, for Noot Holders ===

    public fun transfer_and_fully_own<T: drop>(
        new_owner: address, 
        noot: &mut Noot<T>, 
        transfer_cap: TransferCap<T>) 
    {
        transfer_with_cap(&transfer_cap, noot, new_owner);
        option::fill(&mut noot.transfer_cap, transfer_cap);
    }

    // transfer_cap does not have key, so this cannot be used as an entry function
    public fun transfer_with_cap<T: drop>(transfer_cap: &TransferCap<T>, noot: &mut Noot<T>, new_owner: address) {
        assert!(is_correct_transfer_cap(transfer_cap, noot), ENO_TRANSFER_PERMISSION);
        noot.owner = option::some(new_owner);
    }

    // This prevents an inconsistent state; if the noot is in single-writer mode, an external module could
    // transfer the noot and allow noot.owner to become inconsistent with its Sui-defined owner
    public fun transfer<T: drop>(_witness: T, noot: Noot<T>, new_owner: address) {
        noot.owner = option::some(new_owner);
        transfer::transfer(noot, new_owner);
    }

    public fun transfer_data<T: drop, D: store>(_witness: T, noot_data: NootData<T, D>, new_owner: address) {
        transfer::transfer(noot_data, new_owner);
    }

    public fun share_data<T: drop, D: store>(_witness: T, noot_data: NootData<T, D>) {
        transfer::share_object(noot_data);
    }

    // === Authority Checking Functions ===

    public fun is_owner<T>(addr: address, noot: &Noot<T>): bool {
        if (option::is_some(&noot.owner)) {
            *option::borrow(&noot.owner) == addr
        } else {
            true
        }
    }

    public fun is_correct_data<T, D: store>(noot: &Noot<T>, noot_data: &NootData<T, D>): bool {
        if (option::is_none(&noot.data_id)) {
            return false
        };
        let data_id = option::borrow(&noot.data_id);
        (data_id == &object::id(noot_data))
    }

    public fun is_fully_owned<T>(noot: &Noot<T>): bool {
        option::is_some(&noot.transfer_cap)
    }

    public fun is_correct_transfer_cap<T>(transfer_cap: &TransferCap<T>, noot: &Noot<T>): bool {
        transfer_cap.for == object::id(noot)
    }
}