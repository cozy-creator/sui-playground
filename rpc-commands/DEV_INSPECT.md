package_id: 0x206de30a2cf43ba63a9c705616a4f1f94105d7ba

### Step 1: Save a variable to save us time

`export SUI_RPC_HOST='https://fullnode.devnet.sui.io:443'`

### Step 2: Send the Transaction

**Returns String**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573f",
"0x206de30a2cf43ba63a9c705616a4f1f94105d7ba",
"dev_inspect",
"read_name",
[],
["0xa17e506b4f9458f9ea8f0d402c23abaaac67b235"]
]
}' | json_pp

**Aborts**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0x6bd5de4ee95bd5d8e29d20e72967fc9ef4df63ba",
"dev_inspect",
"failure",
[],
[]
]
}' | json_pp

**Two Person Test**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xcfa264df217d51ee022ec030af34b0b8a6288155",
"dev_inspect",
"two_users",
[],
["0x7a8d1efeb109ca89c8a4196ef26ae579f12875d7", "0xfddbf0ca367bb4a960ffcc4d8c532e49d2ff56e8"]
]
}' | json_pp

**Multi-Output**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xcfa264df217d51ee022ec030af34b0b8a6288155",
"dev_inspect",
"multi_output",
[],
[]
]
}' | json_pp

**Struct Output**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xcfa264df217d51ee022ec030af34b0b8a6288155",
"dev_inspect",
"struct_output",
[],
[]
]
}' | json_pp

**Vector Output**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xe46cffe5306d7bca67f24b69b4cdd0d829d17a21",
"dev_inspect",
"vector_output",
[],
[]
]
}' | json_pp

**Dynamic Fields Output**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xe46cffe5306d7bca67f24b69b4cdd0d829d17a21",
"dev_inspect",
"dynamic_fields",
[],
[]
]
}' | json_pp

**optional Field Output**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xb52bdc39d39857276ec6f1cd897f153c7bd490a9",
"dev_inspect",
"optional",
[],
[]
]
}' | json_pp

**UID test Output**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xd922e9d683d8d7d40ee24f1d30751d955aba8423",
"dev_inspect",
"give_uid",
[],
["0x7af6b97b06594721525c5c55783f5ec767e9350c"]
]
}' | json_pp

**Test Optionals**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xc0558bb882142cb732d7860e4e94123c4f76dc08",
"optionals",
"return_option",
[],
[]
]
}' | json_pp

**Test Optionals Again**

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xb4962ad63d93797cc31d88413b7d13a93999bdb9",
"optionals",
"test_bcs",
[],
[]
]
}' | json_pp

**Rick Setup**
**First Create a Rick**

sui client call --package 0x6c804f584c49da2d82e999c0bda472cfb6327e00 --module rick --function create_rick --args 0x7be11365227351a591c46ac7a744973c0296a854 --gas-budget 3000

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0x6c804f584c49da2d82e999c0bda472cfb6327e00",
"rick",
"view",
[],
["0xc53b2a7389f5920a9346693f56d751ae380f5cc3", "0x7be11365227351a591c46ac7a744973c0296a854"]
]
}' | json_pp

outputs something like:

                            4, <-- number of items
                           13, <-- length of first item
                           1, <--  exists optional
                           82, <-- first ascii character
                           105,
                           99,
                           107,
                           32,
                           83,
                           97,
                           110,
                           99,
                           104,
                           101,
                           122,

                           2, <<-- length of second item
                           1,
                           70,

                           9, <-- length of third item
                           1,
                           97,
                           5,
                           0,
                           0,
                           0,
                           0,
                           0,
                           0,

                           1, <-- length of final item
                           0 <-- does not exist optional

Next to do:

- Store items on-chain using their specified types; this makes things easier for explorers

- use the sui_getDynamicFields

- Try bcs size comparison
- Does bcs take into account dynamic fields? We'll see
