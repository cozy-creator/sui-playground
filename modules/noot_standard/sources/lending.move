module noot::lending {
    struct ReclaimCapability<phantom T> has key, store {
        id: UID,
        transfer_cap: TransferCap<T>
    }
}