// This doesn't work

module sui_playground::bitwise {
    public fun something(num: u256) {
        let _a = num & 0x000000;
        let _b = num | 0x000000;
        let _c = num ^ 0x000000;
        let _d = num << 0x000000;
        let _e = num >> 0x000000;
        let _f = num >>> 0x000000;
        let _g = -num;
    }
}