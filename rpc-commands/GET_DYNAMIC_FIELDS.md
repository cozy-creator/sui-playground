Basically these RPC calls work like this:

1. Use sui_getDynamicFields to get all dynamic fields; note that this will return both DynamicFields AND DynamicFieldObjects. All it will return is the Object-IDs and their 'names' (the key used for the dynamic field). It will NOT return any values, which is lame.

2. All objects, regardless of whether or not they're a DynamicField or DynamicFieldObject get assigned an ID under the hood.

3. use sui_getObject with dynamic field's ID in order to get the corresponding value.

4. use sui_getDynamicFieldObject to fetch the value of a DynamicFieldObject or DynamicField; (1) this can be used on BOTH DynamicFieldObjects AND DynamicFields, (2) this requires both the ID of the parent, and the name (key) of the DynamicObjectField you're looking up. This will return the actual value of the corresponding field, changing the two-step process above into a single-step process, assuming you know the name (key).

5. These calls are NOT currently supported by the Sui Typescript SDK.

6. This means that we need to make individual calls on a PER FIELD BASIS. I.e., if you have an object with 10 fields, you need to make 11 calls; one to get the field IDs, and then another 10; one for each field ID. (You can do 10 calls instead, one per field, assuming you already know all the key-names.)

7. DynamicFieldObjects are stupid and should be eliminated; I think the only thing they provide is stable IDs for storing / unstoring fields, which should be rolled into DynamicFields (i.e., if you store an object with UID, keep the UID rather than assigning a new one). There is no reason for their existence and they just cause confusion and duplication.

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_getDynamicFields",
"params": [
"0x3e5aa384fcdcbfd6ca0e35afc45886920bef4480"
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
"0x3e5aa384fcdcbfd6ca0e35afc45886920bef4480"
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
"0x9c490df76f939597bb6c0c3441ce010d95588942", "973u64"
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
"0x3e5aa384fcdcbfd6ca0e35afc45886920bef4480", "696900000000000u64"
]
}' | json_pp

Note that you can use sui_getDynamicFieldObject on regular dynamic fields as well as dynamic object fields. You just need to supply (1) the parent, and (2) the name (key) of the field.
