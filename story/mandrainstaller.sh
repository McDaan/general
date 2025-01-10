#!/bin/bash

curl -s https://raw.githubusercontent.com/McDaan/general/refs/heads/main/story/mandrainstallerlogo.sh | bash

RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"

echo "-------------------------------------------------------------------"
echo -e "$GREEN We can go through different options. Let's get started! (to install a node, go through 1st step and then 2nd one)"
echo -e "$NORMAL-------------------------------------------------------------------"
echo -e "$YELLOW SELECT AN OPTION"
echo "1) INSTALL A NODE (standard setup)"
echo "2) APPLY A SNAPSHOT (Mandragora & others)"
echo "3) UPDATE TO A SPECIFIC VERSION"
echo "4) NODE STATUS"
echo "5) CHECK LOGS (STORY+GETH)"
echo "6) ADD SEEDS (Mandragora & others)"
echo "7) ADD PEERS (Mandragora & others)"
echo "8) ADD GETH ENODE (Mandragora)"
echo -e "9) DOWNLOAD ADDRBOOK (Mandragora)"
echo -e "10) STOP STORY OR GETH NODES"
echo -e "11) RESTART STORY OR GETH NODES $NORMAL"

echo "-------------------------------------------------------------------"
echo -e "What do you want to do?"
echo "-------------------------------------------------------------------"
read -p "Your selection: " OPTION

if [ "$OPTION" == "1" ]; then
		echo -e "$RED Are you sure to proceed? This is done automatically. If you are facing issues with your node would be better to troubleshoot a bit before taking such a measure. This process will override your existing data. Wait patiently. (y/n). $NORMAL"
        read -p "Selected answer (y/n): " ANSWER
		if [ "$ANSWER" == "y" ]; then
			echo -e "$GREEN Installing required dependencies.$NORMAL"
			sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 -y
			wget -c 'https://dl.google.com/go/go1.23.1.linux-amd64.tar.gz' -O go1.23.1.linux-amd64.tar.gz && sudo tar -C /usr/local/ -xzf go1.23.1.linux-amd64.tar.gz
			rm -Rf go1.23.1.linux-amd64.tar.gz
   sudo tee $HOME/.bash_profile <<EOF
   #Go:
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
export GOBIN="$GOPATH/bin"
EOF
			source $HOME/.bash_profile
		
			echo -e "$GREEN Downloading required binaries (geth and story).$NORMAL"
			cd $HOME
			wget https://github.com/piplabs/story-geth/releases/download/v0.11.0/geth-linux-amd64
			chmod +x geth-linux-amd64
			sudo mv $HOME/geth-linux-amd64 /usr/local/bin/story-geth
			story-geth version
			
			wget https://github.com/piplabs/story/releases/download/v0.13.1/story-linux-amd64
			chmod +x story-linux-amd64
			sudo mv $HOME/geth-linux-amd64 /usr/local/bin/story
			story version
			
			echo -e "$GREEN Initializing node.$NORMAL"
			echo -e "$GREEN Choose a node moniker? $NORMAL"
			read -p "Your node noniker: " MONIKER
			story init --network odyssey --moniker $MONIKER
			
			echo -e "$GREEN Creating service files for story and geth.$NORMAL"
sudo tee /etc/systemd/system/story-geth.service <<EOF
   [Unit]
Description=story-geth service
 After=network.target
		
[Service]
User=root
ExecStart=/usr/local/bin/story-geth --odyssey --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
	
