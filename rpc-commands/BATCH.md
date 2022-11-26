curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_batchTransaction",
"params": [
"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c",
[
{
"moveCallRequestParams": {
"packageObjectId": "0x1c273aad9d65a09f83f147f107eb349bcf8613fc",
"module": "gas_benchmark",
"function": "edit_owned",
"typeArguments": [],
"arguments": [
"0x7fc1673517982f8cfc86e7eda4fcc8062bfa6a73",
"Using CURL and RPC to modify this bro"
]
}
},
{
"moveCallRequestParams": {
"packageObjectId": "0x0e18557bf4fab836b60bb07832228908037c5324",
"module": "gas_benchmark",
"function": "not_entry",
"typeArguments": [],
"arguments": []
}
}
],
"0x5f72138198f1e5706938a9e90588bf4264de2f73",
2000
]
}'

txBytes = VHJhbnNhY3Rpb25EYXRhOjoBAgIcJzqtnWWgn4PxR/EH6zSbz4YT/AEAAAAAAAAAIGsQje1q9pjE9qEdHlvwEml8qN3CUATQao6Cl7X/V0t7DWdhc19iZW5jaG1hcmsKZWRpdF9vd25lZAACAQB/wWc1F5gvjPyG5+2k/MgGK/pqcwIAAAAAAAAAIP4mlE+HKbngmW9BIlrvFOxKssuIpZiV2IXWNdoBv2NHACYlVXNpbmcgQ1VSTCBhbmQgUlBDIHRvIG1vZGlmeSB0aGlzIGJybwIcJzqtnWWgn4PxR/EH6zSbz4YT/AEAAAAAAAAAIGsQje1q9pjE9qEdHlvwEml8qN3CUATQao6Cl7X/V0t7DWdhc19iZW5jaG1hcmsKZWRpdF9vd25lZAACAQDpQlZ01ut7bHecMkWagDJZlavcFgEAAAAAAAAAII2ZVmG1ygh+T7f23zMvOb/W+Fzab0Wx8f4GhL9sjEMYADU0RWRpdGluZyB0aGlzIGFzIHdlbGwgYnVkZHksIFJQQyBiYXRjaCBmb3IgdGhlIHdvcmxkIZRQG/m6g/jIRnuCC9XjgYPSrKFcX3ITgZjx5XBpOKnpBYi/QmTeL3MCAAAAAAAAACDcAJ1mHtY2LNTk+wlqfyhdne0VNPZR08TUp+Rnfaxm7AEAAAAAAAAA0AcAAAAAAAA=

### Next

Pubkey: WGWR7QO5mUHeVagOHC/XzbVf4GvUuljZ2ls6pZ/M6+o=
Signature: w5XFL3CMa+uboygi9CXZOLwpQHuPxvT1ZrvVvUlgia65bzeBjBi/1ck4gKthoo01rW1w7sCqJtTYngv9em+yAA==

### Submit tx

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_executeTransaction",
"params": [
"VHJhbnNhY3Rpb25EYXRhOjoBAgIcJzqtnWWgn4PxR/EH6zSbz4YT/AEAAAAAAAAAIGsQje1q9pjE9qEdHlvwEml8qN3CUATQao6Cl7X/V0t7DWdhc19iZW5jaG1hcmsKZWRpdF9vd25lZAACAQB/wWc1F5gvjPyG5+2k/MgGK/pqcwIAAAAAAAAAIP4mlE+HKbngmW9BIlrvFOxKssuIpZiV2IXWNdoBv2NHACYlVXNpbmcgQ1VSTCBhbmQgUlBDIHRvIG1vZGlmeSB0aGlzIGJybwIcJzqtnWWgn4PxR/EH6zSbz4YT/AEAAAAAAAAAIGsQje1q9pjE9qEdHlvwEml8qN3CUATQao6Cl7X/V0t7DWdhc19iZW5jaG1hcmsKZWRpdF9vd25lZAACAQDpQlZ01ut7bHecMkWagDJZlavcFgEAAAAAAAAAII2ZVmG1ygh+T7f23zMvOb/W+Fzab0Wx8f4GhL9sjEMYADU0RWRpdGluZyB0aGlzIGFzIHdlbGwgYnVkZHksIFJQQyBiYXRjaCBmb3IgdGhlIHdvcmxkIZRQG/m6g/jIRnuCC9XjgYPSrKFcX3ITgZjx5XBpOKnpBYi/QmTeL3MCAAAAAAAAACDcAJ1mHtY2LNTk+wlqfyhdne0VNPZR08TUp+Rnfaxm7AEAAAAAAAAA0AcAAAAAAAA=",
"ED25519",
"w5XFL3CMa+uboygi9CXZOLwpQHuPxvT1ZrvVvUlgia65bzeBjBi/1ck4gKthoo01rW1w7sCqJtTYngv9em+yAA==",
"WGWR7QO5mUHeVagOHC/XzbVf4GvUuljZ2ls6pZ/M6+o=",
"WaitForEffectsCert"
]
}'

