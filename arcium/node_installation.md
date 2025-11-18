# Install Rust, Solana CLI, Docker, OpenSSL and Git
```
cd $HOME
```

## Rust
```
rm -rf ~/.rustup ~/.cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh
source $HOME/.cargo/env
rustc --version
```
## Solana CLI
```
curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
rustc --version && solana --version && anchor --version && node --version && yarn --version
```
## Docker

### Uninstall all conflicting packages
```
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
```
### Add Docker's official GPG key
```
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### Add the repository to apt sources
```
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```
```
sudo apt update
```
### Install latest version
```
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
### Check if Docker is running, if not start it
```
sudo systemctl status docker
```
*If not, start it:
```
sudo systemctl start docker
```
## OpenSSL and Git
```
sudo apt install git openssl
```
# Set up your Arcium node workspace
```
mkdir arcium-node-setup
cd arcium-node-setup
```
```
curl https://ipecho.net/plain ; echo
```
## Install Arcium Tooling
```
curl --proto '=https' --tlsv1.2 -sSfL https://install.arcium.com/ | bash
```
## Check version
```
arcium --version
arcup --version
```

# Generate required keypairs
*Make sure you are located at `arcium-node-setup` folder

## Node Authority Keypair
```
solana-keygen new --outfile node-keypair.json --no-bip39-passphrase
```
## Callback Authority Keypair
```
solana-keygen new --outfile callback-kp.json --no-bip39-passphrase
```
## Identity Keypair
```
openssl genpkey -algorithm Ed25519 -out identity.pem
```
**Keep the keys safe and store them securely.**


# Initialize node accounts
```
arcium init-arx-accs \
  --keypair-path node-keypair.json \
  --callback-keypair-path callback-kp.json \
  --peer-keypair-path identity.pem \
  --node-offset <your-node-offset> \
  --ip-address <your-node-ip> \
  --rpc-url https://api.devnet.solana.com
```
*Make sure you see a confirmation that your node accounts have been initialized. It's suggested to use a dedicated Solana Devnet RPC endpoint for better reliability.

# Configure your node

## Open 8080 port and create `node-config.toml` file at `arcium-node-setup` folder
```
ufw allow 8080
cd arcium-node-setup
```
```
nano node-config.toml
```
```
[node]
offset = <your-node-offset>  # Your node offset from step 5
hardware_claim = 0  # Currently not required to specify, just use 0
starting_epoch = 0
ending_epoch = 9223372036854775807

[network]
address = "0.0.0.0" # Bind to all interfaces for reliability behind NAT/firewalls

[solana]
endpoint_rpc = "<your-rpc-provider-url-here>"  # Replace with your RPC provider URL or use default https://api.devnet.solana.com
endpoint_wss = "<your-rpc-websocket-url-here>"   # Replace with your RPC provider WebSocket URL or use default wss://api.devnet.solana.com
cluster = "Devnet"
commitment.commitment = "confirmed"  # or "processed" or "finalized"
```
*Save the file.
