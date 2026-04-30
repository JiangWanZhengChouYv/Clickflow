#!/bin/bash
cd /Users/markzhang/Desktop/GithubClone/Clickflow

echo "1. 检查当前 git 状态..."
git status

echo -e "\n2. 添加修改的文件..."
git add package.json

echo -e "\n3. 提交更改..."
git commit -m "fix: 修复连点器功能问题"

echo -e "\n4. 检查提交..."
git log --oneline -3

echo -e "\n5. 尝试直接使用 HTTPS 推送（绕过代理）..."
GIT_SSH_COMMAND="ssh -o ProxyCommand=none" git push origin main

echo -e "\n完成！"
