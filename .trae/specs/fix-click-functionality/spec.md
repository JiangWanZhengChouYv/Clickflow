# 修复连点功能 - Product Requirement Document

## Overview
- **Summary**: 修复 Clickflow 应用无法执行真实鼠标点击的问题，使用更可靠的方案
- **Purpose**: 解决当前 Python Quartz API 方案不够可靠的问题，确保连点功能正常工作
- **Target Users**: Clickflow 应用用户

## Goals
- 实现可靠的鼠标点击功能
- 支持左键/右键点击
- 支持鼠标位置移动
- 确保在 macOS 上正常工作

## Non-Goals (Out of Scope)
- 跨平台支持（目前只针对 macOS）
- 复杂的鼠标手势
- 多显示器支持（虽然应该可以工作）

## Background & Context
- 当前方案每次点击都 spawn 新的 Python 进程，效率低且不稳定
- Quartz API 的使用可能不够正确
- 需要一个更简单、更可靠的方案

## Functional Requirements
- **FR-1**: 实现鼠标左键点击
- **FR-2**: 实现鼠标右键点击
- **FR-3**: 实现鼠标位置移动
- **FR-4**: 支持连续点击（连点）

## Non-Functional Requirements
- **NFR-1**: 点击响应时间 < 50ms
- **NFR-2**: 支持至少 100ms 间隔的连续点击
- **NFR-3**: 方案可靠，不会随机失败

## Constraints
- **Technical**: 必须在 Electron 环境下工作，只能使用 macOS 可用的方案
- **Business**: 保持现有架构不变
- **Dependencies**: 不能添加复杂的外部依赖

## Assumptions
- macOS 权限问题可以解决（辅助功能权限）
- 可以使用 node.js 的 native 模块或简单的方案

## Acceptance Criteria

### AC-1: 左键点击正常工作
- **Given**: 用户配置好点击参数
- **When**: 用户点击开始
- **Then**: 应用能在指定位置执行左键点击
- **Verification**: `human-judgment`

### AC-2: 右键点击正常工作
- **Given**: 用户选择右键模式
- **When**: 点击器运行
- **Then**: 应用能执行右键点击
- **Verification**: `human-judgment`

### AC-3: 多点循环正常工作
- **Given**: 用户添加了多个点
- **When**: 点击器运行
- **Then**: 应用能在多个点之间循环点击
- **Verification**: `human-judgment`

### AC-4: 无限循环模式正常工作
- **Given**: 用户启用无限循环
- **When**: 点击器运行
- **Then**: 应用能持续点击直到停止
- **Verification**: `human-judgment`

## Open Questions
- [ ] 是否需要使用专门的 npm 包？
- [ ] 是否需要先请求辅助功能权限？
