# General information for Namada

Current chain-id: **public-testnet-9.0.5aa315d1a22**

## Adding a new addrbook file

```
sudo systemctl stop namadad

wget -O $HOME/.local/share/namada/public-testnet-9.0.5aa315d1a22/cometbft/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/namada/addrbook.json

sudo systemctl start namadad
