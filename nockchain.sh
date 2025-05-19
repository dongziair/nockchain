#!/bin/bash

echo "自行安装git，make，rust"
echo "克隆 Nockchain 仓库"
if [ -d "nockchain" ]; then
    echo "Nockchain directory already exists. Pulling latest changes..."
    cd nockchain
    git pull
    cd ..
else
    git clone https://github.com/zorp-corp/nockchain.git
fi
cd nockchain
make build-hoon-all
make build
# 安装钱包
make install-nockchain-wallet

NOCKCHAIN_PATH="$HOME/nockchain/target/release"

# 检查是否已添加 PATH
if ! grep -Fx "export PATH=\"\$PATH:$NOCKCHAIN_PATH\"" "$HOME/.zshrc" > /dev/null; then
  echo "添加 PATH 到 .zshrc..."
  echo "export PATH=\"\$PATH:$NOCKCHAIN_PATH\"" >> "$HOME/.zshrc"
else
  echo "PATH 已存在于 .zshrc，无需重复添加。"
fi

# 应用 .zshrc 更改
echo "应用 .zshrc 更改..."
source "$HOME/.zshrc"

# 尝试生成种子短语（假设命令为 generate-seed）
echo "尝试生成种子短语..."
nockchain-wallet keygen

# 安装nockchain
make install-nockchain
make run-nockchain-leader
make run-nockchain-follower
