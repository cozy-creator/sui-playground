module sui_playground::cadence_clone {
    use sui::object::UID;

    // Step 1: store all objects as dynamic fields inside of an 'Account'
    // Assign a keypair, which can modify this (add, borrow, borrow_mut, borrow_value, remove)
    struct Account has key {
        id: UID,
        keypair: address
    }

    public fun add() {

    }

    public fun remove() {

    }

    // Step 2: Define an interface, which restricts which fields and methods can be accessed
    // for an object

    // Step 3: Create 'capabilities'; this is a record that points to an object inside of the
    // Account, and specifies an interface for it. If it's public, a caller can obtain a mutable reference
    // to the stored object, subject to the specified interface.

    struct Capability<phantom T> has copy, drop {

    }

    // public fun link<T>(path, )
}