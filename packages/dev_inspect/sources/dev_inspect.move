module sui_playground::dev_inspect {
    use std::ascii::{Self, String};
    use std::option::{Self, Option};
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;

    struct NamedPerson has key {
        id: UID,
        name: String
    }

    struct Object has key {
        id: UID
    }

    struct Optional has drop {
        age: u16,
        height: Option<u64>,
        friends: Option<u64>
    }

    struct Response has drop {
        name: String,
        description: String,
        age: u16,
        location: Nested
    }

    struct Nested has store, drop {
        addr: String,
        zip: u64,
        country: String
    }

    public fun something(_ctx: &mut TxContext): u64 {
        69
    }

    public fun read_name(guy: &NamedPerson, ctx: &mut TxContext): String {
        something(ctx);
        something(ctx);
        guy.name
    }

    public fun failure() {
        assert!(false, 7999);
    }

    // I thought this would fail, but I was wrong; you CAN use owned objects from multiple
    // different addresses all within the same transaction, even if you're not the transaction
    // sender. This is great!
    public fun two_users(person1: &NamedPerson, person2: &NamedPerson): (String, String) {
        (person1.name, person2.name)
    }

    // The result of this format is in raw-bytes, not anything more fancy.
    // Uses little-endian encoding for numbers, e.g.:
    // For example, 99u64 = [ [99,0,0,0,0,0,0,0], "u64" ]
    // "Thingy" in ascii = [ [6,84,104,105,110,103,121], "0x1::ascii::String" ]
    public fun multi_output(): (String, u8, u16, u64, u128, u256, bool) {
        let string = ascii::string(b"Thingy");
        (string, 3u8, 255u16, 99, 178888u128, 31468863379000u256, true)
    }

    // Returns a not-so useful bcs-encoding:
    // [11,80,97,117,108,32,70,105,100,105,107,97, 22,83,111,109,101,32,100,101,103,101,110,32,83,117,
    // 105,32,100,101,118,32,103,117,121, 26,0, 18,49,52,49... 74,57,1,0,0,0,0,0,...],
    // "0xcfa264df217d51ee022ec030af34b0b8a6288155::dev_inspect::Response"
    // The first bit is '11 bytes... Paul Fidika' and then '22 bytes... (description)', followed by
    // 26,0 (26), followed by '18 bytes... (address)', followed by 'zipcode as u64'.
    // Any system which wants to decode these bytes will need the struct definition located at
    // dev_inspect::Response; it's simply not possible to deserialize this as-is, because the client-app
    // lacks the information needed to do so.
    public fun struct_output(): Response {
        let location = Nested {
            addr: ascii::string(b"1415 Park West Ave"),
            zip: 80202,
            country: ascii::string(b"United States")
        };

        Response {
            name: ascii::string(b"Paul Fidika"),
            description: ascii::string(b"Some degen Sui dev guy"),
            age: 26,
            location
        }
    }

    // Response is:
    // [11, 0 (7 more 0's), 1 (7 more 0's), 2 (7 more 0's)...], "vector<u64>"
    // it specifies the length of the vector first, followed by each member
    public fun vector_output(): vector<u64> {
        vector[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    }

    // This simply prints off the 20-byte object ID, and ignores the dynamic fields entirely
    public fun dynamic_fields(ctx: &mut TxContext): Object {
        let object = Object { id: object::new(ctx) };
        dynamic_field::add(&mut object.id, 0, 99);
        dynamic_field::add(&mut object.id, 1, 254);
        object
    }

    // Returns: [15,0, 0,1, 52,9], "0xb52bdc39d39857276ec6f1cd897f153c7bd490a9::dev_inspect::Optional"
    // I guess 0,1 is the bcs encoding of option::none()
    // This is problematic because option::some(256) for a u16 = option::none()
    // Therefore, we cannot use Option<u16>, because there is a bcs-collission at 256. For other values
    // it should be more clear
    public fun optional(): Optional {
        Optional {
            age: 15,
            height: option::none(),
            friends: option::some(256)
        }
    }

    public fun give_uid(id: &mut UID): String {
        dynamic_field::remove<u64, String>(id, 0)
    }

    fun init(ctx: &mut TxContext) {
        let person = NamedPerson { 
            id: object::new(ctx),
            name: ascii::string(b"Paul Fidika")
        };
        dynamic_field::add(&mut person.id, 0, ascii::string(b"King Of The World"));
        transfer::transfer(person, tx_context::sender(ctx));

        let person = NamedPerson { 
            id: object::new(ctx),
            name: ascii::string(b"Ashlee Taylor")
        };
        dynamic_field::add(&mut person.id, 0, ascii::string(b"Queen Of The World"));
        transfer::transfer(person, @0x33);
    }
}