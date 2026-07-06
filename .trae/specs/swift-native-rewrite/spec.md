# Clickflow Swift 原生重写 - Product Requirement Document

## Overview
- **Summary**: 将现有的 Electron + Python 鼠标连点器应用全面重写为 Swift 原生 macOS 应用，使用 SwiftUI 构建现代化 Mac 风格界面，通过 Core Graphics 实现底层鼠标控制，提供更流畅的用户体验和更好的系统集成。
- **Purpose**: 解决 Electron 应用体积大、启动慢、依赖 Python 外部脚本、权限管理复杂等问题，打造一款真正的 macOS 原生应用。
- **Target Users**: 需要自动鼠标点击功能的 macOS 用户，包括游戏玩家、测试人员、重复操作工作者等。

## Goals
- 使用 Swift + SwiftUI 完全重写应用，移除所有 Electron 和 Python 依赖
- 实现与原版本相同的核心功能：固定单点、多点循环、坐标拾取、时间设置、鼠标按键选择
- 提供菜单栏图标和全局快捷键支持，提升使用便捷性
- 配置 GitHub Actions 自动构建和打包 DMG
- 清理所有旧文件和旧 Actions，保持仓库整洁

## Non-Goals (Out of Scope)
- 不支持 Windows / Linux 平台
- 不实现脚本录制/回放功能
- 不实现多语言支持（仅简体中文）
- 不实现云同步功能

## Background & Context
- 当前应用基于 Electron + Python 实现，存在依赖复杂、权限问题多、应用体积大等问题
- 用户明确要求使用 Swift 原生重写，以获得更好的性能和系统集成
- 最低支持 macOS 13.0
- 使用 Swift Package Manager 管理依赖

## Functional Requirements
- **FR-1**: 支持固定单点点击模式，可设置点击坐标、间隔时间、点击次数
- **FR-2**: 支持多点循环点击模式，可添加/编辑/删除多个点位，循环点击
- **FR-3**: 支持坐标拾取功能，一键获取当前鼠标位置
- **FR-4**: 支持左键/右键点击选择
- **FR-5**: 支持无限循环模式和指定次数模式
- **FR-6**: 支持开始/暂停/停止控制
- **FR-7**: 支持菜单栏图标，快速访问常用功能
- **FR-8**: 支持全局快捷键（Cmd + Shift + S）开始/停止
- **FR-9**: 显示运行状态（就绪/运行中/暂停）
- **FR-10**: 应用打包为 DMG 格式，支持正常安装运行

## Non-Functional Requirements
- **NFR-1**: 应用启动时间 < 1 秒
- **NFR-2**: 点击间隔精度 ±5ms
- **NFR-3**: 应用体积 < 10MB
- **NFR-4**: 界面遵循 macOS Human Interface Guidelines
- **NFR-5**: 内存占用 < 50MB（空闲状态）

## Constraints
- **Technical**: Swift 5.9+, SwiftUI, macOS 13.0+, Core Graphics
- **Business**: 保持与原版本功能一致的用户体验
- **Dependencies**: 无第三方依赖，全部使用系统框架

## Assumptions
- 用户已授予应用辅助功能权限（鼠标控制需要）
- 用户使用 macOS 13.0 及以上版本
- GitHub Actions 有可用的 macOS 构建环境

## Acceptance Criteria

### AC-1: 应用可以正常编译运行
- **Given**: 项目代码完整
- **When**: 执行 swift build 命令
- **Then**: 编译成功，生成可执行文件
- **Verification**: `programmatic`
- **Notes**: 无错误、无警告

### AC-2: 主界面完整呈现
- **Given**: 应用已启动
- **When**: 用户查看主窗口
- **Then**: 显示模式选择、点位配置、时间设置、鼠标按键、操作控制、运行状态等所有功能区域
- **Verification**: `human-judgment`
- **Notes**: 界面风格符合 macOS 设计规范

### AC-3: 固定单点点击功能正常
- **Given**: 用户设置了坐标、间隔、次数，选择单点模式
- **When**: 用户点击开始按钮
- **Then**: 应用在指定坐标按指定间隔进行点击，达到次数后自动停止
- **Verification**: `programmatic`
- **Notes**: 支持左键和右键

### AC-4: 多点循环点击功能正常
- **Given**: 用户添加了多个点位，选择多点模式
- **When**: 用户点击开始按钮
- **Then**: 应用按顺序循环点击各个点位
- **Verification**: `programmatic`
- **Notes**: 点位数量可配置，支持最多3个点位

### AC-5: 坐标拾取功能正常
- **Given**: 用户移动鼠标到目标位置
- **When**: 用户点击"拾取坐标"按钮
- **Then**: 输入框自动填充当前鼠标坐标
- **Verification**: `programmatic`
- **Notes**: 坐标精度到像素级别

### AC-6: 全局快捷键功能正常
- **Given**: 应用在后台运行
- **When**: 用户按下 Cmd + Shift + S
- **Then**: 应用开始或停止点击
- **Verification**: `human-judgment`
- **Notes**: 应用未获得焦点时也能响应

### AC-7: 菜单栏图标可用
- **Given**: 应用正在运行
- **When**: 用户点击菜单栏图标
- **Then**: 显示菜单，可进行开始/停止、显示主窗口、退出等操作
- **Verification**: `human-judgment`
- **Notes**: 图标清晰可辨识

### AC-8: GitHub Actions 构建成功
- **Given**: 代码推送到 GitHub
- **When**: GitHub Actions 自动触发构建
- **Then**: 构建成功，生成 DMG 安装包
- **Verification**: `programmatic`
- **Notes**: 使用最新的 Xcode 和 macOS 版本构建

### AC-9: 旧文件已清理
- **Given**: 重写完成
- **When**: 查看仓库根目录
- **Then**: 所有 Electron、Python 相关文件已移除，仅保留 Swift 项目文件
- **Verification**: `programmatic`
- **Notes**: .github/workflows 也已更新为 Swift 构建

### AC-10: 应用可正常打包运行
- **Given**: 构建完成
- **When**: 用户双击安装并运行应用
- **Then**: 应用正常启动，所有功能可用，无"已损坏"提示
- **Verification**: `human-judgment`
- **Notes**: 不需要特殊的绕过公证设置

## Open Questions
- [ ] 是否需要支持右键菜单中的点位管理？
- [ ] 是否需要点击音效反馈？
- [ ] 是否需要支持导入/导出点位配置？
