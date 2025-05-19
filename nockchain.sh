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
SEED_PHRASE=$(nockchain-wallet generate-seed 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$SEED_PHRASE" ]; then
  echo "无法自动生成种子短语，请手动输入种子短语："
  read -p "输入您的种子短语：" SEED_PHRASE
fi

# 生成主私钥
echo "生成主私钥..."
PRIVATE_KEY=$(nockchain-wallet gen-master-privkey --seedphrase "$SEED_PHRASE")
if [ $? -ne 0 ] || [ -z "$PRIVATE_KEY" ]; then
  echo "错误：无法生成主私钥，请检查种子短语或命令。"
  exit 1
fi

# 生成主公钥
echo "生成主公钥..."
PUBLIC_KEY=$(nockchain-wallet gen-master-pubkey --master-privkey "$PRIVATE_KEY")
if [ $? -ne 0 ] || [ -z "$PUBLIC_KEY" ]; then
  echo "错误：无法生成主公钥，请检查私钥或命令。"
  exit 1
fi

# 将所有信息保存到 wallet.txt
echo "保存钱包信息到 wallet.txt..."
{
  echo "种子短语: $SEED_PHRASE"
  echo "主私钥: $PRIVATE_KEY"
  echo "主公钥: $PUBLIC_KEY"
} > ../wallet.txt

# 检查是否成功生成 wallet.txt
if [ -f "../wallet.txt" ]; then
  echo "钱包信息已保存到 wallet.txt"
  echo "请妥善保管 wallet.txt 文件，切勿泄露种子短语或私钥！"
  echo "建议将 wallet.txt 移至安全位置（如加密存储）并删除脚本生成的副本。"
else
  echo "错误：未能生成 wallet.txt，请检查命令输出。"
  exit 1
fi

# 安装nockchain
make install-nockchain
make run-nockchain-leader
make run-nockchain-follower
