module openrails::outlaw_sky {
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use openrails::nft_standard;

    struct OUTLAW_SKY has drop {}

    fun init(witness: OUTLAW_SKY, ctx: &mut TxContext) {
        let addr = tx_context::sender(ctx);

        let (royalty_cap, mint_cap) = nft_standard::create_collection<OUTLAW_SKY>(witness, ctx);

        transfer::transfer(royalty_cap, addr);
        transfer::transfer(mint_cap, addr);
    }

    public entry fun mint() {
        
    }
}