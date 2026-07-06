# Clickflow - 构建说明

## 环境要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本（或 Swift 5.9+ 工具链）
- Swift Package Manager

## 快速开始

### 开发构建

```bash
swift build
```

构建产物位于 `.build/debug/` 目录。

### 发布构建

```bash
swift build -c release
```

构建产物位于 `.build/release/` 目录。

### 清理构建

```bash
swift package clean
```

## 创建 .app Bundle

### 方法一：手动创建

1. 首先进行发布构建：

```bash
swift build -c release
```

2. 创建应用包结构：

```bash
mkdir -p build/Clickflow.app/Contents/MacOS
mkdir -p build/Clickflow.app/Contents/Resources
```

3. 复制可执行文件：

```bash
cp .build/release/Clickflow build/Clickflow.app/Contents/MacOS/
```

4. 复制 Info.plist：

```bash
cp Resources/Info.plist build/Clickflow.app/Contents/
```

### 方法二：使用 Xcode

```bash
# 生成 Xcode 项目
swift package generate-xcodeproj

# 在 Xcode 中打开并构建
open Clickflow.xcodeproj
```

## GitHub Actions 自动构建

项目已配置 GitHub Actions 自动构建，工作流文件位于 `.github/workflows/build.yml`。

触发条件：
- 推送到 `main` 分支
- 提交 tag

构建产物：
- Clickflow.app
- 打包后的 DMG 安装包

## 项目结构

```
Clickflow/
├── Sources/                # 源代码
│   └── Clickflow/         # 主模块
├── Resources/             # 资源文件
│   └── Info.plist        # 应用配置
├── Package.swift         # Swift Package 配置
├── .github/
│   └── workflows/
│       └── build.yml     # GitHub Actions 配置
└── BUILD.md             # 本文档
```

## 常见问题

### 1. 应用无法打开（权限问题）

在 macOS 上，首次打开可能会提示"无法验证开发者"。解决方法：

1. 右键点击应用 → 打开
2. 或者在系统设置 → 安全性与隐私中允许运行

### 2. 辅助功能权限

应用需要辅助功能权限才能控制鼠标。首次使用时：

1. 系统会自动请求权限
2. 在系统设置 → 隐私与安全性 → 辅助功能中启用
3. 重启应用使权限生效

### 3. 构建失败

确保已安装正确版本的 Xcode 和 Swift 工具链：

```bash
swift --version
xcode-select --print-path
```

## 开发者说明

### 添加依赖

在 `Package.swift` 中添加依赖，然后运行：

```bash
swift package resolve
```

### 运行测试

```bash
swift test
```

## 许可证

详见 LICENSE 文件。
