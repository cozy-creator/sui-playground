module sui_playground::set_field {
    public fun borrow_mut() {

    }
}

// Problems:
// How do you coordinate object.id keys?
// Solution = every module will simply have to keep a set of its own idiosyncratic location
//
// What if the key you use doesn't have anything? Fill in with default?
// What if the key you use has something, but it's the incorrect data-type?
module sui_playground::host {
    use sui::object::UID;
    use sui::dynamic_field;
    use sui_playground::metadata::Metadata;
    use sui_playground::writer;

    const METADATA_KEY: u8 = 0;

    struct Object has key {
        id: UID
    }

    public fun use_writer(object: &mut Object) {
        // let metadata = set_field::borrow_mut(&mut object.id, METADATA_KEY);
        let metadata = dynamic_field::borrow_mut<u8, Metadata>(&mut object.id, METADATA_KEY);
        writer::write_to_metadata(metadata);
    }
}

module sui_playground::writer {
    use std::string;
    use sui_playground::metadata::{Self, Metadata};

    public fun write_to_metadata(metadata: &mut Metadata) {
        metadata::set_name(metadata, string::utf8(b"Something New"));
    }
}

module sui_playground::metadata {
    use std::string::{String};

    struct Metadata has store {
        name: String,
        description: String,
        url: String
    }

    public fun set_name(metadata: &mut Metadata, new_name: String) {
        metadata.name = new_name;
    }
}