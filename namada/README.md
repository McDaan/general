# General information for Namada

Current chain-id: **public-testnet-7.0.3c5a38dc983**

## Adding a new addrbook file

```
sudo systemctl stop namadad

wget -O $HOME/.namada/public-testnet-7.0.3c5a38dc983/tendermint/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/namada/addrbook.json

sudo systemctl start namadad
