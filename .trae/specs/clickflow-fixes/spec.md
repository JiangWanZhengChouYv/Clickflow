# Clickflow 功能修复 - Product Requirement Document

## Overview
- **Summary**: 修复Clickflow连点器应用的关键功能问题，包括连点功能失效、模式限制、UI交互问题以及应用图标问题
- **Purpose**: 解决用户反馈的所有功能问题，确保应用能够正常工作并提供良好的用户体验
- **Target Users**: Clickflow应用的最终用户

## Goals
- 修复连点器连点功能失效的问题
- 确保单点模式下只允许单个点位
- 实现"无限循环"模式下禁用点击次数输入框
- 配置自定义应用图标

## Non-Goals (Out of Scope)
- 添加新功能
- 重构整个应用架构
- 修改应用的整体UI设计风格

## Background & Context
- 当前应用使用Electron框架，之前从PyQt5迁移过来
- 连点功能目前只是打印日志，没有实际执行鼠标点击
- UI交互逻辑存在多个问题
- 应用图标配置存在但缺少相应的图标文件

## Functional Requirements
- **FR-1**: 实现真实的鼠标点击功能
- **FR-2**: 单点模式下只允许添加单个点位
- **FR-3**: 无限循环模式下禁用点击次数输入框
- **FR-4**: 配置自定义应用图标

## Non-Functional Requirements
- **NFR-1**: 鼠标点击功能响应迅速，间隔时间准确
- **NFR-2**: UI状态更新及时反映用户操作

## Constraints
- **Technical**: 必须在Electron框架内实现，使用合适的Node.js库进行鼠标控制
- **Business**: 保持现有Electron构建流程不变
- **Dependencies**: 需要添加robotjs或类似的鼠标控制库

## Assumptions
- robotjs库可以正常工作在macOS环境下
- 可以使用现有的create_icon.py工具生成图标文件
- GitHub Actions构建流程可以正常处理新添加的依赖

## Acceptance Criteria

### AC-1: 连点功能正常工作
- **Given**: 用户配置好点击参数并点击开始
- **When**: 点击器启动
- **Then**: 应用应该实际执行鼠标点击操作，而不是只打印日志
- **Verification**: `human-judgment`

### AC-2: 单点模式下只允许单个点位
- **Given**: 用户选择"固定单点"模式
- **When**: 用户尝试添加多个点位
- **Then**: 应该只允许添加1个点位，超过时提示或禁用添加
- **Verification**: `human-judgment`

### AC-3: 无限循环模式下禁用点击次数输入框
- **Given**: 用户勾选"无限循环"复选框
- **When**: 复选框状态改变
- **Then**: 点击次数输入框应该变为灰色不可编辑状态
- **Verification**: `human-judgment`

### AC-4: 使用自定义应用图标
- **Given**: 应用构建完成
- **When**: 用户查看应用程序
- **Then**: 应该显示自定义的应用图标，而不是Electron默认图标
- **Verification**: `human-judgment`

## Open Questions
- [ ] robotjs在最新macOS版本上是否需要额外的权限配置？
