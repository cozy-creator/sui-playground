Object: 0xc6f1b6c947192001773023c4e250b604c67bcac0

`export SUI_RPC_HOST='https://fullnode.devnet.sui.io:443'`

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_batchTransaction",
"params": [
"0xbb81965d327c51d42d1081e5d81909652f05a675",
[
{
"moveCallRequestParams": {
"packageObjectId": "0x0553ffe2781ccb9fe3007ecb255a0063be3f0efe",
"module": "view",
"function": "view3",
"typeArguments": [],
"arguments": []
}
}
],
"0x4c80b31ce41f4b698aafc49c0f2ba78777d7e900",
2000,
"DevInspect"
]
}'

`AQECBVP/4ngcy5/jAH7LJVoAY74/Dv4EdmlldwV2aWV3MwAAu4GWXTJ8UdQtEIHl2BkJZS8FpnVMgLMc5B9LaYqvxJwPK6eHd9fpAJkWAAAAAAAAINF72emYDTjY7YVn83oy8vM9geYvjITq0OsnDkAmilNCu4GWXTJ8UdQtEIHl2BkJZS8FpnUBAAAAAAAAANAHAAAAAAAA`

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectTransaction",
"params": [
"0xbb81965d327c51d42d1081e5d81909652f05a675",
"AQECBVP/4ngcy5/jAH7LJVoAY74/Dv4EdmlldwV2aWV3MwAAu4GWXQ=="
]
}' | json_pp
