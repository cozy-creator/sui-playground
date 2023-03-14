module sui_playground::structdd {
    struct Struct has store, copy, drop {}

    public fun do_something(struct: Struct) {
    }
}