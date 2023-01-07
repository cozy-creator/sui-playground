`export SUI_RPC_HOST='https://gateway.devnet.sui.io:443'`

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{ "jsonrpc":"2.0",
"method":"sui_transferObject",
"params":["0x94501bf9ba83f8c8467b820bd5e38183d2aca15c",
"0xe066c6de11f4d34276ea2a00c92c48458c588bc0",
"0xe9b13348621ded19211e7984d30516df955af4f9",
1000,
"0xed2c39b73e055240323cf806a7d8fe46ced1cabb"],
"id":1}' | json_pp

txBytes = VHJhbnNhY3Rpb25EYXRhOjoAAO0sObc+BVJAMjz4BqfY/kbO0cq74GbG3hH000J26ioAySxIRYxYi8ABAAAAAAAAACDDjVzzJwWLqVVAKj+NMKIdv+QHhESibrvcF/kQgzasCpRQG/m6g/jIRnuCC9XjgYPSrKFc6bEzSGId7RkhHnmE0wUW35Va9PkBAAAAAAAAACCcAxPcAxqd1NxLhPEiIBClCVmp83uxL4s+As5R2InTsgEAAAAAAAAA6AMAAAAAAAA=

pubkey base64: WGWR7QO5mUHeVagOHC/XzbVf4GvUuljZ2ls6pZ/M6+o=
signature: 0HusLaZ0aFtVhLMaQCDGhi4qXgYJcl/kuYiGBkvao2c8T8fq6SYQSApMrkWMpmjZteMl1odjB4gFPN/5XojQCQ==

### Execute the command

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_executeTransaction",
"params": [
"VHJhbnNhY3Rpb25EYXRhOjoAAO0sObc+BVJAMjz4BqfY/kbO0cq74GbG3hH000J26ioAySxIRYxYi8ABAAAAAAAAACDDjVzzJwWLqVVAKj+NMKIdv+QHhESibrvcF/kQgzasCpRQG/m6g/jIRnuCC9XjgYPSrKFc6bEzSGId7RkhHnmE0wUW35Va9PkBAAAAAAAAACCcAxPcAxqd1NxLhPEiIBClCVmp83uxL4s+As5R2InTsgEAAAAAAAAA6AMAAAAAAAA=",
"ED25519",
"0HusLaZ0aFtVhLMaQCDGhi4qXgYJcl/kuYiGBkvao2c8T8fq6SYQSApMrkWMpmjZteMl1odjB4gFPN/5XojQCQ==",
"WGWR7QO5mUHeVagOHC/XzbVf4GvUuljZ2ls6pZ/M6+o=",
"WaitForEffectsCert"
]
}'

### Success

{"jsonrpc":"2.0",
"result":{"certificate":{"transactionDigest":"YLKdjCyARyZjoGS/ggn5AHGW/nLFqPZjIvKYMlfqNJE=","data":{"transactions":[{"TransferObject":{"recipient":"0xed2c39b73e055240323cf806a7d8fe46ced1cabb","objectRef":{"objectId":"0xe066c6de11f4d34276ea2a00c92c48458c588bc0","version":1,"digest":"w41c8ycFi6lVQCo/jTCiHb/kB4REom673Bf5EIM2rAo="}}}],"sender":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c","gasPayment":{"objectId":"0xe9b13348621ded19211e7984d30516df955af4f9","version":1,"digest":"nAMT3AMandTcS4TxIiAQpQlZqfN7sS+LPgLOUdiJ07I="},"gasBudget":1000},"txSignature":"ANB7rC2mdGhbVYSzGkAgxoYuKl4GCXJf5LmIhgZL2qNnPE/H6ukmEEgKTK5FjKZo2bXjJdaHYweIBTzf+V6I0AlYZZHtA7mZQd5VqA4cL9fNtV/ga9S6WNnaWzqln8zr6g==","authSignInfo":{"epoch":0,"signature":"qmm1xPJXLY6+A75imAc0d1JVC/L53lM1yW4DxmUJ1NqzI1SwTfpyEXbydT+bLqXk","signers_map":[58,48,0,0,1,0,0,0,0,0,2,0,16,0,0,0,0,0,2,0,3,0]}},"effects":{"status":{"status":"success"},"gasUsed":{"computationCost":50,"storageCost":41,"storageRebate":41},"transactionDigest":"YLKdjCyARyZjoGS/ggn5AHGW/nLFqPZjIvKYMlfqNJE=","mutated":[{"owner":{"AddressOwner":"0xed2c39b73e055240323cf806a7d8fe46ced1cabb"},"reference":{"objectId":"0xe066c6de11f4d34276ea2a00c92c48458c588bc0","version":2,"digest":"CAbcazk+PqmJHAbogxL0TPrtbA9r4KODimHnqYfALko="}},{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0xe9b13348621ded19211e7984d30516df955af4f9","version":2,"digest":"IcYhubYLl333/sofRGhtgrqwsYuV+0qgGvENIeWdONc="}}],"gasObject":{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0xe9b13348621ded19211e7984d30516df955af4f9","version":2,"digest":"IcYhubYLl333/sofRGhtgrqwsYuV+0qgGvENIeWdONc="}},"events":[{"transferObject":{"packageId":"0x0000000000000000000000000000000000000002","transactionModule":"native","sender":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c","recipient":{"AddressOwner":"0xed2c39b73e055240323cf806a7d8fe46ced1cabb"},"objectId":"0xe066c6de11f4d34276ea2a00c92c48458c588bc0","version":2,"type":"Coin","amount":null}}],"dependencies":["Y7/nwF1CnBeunlN9f7f/41VLm8+Fu2Rcwec8BdtaBEA=","emJFe0hvIWYvHVgQ/k+18G4w1cGKxAAEhvJ4oCPVZ8I="]},"timestamp_ms":null,"parsed_data":null},"id":1}
