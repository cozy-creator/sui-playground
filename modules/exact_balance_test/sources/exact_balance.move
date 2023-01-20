// 0x9c3cc9999b66afad398eeaf0f2da4923508e0ad1

module sui_playground::exact_balance {
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use sui::sui::SUI;
    use sui::transfer;

    const EINCORRECT_BALANCE: u64 = 0x555;

    public entry fun pay_me(coin: Coin<SUI>, ctx: &mut TxContext) {
        assert!(coin::value(&coin) == 1000, EINCORRECT_BALANCE);

        transfer::transfer(coin, tx_context::sender(ctx));
    }
}