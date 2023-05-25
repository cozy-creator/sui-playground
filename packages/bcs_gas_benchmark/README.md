vector<u8>

12 times

[ 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101]

vector<vector<u8>>

[ [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101] ]

`sui client call --package 0x3751059c543c1443455c3ca168c29b196a63804a --module bcs_gas_benchmark --function free_utf8 --args "[ 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101, 5, 75, 121, 114, 105, 101]" --gas-budget 10000`

`sui client call --package 0x3751059c543c1443455c3ca168c29b196a63804a --module bcs_gas_benchmark --function free_ascii --args "[ [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101] ]" --gas-budget 10000`

sui client call --package 0x3751059c543c1443455c3ca168c29b196a63804a --module bcs_gas_benchmark --function parsed_utf8 --args "[ [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101], [5, 75, 121, 114, 105, 101] ]" --gas-budget 10000

sui client call --package 0x942f9c95643a061abc9b9febffe34a7b5f256cfb --module bcs_gas_benchmark --function dynamic_field_1 --gas-budget 10000

RESULTS on Testnet 2:

113k nanoSUI for BCS
80k nanoSUI for parsed
25k nanoSUI for UTF8

kind of insane to me still that utf8 is 3x cheaper than ascii lol

### RESULTS on Devnet 0.27:

bcs deserialize: 1,147 nanoSUI
parsed deserialize: 811 nanoSUI
parsed deserialize + utf8: 259 nanoSUI
free ascii and free utf8: 142 nanoSUI (you don't get charged for the conversion; it really is free)

dynamic field simple (10 objects): 582 nanoSUI
dynamic field complex (10 objects): 1,262 nanoSUI
dynamic field utf8 (10 objects): 723 nanoSUI

We can have a full 10 child objects inside of an object for under 1k nanoSUI.

### Benchmarking in production:

- devnetNFT: 517 nanoSUI
- demo factory: 2,514 nanoSUI (1 child object)
- outlaw-sky demo: 5,118 nanoSUI (9 child objects)

### v0.30 Testnet

- dynamic-field no key (1): 3.73m
- dynamic-field with key (1): 4.15m
- dynamic-field no key (20): 30.5m
- dynamic-field with key (20): 37.9m
- dynamic-field no key (100): 143.3m
- dynamic-field with key (100): 184.2m

The key-pattern adds a 29% penalty to creating fields.
A dynamic-field costs around 1.43m - 1.53m nanoSUI to create
