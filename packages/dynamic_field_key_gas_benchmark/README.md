This test has demonstrated that:

If you use a Key { u8 } as a key to a dynamic field, rather than just a u8, this adds 12% overhead to the gas-cost. Which is surprisingly small.

Using utf8 strings, rather than u8's as keys increases the gas-cost by about 17% (i.e., switching from utf8 to u8's saves 15% on gas).

### Numbers:

Create object: 189
u8: 2,187
raw u8: 1,989
key adds: 198

utf8: 2,409
raw utf8: 2,394
key adds: 15

ascii: 4,478
raw ascii: 4,443
key adds: 35

wrapper with raw u8: 2,107

### Conclusion

In other words, our 'Key' pattern adds almost no overhead whatsoever. This is probably because keys are not stored; instead hashes of keys are stored.

Also, going from raw-bytes to utf8 incurs almost no penalty; it cost an addition 222 nanoSui because of running the conversion function.

Adding a wrapper gave almost no savings whatsoever.

Surprisingly ascii was FAR more expensive than UTF8 however. Checking, it appears ascii::string is far more expensive than string::utf8:

utf8: 528
ascii: 2,597

ascii is probably cheaper to store (as you'd expect), but the conversion function is far more costly.