[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/story.service <<EOF
  [Unit]
Description=story-cometbft service
After=network.target
	
[Service]
User=root
ExecStart=/usr/local/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
	
[Install]
WantedBy=multi-user.target
EOF
			echo -e "$GREEN Enabling service files.$NORMAL"
			sudo systemctl daemon-reload
			sudo systemctl enable story-geth
			sudo systemctl enable story
			
			echo -e "$GREEN Well done! You have installed your node successfully. Before it start syncing, you'll need to apply a snapshot, so now go through option 2 of this installer to apply a recent snapshot and start your nodes.$NORMAL"
			exit 0
		elif [ "$ANSWER" == "n" ]; then
			echo -e "$YELLOW See you! Aborting...$NORMAL"
			exit 0
		else
            echo -e "$RED Wrong answer. Select a valid option (y/n) Aborting...$NORMAL"
            exit 0
		fi
elif [ "$OPTION" == "2" ]; then
        echo -e "$GREEN Enter the available snapshot providers (Mandragora, Josephtran, Itrocket) .$NORMAL"
        read -p "Selected snapshot provider: " PROVIDER
		
		if [ "$PROVIDER" == "Mandragora" ] || [ "$PROVIDER" == "Josephtran" ] || [ "$PROVIDER" == "Itrocket" ]; then
                echo -e "$GREEN Do you want to download an archival (heavier) or pruned snapshot (lighter)?$NORMAL"
                read -p "Selected snapshot type (archival or pruned): " SNAPSHOT
				if [ "$SNAPSHOT" == "archival" ]; then
					case $PROVIDER in
						"Mandragora")
							echo -e "$GREEN Installing required dependencies.$NORMAL"
							sudo apt-get install wget lz4 -y

							echo -e "$GREEN Stopping both story and geth nodes.$NORMAL"
							sudo systemctl stop story-geth
							sudo systemctl stop story

							echo -e "$GREEN Backing up the validator state (just in case).$NORMAL"
							sudo cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

							echo -e "$GREEN Deleting old data.$NORMAL"
							sudo rm -rf $HOME/.story/geth/odyssey/geth/chaindata
							sudo rm -rf $HOME/.story/story/data

							echo -e "$GREEN Downloading both story and geth snapshots (this may take time, wait patiently).$NORMAL"
							wget -O geth_snapshot.lz4 https://snapshots.mandragora.io/geth_snapshot.lz4
							wget -O story_snapshot.lz4 https://snapshots.mandragora.io/story_snapshot.lz4

							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/odyssey/geth
							lz4 -c -d story_snapshot.lz4 | tar -xv -C $HOME/.story/story

							echo -e "$GREEN Deleting snapshot files.$NORMAL"
							sudo rm -v geth_snapshot.lz4
							sudo rm -v story_snapshot.lz4

							echo -e "$GREEN Restoring your validator state.$NORMAL"
							sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

							echo -e "$GREEN Restarting both story and geth nodes (check out your node status to make sure your node is syncing).$NORMAL"
							sudo systemctl start story-geth
							sudo systemctl start story
						;;
						"Josephtran")
							echo -e "$GREEN Installing required dependencies.$NORMAL"
							sudo apt-get install wget lz4 aria2 pv -y

							echo -e "$GREEN Stopping both story and geth nodes.$NORMAL"
							sudo systemctl stop story-geth
							sudo systemctl stop story
							
							echo -e "$GREEN Downloading both story and geth snapshots (this may take time, wait patiently).$NORMAL"
							cd $HOME
							rm -f Story_snapshot.lz4
							aria2c -x 16 -s 16 -k 1M https://story.josephtran.co/archive_Story_snapshot.lz4
							rm -f Geth_snapshot.lz4
							aria2c -x 16 -s 16 -k 1M https://story.josephtran.co/archive_Geth_snapshot.lz4
							
							echo -e "$GREEN Backing up the validator state (just in case).$NORMAL"
							cp ~/.story/story/data/priv_validator_state.json ~/.story/priv_validator_state.json.backup
							
							echo -e "$GREEN Deleting old data.$NORMAL"
							rm -rf ~/.story/story/data
							rm -rf ~/.story/geth/odyssey/geth/chaindata
							
							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							sudo mkdir -p /root/.story/story/data
							lz4 -d -c Story_snapshot.lz4 | pv | sudo tar xv -C ~/.story/story/ > /dev/null
							sudo mkdir -p /root/.story/geth/odyssey/geth/chaindata
							lz4 -d -c Geth_snapshot.lz4 | pv | sudo tar xv -C ~/.story/geth/odyssey/geth/ > /dev/null
							
							echo -e "$GREEN Restoring your validator state.$NORMAL"
							cp ~/.story/priv_validator_state.json.backup ~/.story/story/data/priv_validator_state.json
							
						    echo -e "$GREEN Restarting both story and geth nodes (check out your node status to make sure your node is syncing).$NORMAL"
							sudo systemctl start story
							sudo systemctl start story-geth
						;;
						"Itrocket")
							echo -e "$GREEN Installing required dependencies.$NORMAL"
							sudo apt install curl tmux jq lz4 unzip aria2 -y

							echo -e "$GREEN Stopping both story and geth nodes.$NORMAL"
							sudo systemctl stop story story-geth
							
							echo -e "$GREEN Downloading both story and geth snapshots (this may take time, wait patiently).$NORMAL"
							cd $HOME
							aria2c -x 16 -s 16 -o story-archive-snap.tar.lz4 https://server-5.itrocket.net/testnet/story/story_2024-10-19_1575237_snap.tar.lz4
							aria2c -x 16 -s 16 -o geth-archive-snap.tar.lz4 https://server-5.itrocket.net/testnet/story/geth_story_2024-10-19_1575237_snap.tar.lz4

							echo -e "$GREEN Backing up the validator state (just in case).$NORMAL"
							cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup
							
							echo -e "$GREEN Deleting old data.$NORMAL"
							rm -rf $HOME/.story/story/data
							rm -rf $HOME/.story/geth/odyssey/geth/chaindata
							
							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							tar -I lz4 -xvf ~/story-archive-snap.tar.lz4 -C $HOME/.story/story
							tar -I lz4 -xvf ~/geth-archive-snap.tar.lz4 -C $HOME/.story/geth/odyssey/geth

							echo -e "$GREEN Restoring your validator state.$NORMAL"
							mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

							echo -e "$GREEN Restarting both story and geth nodes (check out your node status to make sure your node is syncing).$NORMAL"
							sudo systemctl restart story story-geth
						;;
					esac
					
                elif [ "$SNAPSHOT" == "pruned" ]; then
					case $PROVIDER in
						"Mandragora")
							echo -e "$GREEN Installing required dependencies.$NORMAL"
							sudo apt-get install wget lz4 -y

							echo -e "$GREEN Stopping both story and geth nodes.$NORMAL"
							sudo systemctl stop story-geth
							sudo systemctl stop story

							echo -e "$GREEN Backing up the validator state (just in case).$NORMAL"
							sudo cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

							echo -e "$GREEN Deleting old data.$NORMAL"
							sudo rm -rf $HOME/.story/geth/odyssey/geth/chaindata
							sudo rm -rf $HOME/.story/story/data

							echo -e "$GREEN Downloading both story and geth snapshots (this may take time, wait patiently).$NORMAL"
							wget -O geth_snapshot.lz4 https://snapshots2.mandragora.io/story/geth_snapshot.lz4
							wget -O story_snapshot.lz4 https://snapshots2.mandragora.io/story/story_snapshot.lz4

							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/odyssey/geth
							lz4 -c -d story_snapshot.lz4 | tar -xv -C $HOME/.story/story

							echo -e "$GREEN Deleting snapshot files.$NORMAL"
							sudo rm -v geth_snapshot.lz4
							sudo rm -v story_snapshot.lz4

							echo -e "$GREEN Restoring your validator state.$NORMAL"
							sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

							echo -e "$GREEN Restarting both story and geth nodes (check out your node status to make sure your node is syncing).$NORMAL"
							sudo systemctl start story-geth
							sudo systemctl start story
						;;
						"Josephtran")
							echo -e "$GREEN Installing required dependencies.$NORMAL"
							sudo apt-get install wget lz4 aria2 pv -y

							echo -e "$GREEN Stopping both story and geth nodes.$NORMAL"
							sudo systemctl stop story-geth
							sudo systemctl stop story
							
							echo -e "$GREEN Downloading both story and geth snapshots (this may take time, wait patiently).$NORMAL"
							cd $HOME
							rm -f Story_snapshot.lz4
							aria2c -x 16 -s 16 -k 1M https://story.josephtran.co/Story_snapshot.lz4
							rm -f Geth_snapshot.lz4
							aria2c -x 16 -s 16 -k 1M https://story.josephtran.co/Geth_snapshot.lz4
							
							echo -e "$GREEN Backing up the validator state (just in case).$NORMAL"
							cp ~/.story/story/data/priv_validator_state.json ~/.story/priv_validator_state.json.backup
							
							echo -e "$GREEN Deleting old data.$NORMAL"
							rm -rf ~/.story/story/data
							rm -rf ~/.story/geth/odyssey/geth/chaindata
							
							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							sudo mkdir -p /root/.story/story/data
							lz4 -d -c Story_snapshot.lz4 | pv | sudo tar xv -C ~/.story/story/ > /dev/null
							sudo mkdir -p /root/.story/geth/odyssey/geth/chaindata
							lz4 -d -c Geth_snapshot.lz4 | pv | sudo tar xv -C ~/.story/geth/odyssey/geth/ > /dev/null
							
							echo -e "$GREEN Restoring your validator state.$NORMAL"
							cp ~/.story/priv_validator_state.json.backup ~/.story/story/data/priv_validator_state.json
							
							echo -e "$GREEN Restarting both story and geth nodes (check out your node status to make sure your node is syncing).$NORMAL"
							sudo systemctl start story
							sudo systemctl start story-geth
						;;
						"Itrocket")
							echo -e "$GREEN Installing required dependencies.$NORMAL"
							sudo apt install curl tmux jq lz4 unzip -y

							echo -e "$GREEN Stopping both story and geth nodes.$NORMAL"
							sudo systemctl stop story story-geth

							echo -e "$GREEN Backing up the validator state (just in case).$NORMAL"
							cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup

							echo -e "$GREEN Deleting old data.$NORMAL"
							rm -rf $HOME/.story/story/data
							rm -rf $HOME/.story/geth/odyssey/geth/chaindata
							
							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							curl https://server-3.itrocket.net/testnet/story/story_2024-10-19_1576351_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/story
							curl https://server-3.itrocket.net/testnet/story/geth_story_2024-10-19_1576351_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/geth/odyssey/geth

							echo -e "$GREEN Restoring your validator state.$NORMAL"
							mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

							echo -e "$GREEN Restarting both story and geth nodes (check out your node status to make sure your node is syncing).$NORMAL"
							sudo systemctl restart story story-geth
						;;
					esac	
                else
					echo -e "$RED Wrong answer. Please select a valid option (archival or pruned). Aborting...$NORMAL"
					exit 0
				fi
        else
                echo -e "$RED Wrong answer. Please select valid option (Mandragora, Josephtran or Itrocket) Aborting...$NORMAL"
                exit 0
        fi
