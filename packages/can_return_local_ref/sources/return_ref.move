module sui_playground::return_ref {
    use std::vector;

    // This won't work because return_ref's function is ending, and we can't give a reference
    // to a variable that is about to be dropped!
    public fun return_ref(): &vector<u8> {
        &vector::empty()
    }
}