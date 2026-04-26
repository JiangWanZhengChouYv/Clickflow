# macOS 鼠标连点器 - 构建说明

## 环境要求

- macOS 10.13 或更高版本
- Python 3.7 或更高版本
- Xcode 命令行工具

## 快速开始

### 1. 安装依赖

```bash
# 安装 Python 依赖
pip install -r requirements.txt

# (可选) 安装 Pillow 用于生成图标
pip install Pillow

# (可选) 安装 create-dmg 工具（用于创建美观的 DMG）
brew install create-dmg
```

### 2. 一键构建

```bash
# 完整构建（包括 .app 和 DMG）
./build.sh

# 仅构建 .app
./build.sh --app

# 仅清理构建文件
./build.sh --clean
```

## 手动构建步骤

### 1. 创建虚拟环境（推荐）

```bash
python3 -m venv venv
source venv/bin/activate
pip install -U pip
pip install -r requirements.txt
```

### 2. 生成应用图标

```bash
python3 create_icon.py
```

### 3. 使用 PyInstaller 构建

```bash
pyinstaller --clean mouse_clicker.spec
```

### 4. 创建 DMG 安装包

```bash
# 使用 create-dmg（推荐）
create-dmg \
    --volname "macOS 鼠标连点器" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --icon-size 100 \
    --icon "macOS 鼠标连点器.app" 200 190 \
    --hide-extension "macOS 鼠标连点器.app" \
    --app-drop-link 600 185 \
    "dist/macOS 鼠标连点器-1.0.0.dmg" \
    "dist/"

# 或者使用 hdiutil（基础方式）
hdiutil create -volname "macOS 鼠标连点器" \
    -srcfolder "dist/macOS 鼠标连点器.app" \
    -ov -format UDZO \
    "dist/macOS 鼠标连点器-1.0.0.dmg"
```

## 构建配置说明

### PyInstaller 配置 (mouse_clicker.spec)

- **hiddenimports**: 包含 PyQt5、pynput 和 pyobjc 相关模块
- **excludes**: 排除不需要的模块以减小体积（如 tkinter、matplotlib 等）
- **optimizations**: 启用 strip 和 UPX 压缩
- **console**: 设置为 False，无控制台窗口
- **info_plist**: 配置 macOS 应用信息

### 优化选项

- `strip=True`: 去除调试符号
- `upx=True`: 使用 UPX 压缩
- 排除不必要的模块
- 使用单文件模式

## 构建产物

构建完成后，以下文件将出现在 `dist/` 目录中：

- `macOS 鼠标连点器.app`: macOS 应用包
- `macOS 鼠标连点器-1.0.0.dmg`: DMG 安装包

## 常见问题

### 1. 应用无法打开（权限问题）

在 macOS 上，首次打开可能会提示"无法验证开发者"。解决方法：

1. 右键点击应用 → 打开
2. 或者在系统设置 → 安全性与隐私中允许运行

### 2. 图标显示不正常

确保 `assets/icon.icns` 文件存在且格式正确。重新生成图标：

```bash
python3 create_icon.py
```

### 3. 构建体积过大

检查是否包含了不必要的依赖，确保 `excludes` 列表配置正确。

### 4. pyobjc 相关问题

确保在 macOS 系统上构建，并且已正确安装 pyobjc。

## 性能优化建议

1. **减小体积**:
   - 使用虚拟环境仅安装必要依赖
   - 确保 excludes 列表配置完整
   - 启用 UPX 压缩

2. **提升启动速度**:
   - 使用单文件模式
   - 避免延迟导入
   - 优化 PyQt5 的加载

3. **跨架构支持**:
   - 在 Apple Silicon 和 Intel 上分别构建
   - 或者使用通用二进制（需要额外配置）

## 开发者说明

项目结构：

```
/workspace
├── src/                  # 源代码
│   ├── main.py          # 主程序入口
│   ├── mouse_controller.py  # 鼠标控制模块
│   └── hotkey_manager.py    # 快捷键管理模块
├── assets/              # 资源文件（图标等）
├── mouse_clicker.spec   # PyInstaller 配置
├── build.sh            # 构建脚本
├── create_icon.py      # 图标生成脚本
└── requirements.txt    # Python 依赖
```

## 许可证

详见 LICENSE 文件。
