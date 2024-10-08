# Namada (Housefire) - Mandragora's infrastructure services

Chain ID: `housefire-reduce.e51ecf4264fc3`
Namada software version: `v0.44.0`

### RPC endpoint (state-sync snapshots enabled)
```
https://namada-rpc-housefire.mandragora.io
```
### REST API endpoint (Undexer)
You can find the available API routes in: https://github.com/hackbg/undexer/blob/v3/swagger.yaml
```
https://undexer-v3.demo.hack.bg/v3/
```
### Seed node
```
tcp://836a25b5c465352adf17430135888689b9a0f1d6@namada-seed-housefire.mandragora.io:21656
```
### Persistent peer
```
tcp://a675f4c862fbf71e08a2a770240a79ac3933d163@namada-peer-housefire.mandragora.io:26656
```
## Add peers
```
PEERS=$(curl -sS https://namada-rpc-housefire.mandragora.io/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)

sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/config.toml

systemctl restart namadad
```
## Add seeds
```
SEEDS=tcp://836a25b5c465352adf17430135888689b9a0f1d6@namada-seed-housefire.mandragora.io:21656

sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/config.toml

sudo systemctl restart namadad
```
## Add addrbook
```
sudo systemctl stop namadad

wget -O $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/cometbft/config/addrbook.json https://snapshots2.mandragora.io/addrbook.json

sudo systemctl start namadad
```
## Apply Mandragora snapshots (db+data)
Check the height of the snapshot (v0.44.0): https://snapshots2.mandragora.io/height.txt
```
# Install required dependencies
sudo apt-get install wget lz4 -y

# Stop your node
sudo systemctl stop namadad

# Back up your validator state
sudo cp $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/cometbft/data/priv_validator_state.json $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/cometbft/priv_validator_state.json.backup

# Delete previous db and data folders
sudo rm -rf $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/db
sudo rm -rf $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/cometbft/data

# Download db and data snapshots
wget -O db.lz4 https://snapshots2.mandragora.io/db.lz4
wget -O data.lz4 https://snapshots2.mandragora.io/data.lz4

# Decompress db and data snapshots
lz4 -c -d db.lz4 | tar -xv -C $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3
lz4 -c -d data.lz4 | tar -xv -C $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/cometbft

# Delete downloaded db and data snapshots
sudo rm -v db.lz4
sudo rm -v data.lz4

# Restore your validator state
sudo cp $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/cometbft/priv_validator_state.json.backup $HOME/.local/share/namada/housefire-reduce.e51ecf4264fc3/cometbft/data/priv_validator_state.json

# Start your node
sudo systemctl start namadad
```

## Instructions to sync a node via state-sync method
```
tobedone
```