elif [ "$OPTION" == "3" ]; then
	echo -e "$GREEN Do you want to upgrade your story or story-geth binary (story/geth)? .$NORMAL"
        read -p "Selected binary (story or geth): " BINARY
		
    if [ "$BINARY" == "story" ]; then
		echo -e "$GREEN Downloading story binary.$NORMAL"
			cd $HOME
			wget https://github.com/piplabs/story/releases/download/v0.13.1/story-linux-amd64
			chmod +x story-linux-amd64
			sudo mv $HOME/geth-linux-amd64 /usr/local/bin/story
			story version	
			echo -e "$GREEN Make sure story version is the one running on the network. Otherwise, download the correct one and tag @danielmandragora if you want this script be up to date (you can still modify it to change the binary versions though).$NORMAL"
	elif [ "$BINARY" == "geth" ]; then
		echo -e "$GREEN Downloading geth binary.$NORMAL"
			wget https://github.com/piplabs/story-geth/releases/download/v0.11.0/geth-linux-amd64
			chmod +x geth-linux-amd64
			sudo mv $HOME/geth-linux-amd64 /usr/local/bin/story-geth
			story-geth version
		echo -e "$GREEN Make sure story-geth version is the one running on the network. Otherwise, download the correct one and tag @danielmandragora if you want this script be up to date (you can still modify it to change the binary versions though).$NORMAL"
	else
		echo -e "$RED Wrong snswer. Select a valid option (story or geth). Aborting...$NORMAL"
		exit 0
	fi
