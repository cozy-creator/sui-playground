module sui_playground::dry_run {
    public entry fun call_me() {
        return_value();
    }

    public fun return_value(): u64 {
        15
    }
}