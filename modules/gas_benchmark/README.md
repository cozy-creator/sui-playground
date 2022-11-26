publish this module:
`sui client publish --gas-budget 1000`

call creation function:

`sui client call --package 0x1c273aad9d65a09f83f147f107eb349bcf8613fc --module gas_benchmark --function create_owned --args b"Hello World" --gas-budget 1000`

call edit function:

`sui client call --package 0x1c273aad9d65a09f83f147f107eb349bcf8613fc --module gas_benchmark --function edit_owned --args 0x9ff1a0a752b671b8fa02578120915fe42fca70e9 "Hello World" --gas-budget 1000`

`sui client call --package 0x1c273aad9d65a09f83f147f107eb349bcf8613fc --module gas_benchmark --function edit_shared --args 0xf3c42885512dc2ac8fc83c2f1b76a47f82646695 b"Hello World" --gas-budget 1000`

### Observed gas benchmarks

- deploying this module: 563
- transfer a gas-object: 61

### Owned VS Shared

Data: "Hello World", stored as vec

- create owned: 80 gas, 1.9 seconds
- created shared: 68 gas, 1.8 seconds
- edit owned: 49 gas, 1.8 seconds
- edit shared: 149 gas, 4.5 - 10 seconds (average around 6 seconds)

Data: "Hello World", stored as string

- create owned: 87 gas, 1.9 seconds
- create shared: 74 gas, 1.9 seconds
- edit owned: 56 gas, 1.9 seconds
- edit shared: 156 gas

Data: Large wikipedia paragraph

- edit owned: 316, 1.9 seconds
- edit shared: 416 gas, 5.8 seconds

- Large 20 KB edits: about 2,600 gas

Note: after deleting a large article (replacing 20 KBs with 1 KBs) you get a gas refund, of something like -53 gas, which is pretty cool.

### Sui Precision Decimals

1,000,000,000 nano-SUI = 1 SUI
10,000,000 nano-SUI = .001 SUI
