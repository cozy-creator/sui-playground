// Local Storage Operator

module sui_utils::lso {
    use std::type_name::{Self, TypeName};
    use sui::dynamic_field;
    use sui::object::UID;

    public fun move_to_<T: store>(uid: &mut UID, value: T) {
        let key = type_name::get<T>();
        dynamic_field::add(uid, key, value);
    }

    public fun move_from_<T: store>(uid: &mut UID): T {
        let key = type_name::get<T>();
        dynamic_field::remove(uid, key)
    }

    public fun borrow_local<T: store>(uid: &UID): &T {
        let key = type_name::get<T>();
        dynamic_field::borrow(uid, key)
    }

    public fun borrow_local_mut<T: store>(uid: &mut UID): &mut T {
        let key = type_name::get<T>();
        dynamic_field::borrow_mut(uid, key)
    }

    public fun exists_<T: store>(uid: &UID): bool {
        let key = type_name::get<T>();
        dynamic_field::exists_with_type<TypeName, T>(uid, key)
    }
}