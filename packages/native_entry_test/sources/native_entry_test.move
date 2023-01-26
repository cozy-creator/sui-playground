module sui_playground::native_entry_test {
    use sui::object::{Self, UID};

    public entry fun something(_d: address, id: UID) {
        object::delete(id);
    }
}