### Success

{"jsonrpc":"2.0","result":{"certificate":{"transactionDigest":"OsrMSFWgHOIwGkh54u5P6gJyiS/voA5+IY2svct9pA4=","data":{"transactions":[{"Call":{"package":{"objectId":"0x1c273aad9d65a09f83f147f107eb349bcf8613fc","version":1,"digest":"axCN7Wr2mMT2oR0eW/ASaXyo3cJQBNBqjoKXtf9XS3s="},"module":"gas_benchmark","function":"edit_owned","arguments":["0x7fc1673517982f8cfc86e7eda4fcc8062bfa6a73","Using CURL and RPC to modify this bro"]}},{"Call":{"package":{"objectId":"0x1c273aad9d65a09f83f147f107eb349bcf8613fc","version":1,"digest":"axCN7Wr2mMT2oR0eW/ASaXyo3cJQBNBqjoKXtf9XS3s="},"module":"gas_benchmark","function":"edit_owned","arguments":["0xe9425674d6eb7b6c779c32459a80325995abdc16","Editing this as well buddy, RPC batch for the world!"]}}],"sender":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c","gasPayment":{"objectId":"0x5f72138198f1e5706938a9e90588bf4264de2f73","version":2,"digest":"3ACdZh7WNizU5PsJan8oXZ3tFTT2UdPE1KfkZ32sZuw="},"gasBudget":2000},"txSignature":"AMOVxS9wjGvrm6MoIvQl2Ti8KUB7j8b09Wa71b1JYImuuW83gYwYv9XJOICrYaKNNa1tcO7AqibU2J4L/XpvsgBYZZHtA7mZQd5VqA4cL9fNtV/ga9S6WNnaWzqln8zr6g==","authSignInfo":{"epoch":0,"signature":"h1HHjDgmloR0cnrWs+TvuIzQlMSgPHjX3osvVHQcXBwMS41x9oOAtBiN4VoKJOhp","signers_map":[58,48,0,0,1,0,0,0,0,0,2,0,16,0,0,0,0,0,1,0,2,0]}},"effects":{"status":{"status":"success"},"gasUsed":{"computationCost":80,"storageCost":52,"storageRebate":46},"transactionDigest":"OsrMSFWgHOIwGkh54u5P6gJyiS/voA5+IY2svct9pA4=","mutated":[{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0x5f72138198f1e5706938a9e90588bf4264de2f73","version":3,"digest":"7OjPd3hSEOxtgmSOZ0vxbzJp3Jz7L9Wx/Eljqg4ZOrU="}},{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0x7fc1673517982f8cfc86e7eda4fcc8062bfa6a73","version":3,"digest":"CHD9C9tsaIgVAm4GwyJpRWcRlvGegfHPgYHeNxiwAu0="}},{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0xe9425674d6eb7b6c779c32459a80325995abdc16","version":2,"digest":"ra2IjSOfx8y7053gyOHnlwx5jBoYnRe4b7wBAhU9s6E="}}],"gasObject":{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0x5f72138198f1e5706938a9e90588bf4264de2f73","version":3,"digest":"7OjPd3hSEOxtgmSOZ0vxbzJp3Jz7L9Wx/Eljqg4ZOrU="}},"dependencies":["0p21j1y+Na0HHIcxnsRaco8qw2iNCO8sVsyZV1UrqcE=","3qEuz53c/zV/LY1y12WvKR7FEZ5hkEi0SvwrxEaMJrY=","/ZBmmtrjqChINSEQy3BvajGC3PsPMBJ6JC6XJFWyk1k="]},"timestamp_ms":null,"parsed_data":null},"id":1}

### Failure

{"jsonrpc":"2.0","result":{"certificate":{"transactionDigest":"0p21j1y+Na0HHIcxnsRaco8qw2iNCO8sVsyZV1UrqcE=","data":{"transactions":[{"Call":{"package":{"objectId":"0x1c273aad9d65a09f83f147f107eb349bcf8613fc","version":1,"digest":"axCN7Wr2mMT2oR0eW/ASaXyo3cJQBNBqjoKXtf9XS3s="},"module":"gas_benchmark","function":"edit_owned","arguments":["0x7fc1673517982f8cfc86e7eda4fcc8062bfa6a73","Using CURL and RPC to modify this bro"]}},{"Call":{"package":{"objectId":"0xb6e0339a5d06fd24ce6b70c92db4786f27ca9eeb","version":1,"digest":"V7a6lhuIcXvvzXgHtAXQprTVnoDjXISetnzn+qKY/ck="},"module":"gas_benchmark","function":"failure"}}],"sender":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c","gasPayment":{"objectId":"0x5f72138198f1e5706938a9e90588bf4264de2f73","version":1,"digest":"T/RX5h7ZQ5yMJMzDrTL03z7AqKY9ivBfB+vyf2BkCCQ="},"gasBudget":2000},"txSignature":"AAdl42fnyAgGaWROnf+u9SwWlARFMa2TR0ZCRpua7zWgpyBjQGIcYaqgt53FpNUqNaAIBb35y29HWSBAvkz1oQFYZZHtA7mZQd5VqA4cL9fNtV/ga9S6WNnaWzqln8zr6g==","authSignInfo":{"epoch":0,"signature":"rwp6249RjzVcPgsQCMyYtcaboSd73TJ/Vyue+T+9NUp1sr9FGOTEvqKEOdlcoFA1","signers_map":[58,48,0,0,1,0,0,0,0,0,2,0,16,0,0,0,0,0,1,0,2,0]}},"effects":{"status":{"status":"failure","error":"MoveAbort(ModuleId { address: b6e0339a5d06fd24ce6b70c92db4786f27ca9eeb, name: Identifier(\"gas_benchmark\") }, 0)"},"gasUsed":{"computationCost":66,"storageCost":0,"storageRebate":0},"transactionDigest":"0p21j1y+Na0HHIcxnsRaco8qw2iNCO8sVsyZV1UrqcE=","mutated":[{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0x5f72138198f1e5706938a9e90588bf4264de2f73","version":2,"digest":"3ACdZh7WNizU5PsJan8oXZ3tFTT2UdPE1KfkZ32sZuw="}},{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0x7fc1673517982f8cfc86e7eda4fcc8062bfa6a73","version":2,"digest":"/iaUT4cpueCZb0EiWu8U7Eqyy4ilmJXYhdY12gG/Y0c="}}],"gasObject":{"owner":{"AddressOwner":"0x94501bf9ba83f8c8467b820bd5e38183d2aca15c"},"reference":{"objectId":"0x5f72138198f1e5706938a9e90588bf4264de2f73","version":2,"digest":"3ACdZh7WNizU5PsJan8oXZ3tFTT2UdPE1KfkZ32sZuw="}},"dependencies":["o3gz1uKX9Rn8EzeXQ4PKlw8kYFdc7ENdCOygLkk6gOM=","7wZTpCfCwMrcOIExK4G7uLdwxsdbLXjOMHYhhZIZcfo=","+XGGJyPJufLHIdgcaNVE1ABtYV/5vQW8R6uO7aTvZ9U=","/ZBmmtrjqChINSEQy3BvajGC3PsPMBJ6JC6XJFWyk1k="]},"timestamp_ms":null,"parsed_data":null},"id":1}
