Benchmarks:

Do nothing with 1KB vector: 5
Copy once: 7
Copy thrice: 12

Iterating on 1KB vector and doing nothing: 3,203

Copying big-struct once: 28
Copying big-struct 3 times: 239
Copying big-struct 6 times: 391
Copying big-struct 7 times: 706

'Copy' is free, whereas de-ref costs gas

idk wtf is going on here

### Testnet 1.2

Test-1 (deref): 5 milliSUI (copies 3 KB 7x times)
Test-2 (copy): 1 milliSUI (copies 3 KB 7x times)
