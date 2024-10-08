# General information for Story Protocol

Current chain-id: **iliad-0**

# Story Protocol - Mandragora's infrastructure services

### RPC endpoint
```
https://story-rpc.mandragora.io
```
### API endpoint
```
https://story-api.mandragora.io
```
### JSON-RPC (EVM) endpoint
```
https://story-rpc-evm.mandragora.io
```
### WSS (Cosmos) endpoint
```
wss://story-rpc.mandragora.io/websocket
```
### WSS (EVM) endpoint
```
wss://story-wss.mandragora.io
```
### Seed node
```
b6fb541c80d968931602710342dedfe1f5c577e3@story-seed.mandragora.io:23656
```
### Persistent peer
```
f16c644a6d19798e482edcfe5bd5728a22aa5e0d@65.108.103.184:26656
```
### Geth enode
```
enode://a86b76eb7171eb68c4495e1fbad292715eee9b77a34ffa5cf39e40cc9047e1c41e01486d1e31428228a1350b0f870bcd3b6c5d608ba65fe7b7fcba715a78eeb8@story-geth.mandragora.io:30303
```
## Add peers
```
PEERS=$(curl -sS https://story-rpc.mandragora.io/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)

sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.story/story/config/config.toml

systemctl restart story
```
## Add seeds
```
SEEDS=b6fb541c80d968931602710342dedfe1f5c577e3@story-seed.mandragora.io:23656,51ff395354c13fab493a03268249a74860b5f9cc@story-testnet-seed.itrocket.net:26656,5d7507dbb0e04150f800297eaba39c5161c034fe@135.125.188.77:26656

sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.story/story/config/config.toml

sudo systemctl restart story
```
## Add addrbook
```
sudo systemctl stop story

wget -O $HOME/.story/story/config/addrbook.json https://snapshots.mandragora.io/addrbook.json

sudo systemctl start story
```
## Add Geth enode
Is your Geth binary named `geth` or `story-geth`? Change it accordingly if that's the case. Meanwhile, `story-geth` will remain as default.
```
story-geth --exec 'admin.addPeer("enode://a86b76eb7171eb68c4495e1fbad292715eee9b77a34ffa5cf39e40cc9047e1c41e01486d1e31428228a1350b0f870bcd3b6c5d608ba65fe7b7fcba715a78eeb8@story-geth.mandragora.io:30303")' attach ~/.story/geth/iliad/geth.ipc

sudo systemctl restart story-geth
```
## Apply Mandragora archival snapshot (geth+story)
Check the height of the snapshot (v0.10.1): https://snapshots.mandragora.io/height.txt

This is an archival snapshot with tx indexing on.
```
# Install required dependencies
sudo apt-get install wget lz4 -y

# Stop your story-geth and story nodes
sudo systemctl stop story-geth
sudo systemctl stop story

# Back up your validator state
sudo cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

# Delete previous geth chaindata and story data folders
sudo rm -rf $HOME/.story/geth/iliad/geth/chaindata
sudo rm -rf $HOME/.story/story/data

# Download story-geth and story snapshots
wget -O geth_snapshot.lz4 https://snapshots.mandragora.io/geth_snapshot.lz4
wget -O story_snapshot.lz4 https://snapshots.mandragora.io/story_snapshot.lz4

# Decompress story-geth and story snapshots
lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/iliad/geth
lz4 -c -d story_snapshot.lz4 | tar -xv -C $HOME/.story/story

# Delete downloaded story-geth and story snapshots
sudo rm -v geth_snapshot.lz4
sudo rm -v story_snapshot.lz4

# Restore your validator state
sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Start your story-geth and story nodes
sudo systemctl start story-geth
sudo systemctl start story
```
## Apply Mandragora pruned snapshot (geth+story)
Check the height of the snapshot (v0.10.1): https://snapshots2.mandragora.io/story/height.txt

This is a pruned snapshot with tx indexing disabled.
```
# Install required dependencies
sudo apt-get install wget lz4 -y

# Stop your story-geth and story nodes
sudo systemctl stop story-geth
sudo systemctl stop story

# Back up your validator state
sudo cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

# Delete previous geth chaindata and story data folders
sudo rm -rf $HOME/.story/geth/iliad/geth/chaindata
sudo rm -rf $HOME/.story/story/data

# Download story-geth and story snapshots
wget -O geth_snapshot.lz4 https://snapshots2.mandragora.io/story/geth_snapshot.lz4
wget -O story_snapshot.lz4 https://snapshots2.mandragora.io/story/story_snapshot.lz4

# Decompress story-geth and story snapshots
lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/iliad/geth
lz4 -c -d story_snapshot.lz4 | tar -xv -C $HOME/.story/story

# Delete downloaded story-geth and story snapshots
sudo rm -v geth_snapshot.lz4
sudo rm -v story_snapshot.lz4

# Restore your validator state
sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Start your story-geth and story nodes
sudo systemctl start story-geth
sudo systemctl start story
```
# Other meaningful contributions

##  GitHub issues opened by Mandragora
- https://github.com/piplabs/story/issues/80
- https://github.com/piplabs/story/issues/90
- https://github.com/piplabs/story/issues/91
- https://github.com/piplabs/story/issues/138

## Public JSON-RPC (EVM) available on Chainlist
We have added our public JSON-RPC endpoint to Chainlist through this PR https://github.com/DefiLlama/chainlist/pull/1259.

Feel free to use it ✌️ https://chainlist.org/?testnets=true&search=story
