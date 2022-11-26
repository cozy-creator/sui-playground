import {
  JsonRpcProvider,
  Ed25519Keypair,
  RawSigner,
  Keypair,
  Base64DataBuffer,
  getMoveCallTransaction,
  isSuiTransactionKind,
  LocalTxnDataSerializer,
  TxnDataSerializer,
  SuiTransactionKind
} from '@mysten/sui.js';

// I have no clue how to convert this into a private key
// const privateKeyBase64 =
//   'AEafDzqO94kdIxJ/iklK/e+jExNQfoPKTbYcvdjhDyqOx1TJsxkwO5mqEIf5ntFAyP6gHk2JoBKO/lOXXZFnkXo=';

// const address = ed2c39b73e055240323cf806a7d8fe46ced1cabb

const privateKeyBytes = new Uint8Array([
  132, 54, 122, 250, 165, 129, 138, 9, 27, 139, 141, 26, 251, 132, 105, 197, 222, 13, 99, 214, 58,
  249, 145, 34, 191, 69, 206, 232, 232, 208, 127, 60, 189, 137, 111, 147, 146, 3, 153, 199, 100, 74,
  64, 131, 145, 63, 134, 219, 99, 85, 235, 27, 193, 32, 115, 230, 40, 217, 14, 248, 76, 212, 88, 83
]);

const provider = new JsonRpcProvider('https://gateway.devnet.sui.io:443');

let keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);
const signer = new RawSigner(keypair, provider);
const publicKeyHex = keypair.getPublicKey().toSuiAddress();

async function get_objects(address: string) {
  const objects = await provider.getObjectsOwnedByAddress(address);

  console.log(objects);
}

// get_objects(publicKeyHex);

async function mint_example_nft() {
  const moveCallTxn = await signer.executeMoveCall({
    packageObjectId: '0x2',
    module: 'devnet_nft',
    function: 'mint',
    typeArguments: [],
    arguments: [
      'Example NFT',
      'An NFT created by the wallet Command Line Tool',
      'ipfs://bafkreibngqhl3gaa7daob4i2vccziay2jjlp435cf66vhono7nrvww53ty'
    ],
    gasBudget: 1000
  });

  //   console.log(moveCallTxn);

  console.log(publicKeyHex);
}

// mint_example_nft();

// batch transactions are not supported yet
async function batch_tx() {
  const tx_serialize = new LocalTxnDataSerializer(provider);

  //   let tx = TxnDataSerializer;

  //   tx_serialize.newMoveCall(publicKeyHex);

  //   signer.exec;

  //   signer.serializer.newMoveCall(publicKeyHex, d);
  //   getMoveCallTransaction();
}
