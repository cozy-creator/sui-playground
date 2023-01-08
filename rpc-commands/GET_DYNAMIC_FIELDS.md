curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_getDynamicFields",
"params": [
"0x182e14fdeff9367d6fb5efdec18075fc7097f409"
]
}' | json_pp

Oddly enough, this query returns ONLY the keys for the dynamic field, and not their actual values. Which is disappointing.
Also, under the hood every dynamic field has its own object-id, which is also returned by this.

## Qeurying an Object:

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_getObject",
"params": [
"0x3bf63ab6922f77ea47e2c2e7540589c6f8166bb1"
]
}' | json_pp

## Dynamic Object Fields:

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_getDynamicFields",
"params": [
"0xc1d525255122f8e4bcdbfe7126f0e149babe4753"
]
}' | json_pp

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_getDynamicFieldObject",
"params": [
"0xc1d525255122f8e4bcdbfe7126f0e149babe4753", "1u64"
]
}' | json_pp

**Dynamic Field**

{
"digest" : "iJRnezJKSIw75/xo54LMHwW7Tlf6s3FJLkVR41LhkWk=",
"name" : "0x11c78cd27c165f9b8910af7307da85ee3d068fea::metadata::Key {slot: 0x1::ascii::String {bytes: vector[117u8, 110u8, 105u8, 118u8, 101u8, 114u8, 115u8, 101u8]}}",
"objectId" : "0x3848ac9180ece982703fdfc358174f0309dce5ae",
"objectType" : "vector<u8>",
"type" : "DynamicField",
"version" : 228
},

**Dynamic Object Field**

         {
            "digest" : "jzH9Mde1oSvJBe5xlCKiEdSUs7Nxl4n/Pa5IFCMsnto=",
            "name" : "0u64",
            "objectId" : "0x070b2d6b07cdf4584b7554ba52255dc442306f99",
            "objectType" : "0x748d5c18cf85fa5b968e8356d11bb962afb4e1b5::dynamic_object::Something",
            "type" : "DynamicObject",
            "version" : 229
         },

Other than the name being better formatted, there is literally no difference between a Dynamic Field and a Dynamic Object Field. I can't think of any reason for Dynamic Object Fields to exist.

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_getDynamicFieldObject",
"params": [
"0xe003f430052d8b3d48678def07e3b69afa769899", "0u64"
]
}' | json_pp

Note that you can use sui_getDynamicFieldObject on regular dynamic fields as well as dynamic object fields. You just need to supply (1) the parent, and (2) the name (key) of the field.
