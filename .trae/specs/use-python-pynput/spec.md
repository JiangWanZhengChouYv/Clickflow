# 使用 Python pynput 实现鼠标点击

## Why
AppleScript 权限问题复杂，用户之前用 Python 写过连点器很好用，pynput 库简单可靠。

## What Changes
- 在 main.js 中调用 Python 脚本执行鼠标操作
- 使用 pynput 库控制鼠标
- Python 脚本需要安装 pynput: `pip install pynput`

## Impact
- 需要用户安装 pynput 库
- 需要给 Terminal 或 Python 辅助功能权限
- 点击功能将非常可靠

## 技术方案
1. Python 脚本使用 pynput.mouse.Controller
2. main.js 通过 spawn 调用 Python 脚本
3. 传递坐标和点击类型参数
