# General information for Namada

Current chain-id: **public-testnet-11.cc649ddd49b0**

# Adding a new addrbook file

```
sudo systemctl stop namadad

wget -O $HOME/.local/share/namada/public-testnet-11.cc649ddd49b0/cometbft/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/namada/addrbook.json

sudo systemctl start namadad

```

# Testing shielding, shielded and unshielding transfers

## Generating new Spending Keys
```
namadaw masp gen-key --alias testmasp
namadaw masp gen-key --alias testmasp2
```

A Viewing Key will also be generated sharing the same alias:
- Spending Key alias: *testmasp* & *testmasp2*  
- Viewing Key alias: *testmasp* & *testmasp2*
  
## Generating a payment address
Generating a payment address from the Spending Key (command will generate a different payment address each time you run it - they can be reused or discarded, and relationship between them can't be deciphered w/o the Spending Key):
```
namadaw masp gen-addr \
    --key testmasp \
    --alias testmasp-addr
```
Spending Key/Viewing Key alias used to generate the payment address: *testmasp*  
Payment address alias: *testmasp-addr*  
	
### Generating a second payment address
Generating a second payment address to test shielded-to-shielded transfers:
```
namadaw masp gen-addr \
    --key testmasp2 \
    --alias testmasp-addr2
```	
Spending Key/Viewing Key alias used to generate the payment address: *testmasp2*  
Payment address alias: *testmasp-addr2*  

## Shielding transfer
Sending funds from a transparent address to a shielded one:
```
namadac transfer \
    --source mandragora \
    --target testmasp-addr \
    --token NAM \
    --amount 200
```  
  
Checking shielded balance (*testmasp*)
```
namadac balance --owner testmasp
```

## Shielded transfer
Sending shielded balance to a shielded address:
```
namadac transfer \
    --source testmasp \
    --target testmasp-addr2 \
    --token NAM \
    --amount 100 \
    --signer test
```
Note: here I used a newly created address to be the signer - I just tried signing with the validator address (*mandragora* in this case) and it works too.  
  
Checking shielded balance (*testmasp2*)
```
namadac balance --owner testmasp2
```
	
## Unshielding transfer
Sending shielded balance to a transparent address:
```
namadac transfer \
    --source testmasp2 \
    --target mandragora \
    --token NAM \
    --amount 50 \
    --signer test
```
Note: here I used a newly created address to be the signer - I just tried signing with the validator address (*mandragora* in this case) and it works too.

## Flow of the sent assets
*mandragora* > *testmasp* (*testmasp-addr*) > *testmasp2* (*testmasp-addr2*) > *mandragora*

# Local snapshot solution

**Stop your node**

## Saving the snapshot files
```
mkdir $HOME/snapshot
mv $HOME/.local/share/namada/public-testnet-11.cc649ddd49b0/db $HOME/snapshot
mv $HOME/.local/share/namada/public-testnet-11.cc649ddd49b0/cometbft/data $HOME/snapshot
```
  
## Re-join the network
```
cd $HOME/.local/share/namada
rm -rf public-testnet-11.cc649ddd49b0/ && rm public-testnet-11.cc649ddd49b0.toml && rm global-config.toml && cd
namadac utils join-network --chain-id public-testnet-11.cc649ddd49b0 --genesis-validator <your-validator-alias>
```
Note: you don't need to use the *--genesis-validator* flag if you are not a pre-genesis validator.
  
**Start your node, wait 30-60s, and stop it**
  
## Applying the snapshot
```
rm -rf $HOME/.local/share/namada/public-testnet-11.cc649ddd49b0/db
rm -rf $HOME/.local/share/namada/public-testnet-11.cc649ddd49b0/cometbft/data
cd $HOME/snapshot
mv db/ $HOME/.local/share/namada/public-testnet-11.cc649ddd49b0
mv data/ $HOME/.local/share/namada/public-testnet-11.cc649ddd49b0/cometbft
```
  
**Start your node**


