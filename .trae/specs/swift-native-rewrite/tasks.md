# Clickflow Swift 原生重写 - The Implementation Plan (Decomposed and Prioritized Task List)

## [x] Task 1: 创建 Swift 项目基础结构
- **Priority**: high
- **Depends On**: None
- **Description**:
  - 使用 Swift Package Manager 创建 macOS 应用项目
  - 配置最低支持 macOS 13.0
  - 创建基础目录结构：Models、ViewModels、Services、Resources
  - 配置 Bundle Identifier 和版本号
  - 创建最小可运行应用（空白窗口）
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-1.1: 执行 `swift build` 编译成功，无错误
  - `programmatic` TR-1.2: 生成的可执行文件可以启动并显示窗口
- **Notes**: 已完成

## [ ] Task 2: 实现主界面 UI
- **Priority**: high
- **Depends On**: Task 1
- **Description**:
  - 使用 SwiftUI 构建主界面，包含所有功能区域
  - 模式选择：固定单点 / 多点循环
  - 点位配置：坐标输入、拾取按钮、点位列表、添加/编辑/删除/清空按钮
  - 时间设置：间隔时间、点击次数、无限循环复选框
  - 鼠标按键选择：左键 / 右键
  - 操作控制：开始、暂停、停止按钮
  - 运行状态指示器
  - 全局快捷键提示
  - 遵循 macOS HIG 设计规范
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `human-judgement` TR-2.1: 界面布局合理，视觉效果符合 macOS 风格
  - `human-judgement` TR-2.2: 所有 UI 控件完整呈现，无缺失
  - `programmatic` TR-2.3: 编译成功，界面可正常显示
- **Notes**: 使用 SwiftUI 的 Form、Section、Picker 等原生控件

## [ ] Task 3: 实现鼠标点击控制核心功能
- **Priority**: high
- **Depends On**: Task 2
- **Description**:
  - 使用 Core Graphics (CGEvent) 实现底层鼠标点击
  - 支持左键和右键点击
  - 支持移动鼠标到指定坐标
  - 创建 MouseControlService 服务类
  - 实现点击循环逻辑，支持指定次数和无限循环
  - 实现暂停/继续/停止控制
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `programmatic` TR-3.1: 调用点击 API 能在指定坐标产生鼠标点击事件
  - `programmatic` TR-3.2: 指定次数点击完成后自动停止
  - `programmatic` TR-3.3: 暂停/继续/停止功能正常工作
- **Notes**: 需要辅助功能权限，添加权限检查和提示

## [ ] Task 4: 实现坐标拾取功能
- **Priority**: high
- **Depends On**: Task 2
- **Description**:
  - 使用 NSEvent / CGEvent 获取当前鼠标位置
  - 点击"拾取坐标"按钮后填充坐标输入框
  - 提供延时拾取功能（用户有时间移动鼠标）
- **Acceptance Criteria Addressed**: AC-5
- **Test Requirements**:
  - `programmatic` TR-4.1: 点击拾取按钮能正确获取当前鼠标坐标
  - `programmatic` TR-4.2: 坐标值准确，精度到像素
- **Notes**: 可以提供 3 秒倒计时后自动拾取

## [ ] Task 5: 实现多点循环功能
- **Priority**: medium
- **Depends On**: Task 3
- **Description**:
  - 实现点位数据模型（Point Model）
  - 实现点位列表管理：添加、编辑、删除、清空
  - 实现多点循环点击逻辑，按顺序循环点击各个点位
  - 单点模式下限制只能有 1 个点位
  - 多点模式下最多支持 3 个点位
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `programmatic` TR-5.1: 多点模式下按顺序循环点击各点位
  - `programmatic` TR-5.2: 单点模式下自动限制为 1 个点位
  - `human-judgement` TR-5.3: 点位列表 UI 交互流畅
- **Notes**: 点位列表支持选中高亮

## [ ] Task 5.1: 实现菜单栏图标
- **Priority**: medium
- **Depends On**: Task 3
- **Description**:
  - 添加菜单栏图标（NSStatusItem）
  - 实现菜单项：开始/停止、显示主窗口、退出
  - 点击菜单栏图标显示下拉菜单
  - 运行状态变化时更新菜单状态
- **Acceptance Criteria Addressed**: AC-7
- **Test Requirements**:
  - `human-judgement` TR-5.1.1: 菜单栏图标正常显示
  - `human-judgement` TR-5.1.2: 菜单项功能正常
  - `programmatic` TR-5.1.3: 点击菜单项能触发对应操作
- **Notes**: 使用 SF Symbols 图标

## [ ] Task 5.2: 实现全局快捷键
- **Priority**: medium
- **Depends On**: Task 3
- **Description**:
  - 注册全局快捷键 Cmd + Shift + S
  - 按下快捷键切换开始/停止状态
  - 应用在后台也能响应快捷键
- **Acceptance Criteria Addressed**: AC-6
- **Test Requirements**:
  - `human-judgement` TR-5.2.1: 应用在后台时按快捷键能触发
  - `programmatic` TR-5.2.2: 快捷键能正确切换运行状态
