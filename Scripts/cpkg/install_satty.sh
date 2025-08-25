#!/usr/bin/env bash

# Install satty
wget https://github.com/gabm/Satty/releases/latest/download/satty-x86_64-unknown-linux-gnu.tar.gz
mkdir satty
mv satty-x86_64-unknown-linux-gnu.tar.gz satty/
cd satty
tar -xzf satty-x86_64-unknown-linux-gnu.tar.gz
rm satty-x86_64-unknown-linux-gnu.tar.gz
chmod +x satty
sudo mv satty /usr/local/bin/
cd ..
rm -rf satty