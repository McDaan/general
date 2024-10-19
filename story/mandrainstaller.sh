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
echo "1) INSTALL A NODE (simple and standard setup)"
echo "2) APPLY A SNAPSHOT"
echo "3) UPDATE TO A SPECIFIC VERSION"
echo "4) NODE STATUS"
echo -e "5) CHECK LOGS (STORY+GETH) $NORMAL"

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
			wget https://github.com/piplabs/story-geth/releases/download/v0.9.4/geth-linux-amd64
			chmod +x geth-linux-amd64
			sudo mv $HOME/geth-linux-amd64 /usr/local/bin/story-geth
			story-geth version
			
			wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.11.0-aac4bfe.tar.gz
			tar -xzvf story-linux-amd64-0.11.0-aac4bfe.tar.gz
			sudo cp $HOME/story-linux-amd64-0.11.0-aac4bfe/story /usr/local/bin/story
			story version
			
			echo -e "$GREEN Initializing node.$NORMAL"
			echo -e "$GREEN Choose a node moniker? $NORMAL"
			read -p "Your node noniker: " MONIKER
			story init --network iliad --moniker $MONIKER
			
			echo -e "$GREEN Creating service files for story and geth.$NORMAL"
sudo tee /etc/systemd/system/story-geth.service <<EOF
   [Unit]
Description=Story Geth Client
 After=network.target
		
[Service]
User=root
ExecStart=/usr/local/bin/story-geth --iliad --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
	
[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/story.service <<EOF
  [Unit]
Description=Story Consensus Client
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
							sudo rm -rf $HOME/.story/geth/iliad/geth/chaindata
							sudo rm -rf $HOME/.story/story/data

							echo -e "$GREEN Downloading both story and geth snapshots (this may take time, wait patiently).$NORMAL"
							wget -O geth_snapshot.lz4 https://snapshots.mandragora.io/geth_snapshot.lz4
							wget -O story_snapshot.lz4 https://snapshots.mandragora.io/story_snapshot.lz4

							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/iliad/geth
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
							rm -rf ~/.story/geth/iliad/geth/chaindata
							
							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							sudo mkdir -p /root/.story/story/data
							lz4 -d -c Story_snapshot.lz4 | pv | sudo tar xv -C ~/.story/story/ > /dev/null
							sudo mkdir -p /root/.story/geth/iliad/geth/chaindata
							lz4 -d -c Geth_snapshot.lz4 | pv | sudo tar xv -C ~/.story/geth/iliad/geth/ > /dev/null
							
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
							rm -rf $HOME/.story/geth/iliad/geth/chaindata
							
							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							tar -I lz4 -xvf ~/story-archive-snap.tar.lz4 -C $HOME/.story/story
							tar -I lz4 -xvf ~/geth-archive-snap.tar.lz4 -C $HOME/.story/geth/iliad/geth

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
							sudo rm -rf $HOME/.story/geth/iliad/geth/chaindata
							sudo rm -rf $HOME/.story/story/data

							echo -e "$GREEN Downloading both story and geth snapshots (this may take time, wait patiently).$NORMAL"
							wget -O geth_snapshot.lz4 https://snapshots2.mandragora.io/story/geth_snapshot.lz4
							wget -O story_snapshot.lz4 https://snapshots2.mandragora.io/story/story_snapshot.lz4

							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/iliad/geth
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
							rm -rf ~/.story/geth/iliad/geth/chaindata
							
							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							sudo mkdir -p /root/.story/story/data
							lz4 -d -c Story_snapshot.lz4 | pv | sudo tar xv -C ~/.story/story/ > /dev/null
							sudo mkdir -p /root/.story/geth/iliad/geth/chaindata
							lz4 -d -c Geth_snapshot.lz4 | pv | sudo tar xv -C ~/.story/geth/iliad/geth/ > /dev/null
							
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
							rm -rf $HOME/.story/geth/iliad/geth/chaindata
							
							echo -e "$GREEN Decompressing both story and geth snapshot files (this may take time, wait patiently).$NORMAL"
							curl https://server-3.itrocket.net/testnet/story/story_2024-10-19_1576351_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/story
							curl https://server-3.itrocket.net/testnet/story/geth_story_2024-10-19_1576351_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/geth/iliad/geth

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
			wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.11.0-aac4bfe.tar.gz
			tar -xzvf story-linux-amd64-0.11.0-aac4bfe.tar.gz
			sudo cp $HOME/story-linux-amd64-0.11.0-aac4bfe/story /usr/local/bin/story
			story version	
			echo -e "$GREEN Make sure story-geth version is the one running on the network. Otherwise, download the correct one and tag @danielmandragora if you want this script be up to date (you can still modify it to change the binary versions though).$NORMAL"
	elif [ "$BINARY" == "geth" ]; then
		echo -e "$GREEN Downloading geth binary.$NORMAL"
			wget https://github.com/piplabs/story-geth/releases/download/v0.9.4/geth-linux-amd64
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
	
	while true; do 
		YOURBLOCK=$(curl -s localhost:26657/status | jq -r .result.sync_info.latest_block_height)
		RPCBLOCK=$(curl -s https://story-rpc.mandragora.io/status | jq -r .result.sync_info.latest_block_height)
		$BEHIND=$(($RPCBLOCK - YOURBLOCK))
		echo -e "$NORMAL Your node latest block height: $YOURBLOCK | Latest block height on external RPC: $RPCBLOCK | Blocks behind: $BEHIND (ctrl+q to quit).$NORMAL"
		sleep 2
	done
 elif [ "$OPTION" == "5" ]; then
	echo -e "$GREEN Do you want to see story or geth logs (story or geth)? .$NORMAL"
	read -p "Selected option (story or geth): " $OPT

	 if [ "$BINARY" == "story" ]; then
		sudo journalctl -u story -f -o cat
	elif [ "$BINARY" == "geth" ]; then
		sudo journalctl -u story-geth -f -o cat
	else
		echo -e "$RED Wrong snswer. Select a valid option (story or geth). Aborting...$NORMAL"
		exit 0
	fi
fi
