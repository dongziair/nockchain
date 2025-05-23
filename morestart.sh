#!/bin/bash

# 设置nockchain主目录
NOCKCHAIN_DIR="$HOME/nockchain"

# 检查主目录是否存在
if [ ! -d "$NOCKCHAIN_DIR" ]; then
    echo "错误：目录 $NOCKCHAIN_DIR 不存在"
    exit 1
fi

# 提示用户输入开始和结束数字
read -p "请输入开始数字: " START_NUM
read -p "请输入结束数字: " END_NUM

# 验证输入是否为正整数
if ! [[ "$START_NUM" =~ ^[0-9]+$ ]] || ! [[ "$END_NUM" =~ ^[0-9]+$ ]]; then
    echo "错误：请输入有效的正整数"
    exit 1
fi

# 验证开始数字是否小于等于结束数字
if [ "$START_NUM" -gt "$END_NUM" ]; then
    echo "错误：开始数字必须小于或等于结束数字"
    exit 1
fi

# 进入nockchain目录
cd "$NOCKCHAIN_DIR" || exit 1

# 创建screen会话的函数
create_session() {
    local node_num=$1
    local session_name="nockchain_node$node_num"
    local node_dir="node$node_num"

    # 检查节点目录是否存在，不存在则创建
    if [ ! -d "$node_dir" ]; then
        mkdir "$node_dir"
        echo "已创建节点目录: $node_dir"
    else
        echo "节点目录 $node_dir 已存在，跳过创建"
    fi
    
    # 进入节点目录
    cd "$node_dir" || exit 1
    
    # 复制.env文件并运行脚本
    screen -dmS "$session_name" bash -c "
        echo 'Starting nockchain in session $session_name' &&
        cp ../.env . &&
        sh ../scripts/run_nockchain_miner.sh &&
        echo 'Session $session_name running' &&
        exec bash"
    
    echo "已创建screen会话: $session_name for node$node_num"
    
    # 返回主目录以便下一次循环
    cd "$NOCKCHAIN_DIR" || exit 1
}

# 根据输入范围创建screen会话
for ((i=START_NUM; i<=END_NUM; i++))
do
    create_session $i
done

echo "已创建从 node$START_NUM 到 node$END_NUM 的screen会话"
echo "使用 'screen -ls' 查看所有会话"
echo "使用 'screen -r nockchain_nodeX' 进入特定会话（X为节点编号）"