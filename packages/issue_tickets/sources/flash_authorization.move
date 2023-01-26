module sui_playground::flash_authorization {
    use sui::object::{Self, ID};
    use sui::tx_context::TxContext;
    use sui_playground::function_key::{Self, Noot};

    const OWNER: u64 = 0;

    const ENO_PERMISSION: u64 = 0;
    const EWRONG_HOT_POTATO: u64 = 1;

    struct HotPotato { for: ID, user: address }

    public fun borrow_authority(noot: &mut Noot, user: address, permissions: vector<bool>, ctx: &mut TxContext): (HotPotato) {
        assert!(function_key::check_permission(noot, ctx, OWNER), ENO_PERMISSION);
        function_key::add_authorization(noot, user, permissions, ctx);

        HotPotato { for: object::id(noot), user }
    }

    public fun return_authority(noot: &mut Noot, hot_potato: HotPotato, ctx: &mut TxContext) {
        let HotPotato { for, user } = hot_potato;
        assert!(for == object::id(noot), EWRONG_HOT_POTATO);

        function_key::remove_authorization(noot, user, ctx);
    }
}