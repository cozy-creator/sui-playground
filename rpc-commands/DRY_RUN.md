module: 0xff68a93786651eb0a3025df2601a434d34360673::dry_run::call_me

### Step 1: Set the txBytes

`export SUI_RPC_HOST='https://fullnode.devnet.sui.io:443'`

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"method": "sui_moveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"0xff68a93786651eb0a3025df2601a434d34360673",
"dry_run",
"call_me",
[],
[],
"0xc5bf42f9331c28add838e5383c85392896fdebc0",
1000
],
"id": 1
}' | json_pp

txBytes: VHJhbnNhY3Rpb25EYXRhOjoAAv9oqTeGZR6wowJd8mAaQ000NgZzAQAAAAAAAAAgB157wIkZLg0WPglQvLiOYuKE/l2UIWZnP3Plvcrz2V8HZHJ5X3J1bgdjYWxsX21lAACB3J8trf3SioSBd6/Ys4tyh/dXPsW/QvkzHCit2DjlODyFOSiW/evAAQAAAAAAAAAgoaEAcIdLE5V8ERe/ypSCDupmKUbVx/v6b95rp2wGJpYBAAAAAAAAAOgDAAAAAAAA

### Step 2: Sign the txBytes

sui keytool sign --data VHJhbnNhY3Rpb25EYXRhOjoAAv9oqTeGZR6wowJd8mAaQ000NgZzAQAAAAAAAAAgB157wIkZLg0WPglQvLiOYuKE/l2UIWZnP3Plvcrz2V8HZHJ5X3J1bgdjYWxsX21lAACB3J8trf3SioSBd6/Ys4tyh/dXPsW/QvkzHCit2DjlODyFOSiW/evAAQAAAAAAAAAgoaEAcIdLE5V8ERe/ypSCDupmKUbVx/v6b95rp2wGJpYBAAAAAAAAAOgDAAAAAAAA --address 0x81dc9f2dadfdd28a848177afd8b38b7287f7573e

signature: 0k4y8yDjEobvTVgnkImqOqrcJGaSAh1s562WhB/Oi3J0/TfwSi8vJWpkbuDll/Srn1CQnXAyU3dInEmSqvctBA==

### Step 3: Submit the transaction

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_dryRunTransaction",
"params": [
"VHJhbnNhY3Rpb25EYXRhOjoAAv9oqTeGZR6wowJd8mAaQ000NgZzAQAAAAAAAAAgB157wIkZLg0WPglQvLiOYuKE/l2UIWZnP3Plvcrz2V8HZHJ5X3J1bgdjYWxsX21lAACB3J8trf3SioSBd6/Ys4tyh/dXPsW/QvkzHCit2DjlODyFOSiW/evAAQAAAAAAAAAgoaEAcIdLE5V8ERe/ypSCDupmKUbVx/v6b95rp2wGJpYBAAAAAAAAAOgDAAAAAAAA"
]
}' | json_pp

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_executeTransaction",
"params": [
"VHJhbnNhY3Rpb25EYXRhOjoAAv9oqTeGZR6wowJd8mAaQ000NgZzAQAAAAAAAAAgB157wIkZLg0WPglQvLiOYuKE/l2UIWZnP3Plvcrz2V8HZHJ5X3J1bgdjYWxsX21lAACB3J8trf3SioSBd6/Ys4tyh/dXPsW/QvkzHCit2DjlODyFOSiW/evAAQAAAAAAAAAgoaEAcIdLE5V8ERe/ypSCDupmKUbVx/v6b95rp2wGJpYBAAAAAAAAAOgDAAAAAAAA",
"ED25519",
"0k4y8yDjEobvTVgnkImqOqrcJGaSAh1s562WhB/Oi3J0/TfwSi8vJWpkbuDll/Srn1CQnXAyU3dInEmSqvctBA==",
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573e",
"WaitForLocalExecution"
]
}' | json_pp
