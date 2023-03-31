# General information for Namada

Current chain-id: **public-testnet-6.0.a0266444b06**

## Adding a new addrbook file

```
wget -O $HOME/.namada/public-testnet-6.0.a0266444b06/tendermint/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/namada/addrbook.json

sudo systemctl restart namadad
