# General information for Story Protocol

Current chain-id: **iliad-0**

# Add a new addrbook file

```
sudo systemctl stop namadad

wget -O $HOME/.story/story/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/story/addrbook.json

sudo systemctl start namadad
```

