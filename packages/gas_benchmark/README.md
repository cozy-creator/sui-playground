### Publish Module:

sui client publish --gas-budget 1300

### creation function:

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark --function create_owned --args "Hello World" --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark --function create_shared --args "Hello World" --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

### edit function:

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark --function edit_owned --args 0x8d0da0d0e81e817aa9fbf7e5a806e5d17c595e91b4497cb2b4abac3dc14d795f "New World" --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark --function edit_shared --args 0xe46bf7a78a25772c358694efbd31b643554ab8aaf77d7cecf5a50b0445a4770e "New World" --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark --function delete_owned --args 0xf5969a7b93334f02a32118b452cd7f48750633c8c0aa0c65cccd1bff02fa4e9d --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

### create many:

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark --function create_many_owned --args "Lots of people here" 10 --gas-budget 4001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark --function create_many_shared --args "Lots of people here" 10 --gas-budget 4001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

---

### Event broadcasts

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark_events --function create_owned --args "Hello World" --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark_events --function create_shared --args "Hello World" --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

### edit function:

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark_events --function edit_owned --args 0x8d0da0d0e81e817aa9fbf7e5a806e5d17c595e91b4497cb2b4abac3dc14d795f "New World" --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark_events --function edit_shared --args 0xe46bf7a78a25772c358694efbd31b643554ab8aaf77d7cecf5a50b0445a4770e "New World" --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark_events --function delete_owned --args 0xf5969a7b93334f02a32118b452cd7f48750633c8c0aa0c65cccd1bff02fa4e9d --gas-budget 2001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

### create many:

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark_events --function create_many_owned --args "Lots of people here" 10 --gas-budget 4001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

sui client call --package 0x936608e1d75ac167706b0730bbe5770bd0097f005ec978b7549112931c2abc7c --module gas_benchmark_events --function create_many_shared --args "Lots of people here" 10 --gas-budget 4001000 --gas 0x0a8f821267fb5a6a002cc54633d10ab206a42a2e2ec7656ad251033ba79a091a

---

### Gas Benchmarks v0.29 (devnet)

- I think there's a minimum 1,000 gas fee per transaction
- Events emits and structs are free (why?)
- Sending a 'delete' transaction gives you a storage refund, but it costs more to do the transaction than you get in refund (unless it was a very large object)
- There is a large fixed per-transaction cost. It's more economical to make 100 objects in a single transaction (cost: 7k) versus doing 100 transactions to create 100 objects (cost: 100k)
- You cannot broadcast more than 256 events in a single transaction

Publish: 1,267
Create Owned: 1,019 (1.1 seconds)
Create Shared: 1,019 (1.5 - 25 seconds) - weird!
Edit Owned: 1,000 (3 - 7 seconds)
Edit Shared: 1,000 (3 - 9 seconds)
Delete Owned: 981 (5 seconds)

Create 10 Owned: 1,200 (1.1 - 2 seconds)
Create 10 Shared: 1,200 (1.1 seconds)

Create 100 Owned: 7,000 (2 - 6 seconds)

### Gas Benchmarks v0.29 (testnet)

Same as above, except multiply it by 1,000. Except for some constants

Create 10 Owned: 1,000,200
Create 100 Owned: 5,002,000 (supposed to be 7k)
Create 255 Owned: 10,005,100 (supposed to be 15k)
Create 512 Owned: 20,010,260 (supposed to be 30k)
Create 1000 Owned: 50,020,000 (supposed to be 70k) (0.05 SUI)

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

### v0.29 Devnet Costs

Publish sui_utils: 6,613 nanoSUI
