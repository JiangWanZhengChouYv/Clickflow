# macOS 轻量化鼠标连点器 - 产品需求文档

## Overview
- **Summary**: 一款专为 macOS 平台设计的轻量化鼠标连点器图形化应用，支持多种连点模式、自定义时间间隔和连点位置，提供直观的控制界面。
- **Purpose**: 解决用户在需要重复鼠标点击操作时的手动操作负担，提高工作效率，适用于游戏、数据录入等场景。
- **Target Users**: 需要进行大量重复点击操作的 macOS 用户，包括游戏玩家、数据处理人员等。

## Goals
- 提供多种连点运行模式，满足不同场景需求
- 实现毫秒级精准的时间间隔设置
- 支持灵活的连点位置自定义
- 提供简洁直观的控制界面
- 确保应用轻量化，性能优良
- 支持 macOS 全芯片机型

## Non-Goals (Out of Scope)
- 不支持 Windows 或 Linux 平台
- 不包含键盘宏功能
- 不提供网络功能或云同步
- 不支持复杂的脚本编写
- 不包含广告或用户数据收集

## Background & Context
- 市场上存在多种鼠标连点器工具，但大多数要么功能复杂、体积庞大，要么缺乏 macOS 平台的原生支持
- 用户对轻量化、高性能、操作简单的连点工具需求强烈
- macOS 平台对应用性能和用户体验要求较高

## Functional Requirements
- **FR-1**: 支持多种连点运行模式，包括固定单点连点和多点顺序循环连点
- **FR-2**: 可自定义调节连点时间间隔，支持毫秒级精准设置，允许区间自由输入
- **FR-3**: 支持自定义连点位置，可手动录入屏幕坐标和鼠标拾取实时点位
- **FR-4**: 强化多点循环功能，支持添加多个自定义点位，严格按照顺序循环点击，可单独管理每个点位
- **FR-5**: 配备开始、暂停、停止基础控制功能，操作逻辑简洁直观

## Non-Functional Requirements
- **NFR-1**: 应用体积严格小于 200MB
- **NFR-2**: 软件冷启动耗时小于 0.5 秒
- **NFR-3**: 无冗余后台服务、无多余缓存文件、无需额外依赖
- **NFR-4**: 原生适配 macOS Intel 与 Apple Silicon 全芯片机型
- **NFR-5**: 运行流畅无卡顿

## Constraints
- **Technical**: 仅支持 macOS 平台，需要适配不同芯片架构
- **Performance**: 严格的性能和体积限制
- **Dependencies**: 应使用最少的第三方依赖，优先选择系统内置库

## Assumptions
- 用户具备基本的 macOS 操作知识
- 应用将在 macOS 10.15 及以上版本运行
- 不需要管理员权限即可运行

## Acceptance Criteria

### AC-1: 连点模式切换功能
- **Given**: 应用已启动
- **When**: 用户在界面上选择不同的连点模式
- **Then**: 应用应正确切换到所选模式，并更新相应的界面元素
- **Verification**: `programmatic`

### AC-2: 时间间隔设置功能
- **Given**: 应用已启动
- **When**: 用户输入或调整连点时间间隔
- **Then**: 应用应接受有效输入并在连点时按设定的间隔执行
- **Verification**: `programmatic`

### AC-3: 连点位置设置功能
- **Given**: 应用已启动
- **When**: 用户手动输入坐标或使用鼠标拾取功能
- **Then**: 应用应正确记录并在连点时使用这些位置
- **Verification**: `programmatic`

### AC-4: 多点循环管理功能
- **Given**: 应用已启动并切换到多点循环模式
- **When**: 用户添加、删除、编辑或清空点位
- **Then**: 应用应正确管理点位列表，并在连点时按顺序循环执行
- **Verification**: `programmatic`

### AC-5: 控制功能
- **Given**: 应用已启动
- **When**: 用户点击开始、暂停或停止按钮
- **Then**: 应用应执行相应的操作，开始或停止连点，或在暂停后恢复
- **Verification**: `programmatic`

### AC-6: 性能要求
- **Given**: 应用已安装
- **When**: 测量应用体积、启动时间和运行流畅度
- **Then**: 应用体积应小于 200MB，冷启动时间小于 0.5 秒，运行无卡顿
- **Verification**: `programmatic`

### AC-7: 平台适配
- **Given**: 在不同芯片架构的 macOS 设备上
- **When**: 安装并运行应用
- **Then**: 应用应在 Intel 和 Apple Silicon 芯片上正常运行
- **Verification**: `human-judgment`

### AC-8: 应用打包
- **Given**: 开发完成
- **When**: 打包应用
- **Then**: 应生成包含自定义图标、完整 `.app` 程序和标准 DMG 安装镜像文件
- **Verification**: `human-judgment`

## Open Questions
- [ ] 具体使用哪种 macOS 开发框架和编程语言？
- [ ] 如何实现鼠标拾取功能的技术方案？
- [ ] 如何优化应用性能，确保冷启动时间小于 0.5 秒？
- [ ] 如何设计应用图标？