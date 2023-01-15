This recreates the Diem / Aptos account model, complete with global storage operators and module authority.

Aptos uses a **weak ownership** model. These are the permissions required for each action:

| Action   | Owner | Module |
| -------- | ----- | ------ |
| Deposit  | Y     | Y      |
| Read     | N     | Y      |
| Write    | N     | Y      |
| Withdraw | N     | Y      |

The module has almost unilateral control over the asset, only requiring owner-consent for deposits.

Meanwhile, this is Sui's system-level ownership; it follows a **strong ownership** model:

| Action   | Owner | Module |
| -------- | ----- | ------ |
| Deposit  | N     | N\*    |
| Read     | Y     | Y      |
| Write    | Y     | Y      |
| Withdraw | Y     | N\*    |

\*Note: if the asset has `key + store`, its ownership can be transferred using the system-level command sui::transfer::transfer, without any constent from the module. With just `key` the sui::transfer::transfer can only be called from within the Module, meaning the module's permission is now required for a transfer; the module must expose its own custom transfer-api.

For reading and writing, module-authority is still required, because only the module can access the asset's fields.

Capsule Plan:

| Action                         | Owner | Module | Transfer |
| ------------------------------ | ----- | ------ | -------- |
| Write Metadata                 | Y     | Y      | N        |
| Migrate or Eject Module Auth   | Y     | Y      | N        |
| Migrate or Eject Transfer Auth | N     | N      | Y        |
| Transfer                       | N     | N      | Y        |
| Place Asset in Capsule         | N/A\* | N/A    | N/A      |
| Borrow asset from Capsule      | Y     | N      | N        |
| Borrow mut asset from Capsule  | Y     | N      | N        |
| Remove Asset From Capsule      | N     | N      | Y        |

\*N/A because gaining the asset by value is sufficient permission to be able to wrap it inside of a capsule; no ownership permission is required.

Defaults if not set:

- Ownership defaults to true (anything is permitted)
- Module defaults to true (anything is permitted)
- Transfer defaults to false (everything is prohibited)

## LSO: Local Storage Operator - Diem Throwback

This is just a fun module meant to be a throwback to the good old days of Diem!

In Diem, you had these crazy powerful global storage operators; you would specify:
`borrow_global<T>(addr)`
which would reach into the specified address and pull out the object T at addr (if it exists).

This operation was subject to the following rules:

1. an address can only possess one T at a time
2. operators can only be used on T from within T's declaring module
3. move_to(address) required a signature from address; all other operators did not

Rule #3 means it was impossible to 'clog up' someone else's storage without their authorization by putting an object T at their address. This also gave modules god-like power over their own resources, in that if they declared T they could grab any T in existence, even without the owner's signature, and do whatever they want, including modifying and destroying T.

In Diem, intra-validator partitioning would have been done by module + module's types.

Sui eliminated these operators. Sui intra-validator partitioning will likely be done based on object-id and child objects of that id. This should make parallelization easier.

LSO (Local Storage Operator) replicates Diem's old API. Instead of grabbing items from global storage based on address, it grabs items from local storage based on object O's id (address).

It is subject to the following rules:

1. object O can only possess one T at a time
2. caller must have access to the O's UID

Rule #2 means that the caller is either O's declaring module, or O's declaring module exposed some ability for external functions to obtain O's UIDs.

Note that I had to change the function names slightly because the old names are still reserved by the Move VM.
