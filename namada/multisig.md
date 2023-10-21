# Testing multisig accounts on Namada
On this guide created on `Sept 16, 2023`, we will create a 2-of-2 multisig account and make sure that we created it correctly by using a query. Later on, we will construct, sign and submit different transactions types. 
Finally, for your further reference, multsig accounts with various threshold combinations (from 2 to 10) can be found at the bottom.

# Create a multisig account
Refer to this section [multisig accounts with different thresholds](#multisig-accounts-with-different-thresholds) to create a multisig account of your preference, and then follow the steps below to construct, sign and submit different transaction types.

# Constructing an offline transaction with a multisig account
`--dump-tx` flag allows us to do this. Create a folder to dump the transactions in:
 ```mkdir $HOME/tx_dumps```
# Different transaction types
## Transfer
```
namadac transfer \
--source multisig-2-2 \
--target atest1v4ehgw36gsursd2ygfpyysej8yc5zs3jgdpnjdj9gcmrz33jxpznsvf5gymn2dzzg9zrgd6z8hndjm \
--token NAM \
--amount 0.02 \
--signing-keys key1 \
--dump-tx \
--output-folder-path tx_dumps
```
## Bond transaction
```
namada client bond \
    --source multisig-2-2 \
    --validator mandragora \
    --amount 0.05 \
    --signing-keys key1 \
    --dump-tx \
    --output-folder-path tx_dumps
```
## Unbond transaction
```
namadac unbond \
  --source multisig-2-2 \
  --validator mandragora \
  --amount 0.05 \
  --signing-keys key1 \
  --dump-tx \
  --output-folder-path tx_dumps
```

## Withdraw unbonded tokens transaction
```
namadac withdraw \
  --source multisig-2-2 \
  --validator mandragora \
  --signing-keys key1 \
  --dump-tx \
  --output-folder-path tx_dumps
```
# Signing the transaction
```
namadac sign-tx \
--tx-path "$HOME/tx_dumps/F8DEC31951250C6AE82D78BB145FE083F6C17AF53FD115591A94843E0C63A439.tx" \
--signing-keys key1 \
--owner multisig-2-2
```
```export SIGNATURE_ONE="offline_signature_F8DEC31951250C6AE82D78BB145FE083F6C17AF53FD115591A94843E0C63A439_0.tx"```
```
namadac sign-tx \
--tx-path "$HOME/tx_dumps/F8DEC31951250C6AE82D78BB145FE083F6C17AF53FD115591A94843E0C63A439.tx" \
--signing-keys key2 \
--owner multisig-2-2
```
```export SIGNATURE_TWO="offline_signature_F8DEC31951250C6AE82D78BB145FE083F6C17AF53FD115591A94843E0C63A439_1.tx"```
# Submitting the transaction
```
namadac tx \
--tx-path "tx_dumps/F8DEC31951250C6AE82D78BB145FE083F6C17AF53FD115591A94843E0C63A439.tx" \
--signatures $SIGNATURE_ONE \
--signatures $SIGNATURE_TWO \
--owner multisig-2-2 \
--gas-payer test
```

# Multisig accounts with different thresholds
## At least 2 signers
### 2-of-2
```
namadac init-account \
--alias multisig-2-2 \
--public-keys key1,key2 \
--signing-keys key1,key2 \
--threshold 2
```
### 2-of-3
```
namadac init-account \
--alias multisig-2-3 \
--public-keys key1,key2,key3 \
--signing-keys key1,key2 \
--threshold 2
```
## At least 3 signers
### 3-of-3
```
namadac init-account \
--alias multisig-3-3 \
--public-keys key1,key2,key3 \
--signing-keys key1,key2,key3 \
--threshold 3
```
### 3-of-4
```
namadac init-account \
--alias multisig-3-4 \
--public-keys key1,key2,key3,key4 \
--signing-keys key1,key2,key3 \
--threshold 3
```
### 3-of-5
```
namadac init-account \
--alias multisig-3-5 \
--public-keys key1,key2,key3,key4,key5 \
--signing-keys key1,key2,key3 \
--threshold 3
```
### 3-of-6
```
namadac init-account \
--alias multisig-3-6 \
--public-keys key1,key2,key3,key4,key5,key6 \
--signing-keys key1,key2,key3 \
--threshold 3
```
## At least 4 signers
### 4-of-4
```
namadac init-account \
--alias multisig-4-4 \
--public-keys key1,key2,key3,key4 \
--signing-keys key1,key2,key3,key4 \
--threshold 4
```
### 4-of-5
```
namadac init-account \
--alias multisig-4-5 \
--public-keys key1,key2,key3,key4,key5 \
--signing-keys key1,key2,key3,key4 \
--threshold 4
```
### 4-of-6
```
namadac init-account \
--alias multisig-4-6 \
--public-keys key1,key2,key3,key4,key5,key6 \
--signing-keys key1,key2,key3,key4 \
--threshold 4
```
### 4-of-7
```
namadac init-account \
--alias multisig-4-7 \
--public-keys key1,key2,key3,key4,key5,key6,key7 \
--signing-keys key1,key2,key3,key4 \
--threshold 4
```
### 4-of-8
```
namadac init-account \
--alias multisig-4-8 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8 \
--signing-keys key1,key2,key3,key4 \
--threshold 4
```


## At least 5 signers
### 5-of-5
```
namadac init-account \
--alias multisig-5-5 \
--public-keys key1,key2,key3,key4,key5 \
--signing-keys key1,key2,key3,key4,key5 \
--threshold 5
```
### 5-of-6
```
namadac init-account \
--alias multisig-5-6 \
--public-keys key1,key2,key3,key4,key5,key6 \
--signing-keys key1,key2,key3,key4,key5 \
--threshold 5
```
### 5-of-7
```
namadac init-account \
--alias multisig-5-7 \
--public-keys key1,key2,key3,key4,key5,key6,key7 \
--signing-keys key1,key2,key3,key4,key5 \
--threshold 5
```
### 5-of-8
```
namadac init-account \
--alias multisig-5-8 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8 \
--signing-keys key1,key2,key3,key4,key5 \
--threshold 5
```
### 5-of-9
```
namadac init-account \
--alias multisig-5-9 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9 \
--signing-keys key1,key2,key3,key4,key5 \
--threshold 5
```
### 5-of-10
```
namadac init-account \
--alias multisig-5-10 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9,key10 \
--signing-keys key1,key2,key3,key4,key5 \
--threshold 5
```
## At least 6 signers
### 6-of-6
```
namadac init-account \
--alias multisig-6-6 \
--public-keys key1,key2,key3,key4,key5,key6 \
--signing-keys key1,key2,key3,key4,key5,key6 \
--threshold 6
```
### 6-of-7
```
namadac init-account \
--alias multisig-6-7 \
--public-keys key1,key2,key3,key4,key5,key6,key7 \
--signing-keys key1,key2,key3,key4,key5,key6 \
--threshold 6
```
### 6-of-8
```
namadac init-account \
--alias multisig-6-8 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8 \
--signing-keys key1,key2,key3,key4,key5,key6 \
--threshold 6
```
### 6-of-9
```
namadac init-account \
--alias multisig-6-9 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9 \
--signing-keys key1,key2,key3,key4,key5,key6 \
--threshold 6
```
### 6-of-10
```
namadac init-account \
--alias multisig-6-10 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9,key10 \
--signing-keys key1,key2,key3,key4,key5,key6 \
--threshold 6
```
## At least 7 signers
### 7-of-7
```
namadac init-account \
--alias multisig-7-7 \
--public-keys key1,key2,key3,key4,key5,key6,key7 \
--signing-keys key1,key2,key3,key4,key5,key6,key7 \
--threshold 7
```
### 7-of-8
```
namadac init-account \
--alias multisig-7-8 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8 \
--signing-keys key1,key2,key3,key4,key5,key6,key7 \
--threshold 7
```
### 7-of-9
```
namadac init-account \
--alias multisig-7-9 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9 \
--signing-keys key1,key2,key3,key4,key5,key6,key7 \
--threshold 7
```
### 7-of-10
```
namadac init-account \
--alias multisig-7-10 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9,key10 \
--signing-keys key1,key2,key3,key4,key5,key6,key7 \
--threshold 7
```
## At least 8 signers
### 8-of-8
```
namadac init-account \
--alias multisig-8-8 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8 \
--signing-keys key1,key2,key3,key4,key5,key6,key7,key8 \
--threshold 8
```
### 8-of-9
```
namadac init-account \
--alias multisig-8-9 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9 \
--signing-keys key1,key2,key3,key4,key5,key6,key7,key8 \
--threshold 8
```
### 8-of-10
```
namadac init-account \
--alias multisig-8-10 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9,key10 \
--signing-keys key1,key2,key3,key4,key5,key6,key7,key8 \
--threshold 8
```
## At least 9 signers
### 9-of-9
```
namadac init-account \
--alias multisig-9-9 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9 \
--signing-keys key1,key2,key3,key4,key5,key6,key7,key8,key9 \
--threshold 9
```
### 9-of-10
```
namadac init-account \
--alias multisig-9-10 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9,key10 \
--signing-keys key1,key2,key3,key4,key5,key6,key7,key8,key9 \
--threshold 9
```
## At least 10 signers
### 10-of-10
```
namadac init-account \
--alias multisig-10-10 \
--public-keys key1,key2,key3,key4,key5,key6,key7,key8,key9,key10 \
--signing-keys key1,key2,key3,key4,key5,key6,key7,key8,key9,key10 \
--threshold 10
```
