#!/bin/bash

curl -s https://raw.githubusercontent.com/McDaan/general/refs/heads/main/story/privkeyjsonrecover.sh | bash

RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"

echo -e "$GREEN Have you lost your priv_validator_key.json file and want to recover your validator? This tool will guide you so as to recreate the file. Story Protocol's design allows this to be done in case you still keep your validator account private key but not your priv_validator_key.json file. Note that you will need at least to identify your validator in an explorer to proceed. Let's get started!"
echo -e "$NORMAL-------------------------------------------------------------------"
echo -e "$YELLOW We will need 3 of 3 fields to be filled (1STFIELD, 2NDFIELD and 3RDFIELD) in the following JSON structure to complete the process successfully, are you ready? $NORMAL"
echo "-------------------------------------------------------------------"
echo -e "$NORMAL{"
echo "  \"address\": \"1STFIELD\","
echo "  \"pub_key\": {"
echo "    \"type\": \"tendermint/PubKeySecp256k1\","
echo "    \"value\": \"2NDFIELD\""
echo "  },"
echo "  \"priv_key\": {"
echo "    \"type\": \"tendermint/PrivKeySecp256k1\","
echo "    \"value\": \"3RDFIELD\""
echo "  }"
echo "}"
echo "-------------------------------------------------------------------"
echo -e "$GREEN The 1STFIELD is your validator HEX address. It has this format E3F9285F998C8554FCE49E00CC16BCEF39097928 and 40 characters. You can find yours in the explorer - here you have an example https://testnet.story.explorers.guru/validator/storyvaloper1u0ujshue3jz4fl8yncqvc94uauusj7fg9tx47g $NORMAL"
echo "-------------------------------------------------------------------"
read -p "What's your validator HEX address (1STFIELD): " OPTION1
echo "-------------------------------------------------------------------"
CHAR1=$(echo -n $OPTION1 | wc -m);
if [ "$CHAR1" -gt 40 ]; then
	echo -e "$RED Your response has more than 40 characters. Aborting...$NORMAL"
    exit 0
elif [ "$CHAR1" -lt 40 ]; then
	echo -e "$RED Your response has less than 40 characters. Aborting...$NORMAL"
    exit 0
fi
echo -e "$YELLOW Your 1STFIELD value is $OPTION1.$NORMAL"
echo "-------------------------------------------------------------------"
echo -e "$GREEN The 2NDFIELD is your validator uncompressed public key in base64 format. It has this format A9r+sVF6aMdPH2BJ0i0F9XQTR3xIcKCMLREI1OOA2ar+ and 44 characters. You can find yours by getting your storyvaloper address in an explorer, e.g. storyvaloper1u0ujshue3jz4fl8yncqvc94uauusj7fg9tx47g (with 51 chars) and through this API route thanks to the REST API provided by Daniel from TrustedPointed https://testnet.story.explorers.guru/validator/storyvaloper1u0ujshue3jz4fl8yncqvc94uauusj7fg9tx47g $NORMAL"
echo "-------------------------------------------------------------------"
read -p "What's your storyvaloper address so as to get your validator uncompressed public key in base64 format (2NDFIELD): " OPTION2
echo "-------------------------------------------------------------------"
CHAR2=$(echo -n $OPTION2 | wc -m);
if [ "$CHAR2" -gt 51 ]; then
	echo -e "$RED Your response has more than 51 characters. Aborting...$NORMAL"
    exit 0
elif [ "$CHAR2" -lt 51 ]; then
	echo -e "$RED Your response has less than 51 characters. Aborting...$NORMAL"
    exit 0
fi
FIELD2=$(curl -s https://api-story-testnet.trusted-point.com/cosmos/staking/v1beta1/validators/${OPTION2} | jq -r .validator.consensus_pubkey.key)
echo -e "$YELLOW Your 2NDFIELD value is $FIELD2.$NORMAL"
echo "-------------------------------------------------------------------"
echo -e "$GREEN The 3RDFIELD is your validator account private key in base64 format. It has this format H09dgNnmE5Z1vnF288Q+WOwoLWDWvtlU8GhAirKoFBM= and 44 characters. So as to get such a format, you will need to convert he validator account private key in HEX format to the base64 one. It has this format (0x)1f4f5d80d9e6139675be7176f3c43e58ec282d60d6bed954f068408ab2a81413 and 64 characters. You will need to navigate to this HEX to base64 converter website e.g. https://base64.guru/converter/encode/hex, paste your private key (without 0x), and get the base64 result $NORMAL"
echo "-------------------------------------------------------------------"
read -p "What's your validator account private key in base64 format (3RDFIELD): " OPTION3
echo "-------------------------------------------------------------------"
CHAR3=$(echo -n $OPTION3 | wc -m);
if [ "$CHAR3" -gt 44 ]; then
	echo -e "$RED Your response has more than 44 characters. Aborting...$NORMAL"
    exit 0
elif [ "$CHAR3" -lt 44 ]; then
	echo -e "$RED Your response has less than 44 characters. Aborting...$NORMAL"
    exit 0
fi
echo -e "$YELLOW Your 3RDFIELD value is $OPTION3.$NORMAL"
echo "-------------------------------------------------------------------"
echo -e "$GREEN Congratulations! You have recreated your original priv_validator_key.json file. You can now proceed to restore the file and recover your validator. Enjoy it! Please double-check that you have filled in correctly values in the respective fields. Repeat the process otherwise. The final JSON file has been saved to $HOME/priv_validator_key.json. In case you want to copy it, here you have the JSON result. Made with ♥ by Mandragora!"
cat > $HOME/priv_validator_key.json <<EOF
{
  "address": "$OPTION1",
  "pub_key": {
    "type": "tendermint/PubKeySecp256k1",
    "value": "$FIELD2"
  },
  "priv_key": {
    "type": "tendermint/PrivKeySecp256k1",
    "value": "$OPTION3"
  }
}
EOF
echo -e "$NORMAL-------------------------------------------------------------------"
echo "{"
echo "  \"address\": \"$OPTION1\","
echo "  \"pub_key\": {"
echo "    \"type\": \"tendermint/PubKeySecp256k1\","
echo "    \"value\": \"$FIELD2\""
echo "  },"
echo "  \"priv_key\": {"
echo "    \"type\": \"tendermint/PrivKeySecp256k1\","
echo "    \"value\": \"$OPTION3\""
echo "  }"
echo "}"
echo "-------------------------------------------------------------------"
