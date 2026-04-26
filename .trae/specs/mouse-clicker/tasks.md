# macOS 鼠标连点器 - The Implementation Plan (Decomposed and Prioritized Task List)

## [x] Task 1: 项目初始化与技术栈搭建
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 初始化 Python 项目结构
  - 配置 PyQt5 依赖
  - 搭建基础项目框架
- **Acceptance Criteria Addressed**: AC-11
- **Test Requirements**:
  - `programmatic` TR-1.1: 项目可以正常初始化并运行基础 PyQt5 窗口
  - `human-judgement` TR-1.2: 项目结构清晰合理
- **Notes**: 使用 requirements.txt 管理依赖

## [x] Task 2: 主界面框架设计
- **Priority**: P0
- **Depends On**: Task 1
- **Description**: 
  - 设计并实现主界面布局
  - 包含模式切换、点位配置区、时间设置区、操作控制区
  - 实现基础 UI 组件
- **Acceptance Criteria Addressed**: AC-11
- **Test Requirements**:
  - `programmatic` TR-2.1: 主界面可以正常显示所有组件
  - `human-judgement` TR-2.2: 界面布局清晰、直观、美观
- **Notes**: 使用 PyQt5 的布局管理器

## [x] Task 3: 实现固定单点连续点击模式
- **Priority**: P0
- **Depends On**: Task 2
- **Description**: 
  - 集成 macOS 鼠标控制 API (使用 Quartz 或 PyMouse)
  - 实现单点位连续点击功能
  - 集成到主界面
- **Acceptance Criteria Addressed**: AC-1, AC-8
- **Test Requirements**:
  - `programmatic` TR-3.1: 可以在指定坐标以指定间隔连续点击
  - `programmatic` TR-3.2: 支持左键和右键选择
- **Notes**: 需要处理 macOS 权限问题

## [x] Task 4: 实现多点顺序循环连点模式
- **Priority**: P0
- **Depends On**: Task 3
- **Description**: 
  - 实现点位数据结构
  - 实现多点顺序循环点击逻辑 (1→2→3→1→2→3)
  - 限制最多 3 个点位
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-4.1: 可以按照顺序循环点击多个点位
  - `programmatic` TR-4.2: 超过 3 个点位时给出提示并不允许添加
- **Notes**: 严格按照 1→2→3 顺序循环

## [x] Task 5: 实现屏幕坐标拾取功能
- **Priority**: P0
- **Depends On**: Task 2
- **Description**: 
  - 实现屏幕坐标拾取功能
  - 提供拾取按钮和状态反馈
  - 将拾取的坐标显示在界面上
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `programmatic` TR-5.1: 可以正确拾取屏幕任意位置的坐标
  - `human-judgement` TR-5.2: 拾取过程有明确的视觉反馈
- **Notes**: 使用 Quartz Event Services 获取鼠标位置

## [x] Task 6: 实现点位管理功能
- **Priority**: P0
- **Depends On**: Task 4, Task 5
- **Description**: 
  - 实现手动输入坐标功能
  - 实现编辑、删除、清空点位功能
  - 实时显示已添加的点位列表
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `programmatic` TR-6.1: 可以手动输入、编辑、删除点位
  - `programmatic` TR-6.2: 界面实时更新点位列表
  - `programmatic` TR-6.3: 可以一次性清空所有点位
- **Notes**: 提供清晰的点位列表显示

## [x] Task 7: 实现时间设置与点击次数控制
- **Priority**: P0
- **Depends On**: Task 2
- **Description**: 
  - 实现毫秒级间隔时间输入
  - 实现点击次数设置
  - 实现无限循环模式
- **Acceptance Criteria Addressed**: AC-5, AC-6
- **Test Requirements**:
  - `programmatic` TR-7.1: 可以设置毫秒级的间隔时间
  - `programmatic` TR-7.2: 可以设置具体点击次数
  - `programmatic` TR-7.3: 可以切换无限循环模式
- **Notes**: 添加输入验证确保合法值

## [x] Task 8: 实现操作控制功能
- **Priority**: P0
- **Depends On**: Task 3, Task 4
- **Description**: 
  - 实现开始、暂停、停止按钮
  - 实现相应的状态管理
  - 提供视觉状态反馈
- **Acceptance Criteria Addressed**: AC-7
- **Test Requirements**:
  - `programmatic` TR-8.1: 点击开始按钮启动连点
  - `programmatic` TR-8.2: 点击暂停按钮暂停连点
  - `programmatic` TR-8.3: 点击停止按钮完全停止并重置
- **Notes**: 暂停后可以继续，停止后重置状态

## [x] Task 9: 实现全局快捷键功能
- **Priority**: P1
- **Depends On**: Task 8
- **Description**: 
  - 集成全局快捷键功能
  - 实现快捷键设置界面
  - 绑定到开始/停止功能
- **Acceptance Criteria Addressed**: AC-9
- **Test Requirements**:
  - `programmatic` TR-9.1: 全局快捷键可以正常工作
  - `human-judgement` TR-9.2: 快捷键设置界面清晰易用
- **Notes**: 使用 pynput 或 Quartz 实现全局快捷键

## [x] Task 10: 应用打包与性能优化
- **Priority**: P0
- **Depends On**: Task 1-9
- **Description**: 
  - 使用 PyInstaller 打包成 .app 文件
  - 添加应用图标
  - 优化体积和启动速度
  - 创建 DMG 安装包
- **Acceptance Criteria Addressed**: AC-10
- **Test Requirements**:
  - `programmatic` TR-10.1: .app 文件大小 < 200MB
  - `programmatic` TR-10.2: 冷启动速度 < 0.5 秒
  - `programmatic` TR-10.3: 生成可用的 DMG 安装包
  - `programmatic` TR-10.4: 适配 Intel 和 Apple Silicon 架构
- **Notes**: 使用 PyInstaller 的优化选项，精简依赖
