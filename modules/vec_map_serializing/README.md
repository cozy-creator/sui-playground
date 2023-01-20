0xa15c5443ad1901f6e35caafdba29c04cadcdefb0

0x3d405308984cbbe5dcb5ef4e0e1090538628c80a

curl --location --request POST $SUI_RPC_HOST \
--header 'Content-Type: application/json' \
--data-raw '{
"jsonrpc": "2.0",
"id": 1,
"method": "sui_devInspectMoveCall",
"params": [
"0x81dc9f2dadfdd28a848177afd8b38b7287f7573f",
"0x7ba69ba74d70cb5ac8ef674716be6cbcaf9f2f4f",
"vec_map",
"get_vec",
[],
[]
]
}' | json_pp

### view bcs:

**The 21 bytes that preceed these are the UID being serialized**

"returnValues" : [
[
[
73, <-- length of the whole thing
61,
64,
83,
8,
152,
76,
187,
229,
220,
181,
239,
78,
14,
16,
144,
83,
134,
40,
200,
10,

4,
4,
110,
97,
109,
101,
11,
80,
97,
117,
108,
32,
70,
105,
100,
105,
107,
97,
3,
97,
103,
101,
2,
50,
56,
6,
103,
101,
110,
100,
101,
114,
4,
109,
97,
108,
101,
8,
108,
111,
99,
97,
116,
105,
111,
110,
6,
68,
101,
110,
118,
101,
114
],
"vector<u8>"

### view ref

                  "returnValues" : [
                     [
                        [
                           4,

                           4,
                           110,
                           97,
                           109,
                           101,

                           11,
                           80,
                           97,
                           117,
                           108,
                           32,
                           70,
                           105,
                           100,
                           105,
                           107,
                           97,

                           3,
                           97,
                           103,
                           101,

                           2,
                           50,
                           56,

                           6,
                           103,
                           101,
                           110,
                           100,
                           101,
                           114,

                           4,
                           109,
                           97,
                           108,
                           101,

                           8,
                           108,
                           111,
                           99,
                           97,
                           116,
                           105,
                           111,
                           110,

                           6,
                           68,
                           101,
                           110,
                           118,
                           101,
                           114
                        ],
                        "0x2::vec_map::VecMap<0x1::string::String, 0x1::string::String>"

### view value

                  "returnValues" : [
                     [
                        [
                           4,
                           4,
                           110,
                           97,
                           109,
                           101,
                           11,
                           80,
                           97,
                           117,
                           108,
                           32,
                           70,
                           105,
                           100,
                           105,
                           107,
                           97,
                           3,
                           97,
                           103,
                           101,
                           2,
                           50,
                           56,
                           6,
                           103,
                           101,
                           110,
                           100,
                           101,
                           114,
                           4,
                           109,
                           97,
                           108,
                           101,
                           8,
                           108,
                           111,
                           99,
                           97,
                           116,
                           105,
                           111,
                           110,
                           6,
                           68,
                           101,
                           110,
                           118,
                           101,
                           114
                        ],
                        "0x2::vec_map::VecMap<0x1::string::String, 0x1::string::String>"

### Th 6-thing vec

                        [
                           25,

                           6,
                           3,
                           49,
                           50,
                           51,

                           3,
                           52,
                           53,
                           54,

                           3,
                           49,
                           50,
                           51,

                           3,
                           52,
                           53,
                           54,

                           3,
                           49,
                           50,
                           51,

                           3,
                           52,
                           53,
                           54
                        ],
                        "vector<u8>"
