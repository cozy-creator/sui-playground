module sui_playground::string_entry {
    use std::string::{Self, String};
    
    public entry fun name_something(first: String, last: String) {
        string::append(&mut first, last);
    }
}