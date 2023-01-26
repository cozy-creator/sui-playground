module sui_playground::serialize_strings {
    use std::ascii::String;

    public entry fun vec_u8(_data: vector<vector<u8>>) {

    }
    
    public entry fun vec_ascii(_data: vector<String>) {
    }
}