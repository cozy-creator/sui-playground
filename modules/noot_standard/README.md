### Terminology

**Noot:** a programmable unit of ownership. (plural: noots)

### Why We Built This

- A standard way to store and display data
- A standard set of market-contracts

**Craft:** accepts inputs, creates and returns a noot.

**Deconstruct:** accepts a noot, destroys it, and then returns any residual output.

**Noot Data:** data pointed to by a Noot.

**Noot DNA:** consists of a display and body.

**Transfer Cap:** a capability scoped to a specific noot. Whoever possess this can take possession of that noot. There is always one and only one transfer_cap per noot.

**Fully Owned Noot:** a noot is 'fully owned' if its transfer_cap is stored inside itself. The noot CANNOT be claimed by any external process.

**Partially Owned Noot:** a noot is 'partially owned' if its transfer_cap is outside of itself. The noot CAN be claimed by an external process.

**Noot Dispenser:** a module that is pre-loaded with a fixed supply of NootDNA. It accepts coins, and returns NootDNA, which is used to craft a Noot.

### Downsides

- Restricted transfering
- NFTs are Shared Objects

### Data Storage

**Data:** We can take two approaches to storing NFT data (1) embedded data, in which the data is stored within the NFT struct itself, or (2) pointer data, in which each NFT merely stores a pointer to an object-id that contains the NFT data. I believe Origin Byte referred to this as "embedded" versus "loosely" packed data. The second approach, pointer-data, is clearly superior, because:

1. **Saves Space:** Many NFTs can point to the same data, saving on expensive on-chain storage. Imagine a use-case where Magic The Gathering wants to issue 100 identical cards; they can create 100 NFTs, and give them out to 100 people, but every NFT points to the same NFTData object, saving on 100x data-duplication, and allowing Magic The Gathering to make any changes to that card in one place. Imagine also an NFT which is a blank-canvas when it's first minted; every user will start out with their NFT pointing to the same blank NFTData object, but as soon as they being to change it, a new NFTData object will be created specifically for them, which the NFT will point to.

2. **Composibility:** The NFT itself is mostly concerned with access-control (who owns what, who can do what) and markets (selling, borrowing / lending), while the NFTData is mostly concerned with saving on-chain state and linking to off-chain state. This creates a separation of concerns that allows for ownership and data to be modified separately.

### Minting

**Mint-time Data Generation:** -

**Pre-Mint:** -

**Lazy Minting:** In thise case, everyone receives the same identical NFT, and then a 'reveal' step happens, where each NFT's data is determined.

### Royalties

**Royalty Address:** In the Metaplex standard on Solana, creators specify a list of royalty addresses and their respective split. For simplicity and composibility, we chose to use only one royalty address; the plan is that later we can create 'fan out' accounts, which will be module-controlled accounts (as opposed to private-key controlled accounts) that will automatically forward funds received to their constituents (i.e., the individual creators in a project). Aptos and Solana already have these, but I'm not sure how to implement this in Sui yet, because of the absence of signer_caps and resource accounts on Sui compared to Aptos.

Now that I think of it, the Metaplex royalty system is pretty dumb; on Solana all royalty-data is duplicated and stored on-chain individually for EVERY NFT (that's 10,000x the storage requirements lol).

**Variable Royalties:** -

### Experimental Ideas:

- Why not split royalty payments between both a seller and a buyer? I.e., if an NFT is for sale for 40 SUI, and the royalty is 10%, then the buyer should pay 42 SUI, and the seller should receive 38 SUI, for a total fee of 4 SUI going to the creators.

### Replacement for the term 'NFT'

'NFT' or 'Non Fungible Token' is pretty dumb; what exactly is a token? And what does it matter if it's not-fungible? Any token I've seen in real life is fungible. And most NFTs are treated as almost fungible. Non-fungibility is probably the LEAST interesting part of an NFT.

What are their interesting parts? They're digital assets that exist in a giant crytographic decentralized network. Their ownership can be verified and transfered. They hold state that can be modified.

I like the term 'property', because that's really what we're going for here. Instead of legal property, they're cryptographic property.

**Tokenized Property:** real-world property whose legal ownership has been turned into a digital representation.

**Digital Property:** property with no corresponding real-world component.

The ownership of this property is enforced through blockchain contracts, rather than through courts and lawyers.

Programmable Virtual Item (PVI)
Ownership As Code (OaC)
Property As Code (PaC)

### To Do

- Move this to its own repo
- Come up with actual data-editing abilities
- Packages: standard, crafting, data, market, examples
- Add the 'Buy offer' functionality
- Abstract Outlaw Sky to be an inventory-generator
- Show example implementation with different royalties
- Think about auctions
- Build an open-market
- Implement actual randomness
- Perhaps the market should define the transfer cap of a noot?
- The Sui core includes a url standard with has commits of content; that could be useful. Perhaps integrate that
- See if we can transfer a Noot from being part of market-A to market-B. This would be ideal for closing or opening transfer abilities of a noot (even within the same type).
- For extract_owner_cap, perhaps we should drop the is_owner requirement; what if we want some markets to be able to take transfer_caps, even without the owner's consent???
- Perhaps type-info should have 'store', so that it can be shared as well? It might be useful to give type-info to programs so that they can edit type-info arbitrarily; for example, suppose type-info is being controlled by a module rather than a person (keypair)

### Problems to Solve

- on-chain metadata should be compact. However, how do we turn that metadata into a human-readable format? My suggestion is to have some sort of ancilliary off-chain functions (typescript perhaps) that map on-chain data into human-readable strings

### Definitions

Noot: a unit of ownership on a cryptographic ledger

### Exploits

- **Royalty Bypass:** the concept is that someone deploys a module which wraps a noot transfer function with their own custom marketplace function, so that either marketplace royalties are not paid, or they are paid to the wrong party.

- **Skipping Randomness:** the concept is that someone deploys a module which crafts a randomly-generated noot, and then checks to see if that noot has the desired property that they're farming for; if it doesn't, then they abort the transaction. The net result is that they can do thousands of transactions for just the cost of gas until they manage to get the desired noot, regardless of how improbable the noot is.
