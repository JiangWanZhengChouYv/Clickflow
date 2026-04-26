# macOS 鼠标连点器 - Product Requirement Document

## Overview
- **Summary**: 开发一款 macOS 平台的轻量化图形界面鼠标连点应用，支持固定单点连续点击和多点顺序循环连点两种核心模式，配备完整的操作控制功能和辅助功能。
- **Purpose**: 为用户提供一款简单易用、性能优秀的鼠标连点工具，无需学习成本即可快速上手使用，提升工作效率。
- **Target Users**: 需要频繁重复点击鼠标操作的 macOS 用户，包括游戏玩家、办公人员、测试人员等。

## Goals
- 实现固定单点连续点击和多点顺序循环连点两种核心功能
- 提供直观的可视化操作界面，支持屏幕坐标拾取、手动输入坐标
- 配备毫秒级时间设置、点击次数/无限循环控制
- 支持左键/右键选择，全局快捷键启停
- 打包成标准的 macOS .app 文件和 DMG 安装包
- 确保应用轻量、快速启动、运行稳定

## Non-Goals (Out of Scope)
- 不支持除鼠标点击外的其他自动化操作（如键盘操作）
- 不提供宏录制功能
- 不支持超过 3 个点位的配置
- 不开发 Windows/Linux 版本

## Background & Context
- macOS 平台原生 GUI 应用开发，禁止使用 Swift 语言
- 需要保证原生流畅体验，无终端界面
- 技术栈选择需适配 macOS 全架构（Intel/Apple Silicon）

## Functional Requirements
- **FR-1**: 支持固定单点连续点击模式
- **FR-2**: 支持多点顺序循环连点模式（最多 3 个点位）
- **FR-3**: 支持屏幕坐标拾取功能
- **FR-4**: 支持手动输入坐标、编辑/删除/清空点位
- **FR-5**: 支持毫秒级连点间隔设置
- **FR-6**: 支持设置点击次数或无限循环模式
- **FR-7**: 配备开始、暂停、停止功能按钮
- **FR-8**: 支持鼠标左键/右键选择
- **FR-9**: 支持全局快捷键启停连点

## Non-Functional Requirements
- **NFR-1**: .app 大小 < 200MB
- **NFR-2**: 冷启动速度 < 0.5 秒
- **NFR-3**: 适配 macOS 全架构（Intel/Apple Silicon）
- **NFR-4**: 运行稳定无卡顿
- **NFR-5**: 无冗余依赖

## Constraints
- **Technical**: 禁止使用 Swift 语言，需选择合适的非 Swift 技术栈（如 Objective-C、Python + PyObjC、Electron 等）
- **Business**: 无特定预算/ timeline 约束
- **Dependencies**: 需依赖 macOS 系统 API 实现鼠标控制、全局快捷键等功能

## Assumptions
- 用户具有基本的 macOS 应用使用经验
- 系统允许应用获取屏幕坐标和控制鼠标
- 全局快捷键功能不会与系统或其他应用冲突

## Acceptance Criteria

### AC-1: 固定单点连续点击模式
- **Given**: 应用已启动，用户选择固定单点模式
- **When**: 用户设置坐标、间隔时间，点击开始按钮
- **Then**: 鼠标在指定位置以指定间隔连续点击
- **Verification**: `programmatic`

### AC-2: 多点顺序循环连点模式
- **Given**: 应用已启动，用户选择多点循环模式并配置了 3 个点位
- **When**: 用户点击开始按钮
- **Then**: 鼠标按照 1→2→3→1→2→3 的顺序无限循环点击
- **Verification**: `programmatic`

### AC-3: 屏幕坐标拾取
- **Given**: 应用已启动，用户点击拾取坐标按钮
- **When**: 用户在屏幕上点击
- **Then**: 应用获取并显示该位置的屏幕坐标
- **Verification**: `programmatic`

### AC-4: 点位管理
- **Given**: 应用已启动
- **When**: 用户添加、编辑、删除或清空点位
- **Then**: 界面实时更新显示已添加的点位列表
- **Verification**: `programmatic`

### AC-5: 时间设置
- **Given**: 应用已启动
- **When**: 用户输入毫秒级间隔时间
- **Then**: 连点器按照设置的间隔执行点击
- **Verification**: `programmatic`

### AC-6: 点击次数控制
- **Given**: 应用已启动
- **When**: 用户设置点击次数或选择无限循环
- **Then**: 连点器执行相应次数后停止或持续运行
- **Verification**: `programmatic`

### AC-7: 操作控制
- **Given**: 连点器正在运行
- **When**: 用户点击暂停或停止按钮
- **Then**: 连点器暂停或完全停止
- **Verification**: `programmatic`

### AC-8: 左右键选择
- **Given**: 应用已启动
- **When**: 用户选择左键或右键
- **Then**: 连点器使用选择的鼠标键执行点击
- **Verification**: `programmatic`

### AC-9: 全局快捷键
- **Given**: 应用已启动
- **When**: 用户按下全局快捷键
- **Then**: 连点器开始或停止运行
- **Verification**: `programmatic`

### AC-10: 应用性能
- **Given**: 应用已构建完成
- **When**: 启动应用并运行
- **Then**: .app 大小 < 200MB，冷启动 < 0.5 秒，运行稳定
- **Verification**: `programmatic`

### AC-11: 界面体验
- **Given**: 用户首次使用应用
- **When**: 浏览和操作界面
- **Then**: 界面简洁直观，操作无学习成本
- **Verification**: `human-judgment`

## Open Questions
- [ ] 选择哪种非 Swift 技术栈？（推荐使用 Python + PyObjC + rumps 或 Electron）
