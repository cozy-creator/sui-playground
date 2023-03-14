import {
  MoveCallTransaction,
  UnserializedSignableTransaction,
  Connection,
  JsonRpcProvider
} from '@mysten/sui.js';

const provider = new JsonRpcProvider(
  new Connection({
    fullnode: 'https://node.shinami.com/api/v1/ba7e504a06dad374a07ce82a7773f9bd',
    faucet: 'https://fullnode.devnet.sui.io:443'
  })
);

async function get(object_id: string) {
  const signableTxn = {
    kind: 'moveCall',
    data: {
      packageObjectId: '0x0553ffe2781ccb9fe3007ecb255a0063be3f0efe',
      module: 'view',
      function: 'view2',
      typeArguments: [],
      arguments: [object_id]
    } as MoveCallTransaction
  } as UnserializedSignableTransaction;

  let result = await provider.devInspectTransaction(
    '0x199949be1f89e33d44ac2794f10b340c3ba7789d',
    signableTxn
  );

  console.log(result);
}

get('0xc6f1b6c947192001773023c4e250b604c67bcac0');