elif [ "$OPTION" == "4" ]; then
	echo -e "$GREEN Keep an eye at your node's latest block height and compare it with the latest block height of the external RPC endpoint. You will be fine as long as "Blocks behind:" value keeps increasing and finally catches up with the RPC endpoint latest block height.$NORMAL"

	BLOCK=$(curl -s localhost:26657/status | jq -r .result.sync_info.latest_block_height)
	if [ "$BLOCK" -lt 2 ]; then
		echo -e "$RED Wait until your node is active or start it before proceeding. Aborting...$NORMAL"
		exit 0
	fi
	while true; do 
		YOURBLOCK=$(curl -s localhost:26657/status | jq -r .result.sync_info.latest_block_height)
		RPCBLOCK=$(curl -s https://story-rpc.mandragora.io/status | jq -r .result.sync_info.latest_block_height)
		BEHIND=$(($RPCBLOCK - $YOURBLOCK))
		echo -e "$GREEN Your node latest block height: $YOURBLOCK | $YELLOW Latest block height on external RPC: $RPCBLOCK | $RED Blocks behind: $BEHIND $NORMAL (ctrl+q to quit)."
		sleep 2
	done
 elif [ "$OPTION" == "5" ]; then
	echo -e "$GREEN Do you want to see story or geth logs (story or geth)? (ctrl+q to quit) .$NORMAL"
	read -p "Selected option (story or geth): " OPT

	if [ "$OPT" == "story" ]; then
		sudo journalctl -u story -f -o cat
	elif [ "$OPT" == "geth" ]; then
		sudo journalctl -u story-geth -f -o cat
	else
		echo -e "$RED Wrong snswer. Select a valid option (story or geth). Aborting...$NORMAL"
		exit 0
	fi
  elif [ "$OPTION" == "6" ]; then
	echo -e "$GREEN Adding seeds (Mandragora & others).$NORMAL"
 	SEEDS=2df2b0b66f267939fea7fe098cfee696d6243cec@story-seed.mandragora.io:23656,434af9dae402ab9f1c8a8fc15eae2d68b5be3387@story-testnet-seed.itrocket.net:29656,3f472746f46493309650e5a033076689996c8881@story-testnet.rpc.kjnodes.com:26659
  	sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.story/story/config/config.toml
   	sudo systemctl restart story
  elif [ "$OPTION" == "7" ]; then
	echo -e "$GREEN Adding peers (Mandragora) .$NORMAL"
 	PEERS=$(curl -sS https://story-rpc.mandragora.io/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
  	sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.story/story/config/config.toml
   	sudo systemctl restart story
  elif [ "$OPTION" == "8" ]; then
 	 echo -e "$GREEN Adding geth enode (Mandrgora & others) .$NORMAL"
   	 story-geth --exec 'admin.addPeer("enode://3cf3215bf1a9516fb038bf9217fa149d3a5a7dcc8e3f6b34d3964c3e631af828c6cdad1627acc397db35df8e6a1efb2c597b2c7f1820a56b20956b93a45de5a6@story-geth.mandragora.io:30303")' attach ~/.story/geth/odyssey/geth.ipc
     	 sudo systemctl restart story-geth
  elif [ "$OPTION" == "9" ]; then
  	echo -e "$GREEN Downloading addrbook (Mandragora).$NORMAL"
   	sudo systemctl stop story
    	wget -O $HOME/.story/story/config/addrbook.json https://snapshots.mandragora.io/addrbook.json
    	sudo systemctl start story
 elif [ "$OPTION" == "10" ]; then
  	echo -e "$GREEN What node you want to stop (story, geth or both)?.$NORMAL"
        read -p "Selected option (story, geth or both): " OPT
	if [ "$OPT" == "story" ]; then
		sudo systemctl stop story
  		echo -e "$GREEN Geth node started (check out logs).$NORMAL"
	elif [ "$OPT" == "geth" ]; then
		sudo systemctl stop story-geth
  		echo -e "$GREEN Story node started (check out logs).$NORMAL"
  	elif [ "$OPT" == "both" ]; then
		sudo systemctl stop story
		sudo systemctl stop story-geth
  		echo -e "$GREEN Both story and geth nodes stopped (check out logs).$NORMAL"
	else
		echo -e "$RED Wrong snswer. Select a valid option (story, geth or both). Aborting...$NORMAL"
		exit 0
	fi
 elif [ "$OPTION" == "11" ]; then
  	echo -e "$GREEN What node you want to restart (story, geth or both)?.$NORMAL"
        read -p "Selected option (story, geth or both): " OPT
	if [ "$OPT" == "story" ]; then
		sudo systemctl start story
  		echo -e "$GREEN Story node started (check out logs).$NORMAL"
	elif [ "$OPT" == "geth" ]; then
		sudo systemctl start story-geth
  		echo -e "$GREEN Geth node started (check out logs).$NORMAL"
        elif [ "$OPT" == "both" ]; then
		sudo systemctl start story
		sudo systemctl start story-geth
  		echo -e "$GREEN Both story and geth nodes started (check out logs).$NORMAL"
	else
		echo -e "$RED Wrong snswer. Select a valid option (story, geth or both). Aborting...$NORMAL"
		exit 0
	fi
  else
	echo -e "$RED Wrong snswer. Select a valid option (1-11). Aborting...$NORMAL"
	exit 0
fi