- **Notes**: 使用 Carbon 的 RegisterEventHotKey 或 SwiftUI 的 keyboardShortcut

## [ ] Task 6: 配置 GitHub Actions 构建
- **Priority**: high
- **Depends On**: Task 1
- **Description**:
  - 创建新的 build.yml workflow 文件
  - 配置 macOS 构建环境
  - 配置 Xcode 版本
  - 添加构建步骤：swift build
  - 添加打包步骤：生成 .app 和 .dmg
  - 配置工件上传
- **Acceptance Criteria Addressed**: AC-8
- **Test Requirements**:
  - `programmatic` TR-6.1: Workflow 文件语法正确
  - `programmatic` TR-6.2: Actions 能成功触发并完成构建
  - `programmatic` TR-6.3: 构建产物包含可运行的 .app 和 .dmg
- **Notes**: 替换掉旧的 Electron 构建配置

## [ ] Task 7: 应用图标和打包配置
- **Priority**: medium
- **Depends On**: Task 2
- **Description**:
  - 创建应用图标（AppIcon）
  - 配置 Info.plist 中的图标设置
  - 配置 DMG 打包脚本
  - 设置正确的版权信息
- **Acceptance Criteria Addressed**: AC-10
- **Test Requirements**:
  - `human-judgement` TR-7.1: 应用图标显示正确
  - `programmatic` TR-7.2: DMG 打包成功
  - `human-judgement` TR-7.3: 安装后能正常运行，无"已损坏"提示
- **Notes**: 图标可以先使用 SF Symbols 临时占位

## [ ] Task 8: 本地编译测试
- **Priority**: high
- **Depends On**: Task 3, Task 4
- **Description**:
  - 在本地执行完整的 release 编译
  - 测试基本功能是否正常
  - 修复发现的编译错误和运行时问题
- **Acceptance Criteria Addressed**: AC-1, AC-3, AC-5
- **Test Requirements**:
  - `programmatic` TR-8.1: Release 编译成功
  - `programmatic` TR-8.2: 应用启动无崩溃
  - `human-judgement` TR-8.3: 核心功能（点击、拾取）可正常使用
- **Notes**: 在推送前确保本地编译通过

## [ ] Task 9: 清理旧文件和更新文档
- **Priority**: medium
- **Depends On**: Task 8
- **Description**:
  - 删除所有 Electron 相关文件：package.json, main.js, preload.js, src/ 等
  - 删除所有 Python 相关文件：mouse_control.py, requirements.txt 等
  - 删除旧的构建配置：build.sh, mouse_clicker.spec 等
  - 更新 .gitignore 文件
  - 添加 AGENTS.md 记录完成事项
  - 更新 BUILD.md 文档
- **Acceptance Criteria Addressed**: AC-9
- **Test Requirements**:
  - `programmatic` TR-9.1: 所有旧文件已删除
  - `programmatic` TR-9.2: .gitignore 已更新
  - `programmatic` TR-9.3: AGENTS.md 已创建
- **Notes**: 删除前确认没有需要保留的文件

## [ ] Task 10: 提交代码并验证 Actions
- **Priority**: high
- **Depends On**: Task 8, Task 6, Task 9
- **Description**:
  - 检查 Git 状态
  - 提交所有更改
  - 推送到 origin main
  - 等待 GitHub Actions 构建完成
  - 验证构建成功
- **Acceptance Criteria Addressed**: AC-8
- **Test Requirements**:
  - `programmatic` TR-10.1: Git 提交成功
  - `programmatic` TR-10.2: 推送成功
  - `programmatic` TR-10.3: GitHub Actions 构建成功
- **Notes**: 使用 gh-cli 或浏览器检查 Actions 状态

## [ ] Task 11: 编译软件供用户测试
- **Priority**: high
- **Depends On**: Task 10
- **Description**:
  - 本地编译 Release 版本
  - 生成 .app 应用包
  - 放到"临时/"文件夹中供用户测试
  - 应用名称不带后缀
- **Acceptance Criteria Addressed**: AC-10
- **Test Requirements**:
  - `programmatic` TR-11.1: Release 编译成功
  - `human-judgement` TR-11.2: 应用可正常启动和使用
  - `programmatic` TR-11.3: 文件在"临时/"文件夹中
- **Notes**: 不要给编译出来的软件加后缀

## [ ] Task 5.3: 实现运行时悬浮窗
- **Priority**: low
- **Depends On**: Task 5.1
- **Description**:
  - 实现一个小型悬浮窗，显示运行状态
  - 悬浮窗始终置顶
  - 可拖拽移动
  - 点击可快速暂停/停止
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `human-judgement` TR-5.3.1: 悬浮窗显示正常
  - `human-judgement` TR-5.3.2: 悬浮窗可拖拽
  - `programmatic` TR-5.3.3: 点击操作正常
- **Notes**: 可选功能，时间充裕时实现
