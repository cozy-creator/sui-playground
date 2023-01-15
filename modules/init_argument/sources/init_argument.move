// It is not possible to include arguments in init functions

module sui_playground::init_argument {
    use sui::object::UID;
    use sui::tx_context::TxContext;

    struct Something has key {
        id:UID
    }

    struct INIT_ARGUMENT has drop {}

    fun init(_something: &mut Something, _ctx: &mut TxContext) {
    }
}