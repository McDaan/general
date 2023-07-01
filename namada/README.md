# General information for Namada

Current chain-id: **public-testnet-10.3718993c3648**

## Adding a new addrbook file

```
sudo systemctl stop namadad

wget -O $HOME/.local/share/namada/public-testnet-10.3718993c3648/cometbft/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/namada/addrbook.json

sudo systemctl start namadad
