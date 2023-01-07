This test has demonstrated that:

If you use a Key { u8 } as a key to a dynamic field, rather than just a u8, this adds 12% overhead to the gas-cost. Which is surprisingly small.

Using utf8 strings, rather than u8's as keys increases the gas-cost by about 17% (i.e., switching from utf8 to u8's saves 15% on gas).
