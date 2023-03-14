sui client call --package 0x0296322a7657c74008c9b6a9e9d34c9fef9f3c65 --module cli_args --function simple --args b"[254, 199999]" --gas-budget 4000

My current understanding is that the Sui CLI has NO WAY to serialize heterogenous types as an array, i.e., it cannot do

`[15u8, 65536u64, 512u16] = vector<vector<u8>> = [ [15], [0, 0, 1, ..], [0, 2] ]`

this would take the arguments, annotated with their types, and turn them each into the correct `vector<u8>`.
