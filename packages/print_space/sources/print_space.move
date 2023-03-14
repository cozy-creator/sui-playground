module sui_playground::print_space {
    use std::type_name;
    
    struct Whatever has store { }

    struct Generics<phantom A, phantom B, phantom C> has drop { }

    public fun print_generics<A, B, C>() {

    }
}