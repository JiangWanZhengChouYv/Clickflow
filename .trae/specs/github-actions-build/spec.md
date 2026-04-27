# Clickflow - GitHub Workflows打包 - 产品需求文档

## 概述
- **摘要**：修改现有的GitHub Workflows配置文件(build.yml)，使其能够正确打包基于Electron的Clickflow应用，生成DMG安装包。
- **目的**：确保应用能够通过CI/CD流程自动构建和打包，提高开发效率和发布质量。
- **目标用户**：开发团队和维护者，需要通过GitHub Actions自动构建和发布应用。

## 目标
- 修改build.yml文件，使其适用于基于Electron的Clickflow应用
- 确保GitHub Workflows能够正确安装依赖、构建应用和生成DMG包
- 配置正确的缓存策略，提高构建速度
- 确保构建产物能够正确上传为GitHub Artifact

## 非目标（范围外）
- 不修改应用的核心功能
- 不更改应用的用户界面
- 不修改应用的签名和证书配置

## 背景与上下文
- 当前的build.yml文件是为基于PyQt5的应用设计的
- 现在应用已经重构为基于Electron的实现
- 需要更新GitHub Workflows配置以适应新的技术栈

## 功能需求
- **FR-1**：修改build.yml文件，使用Node.js环境替代Python环境
- **FR-2**：配置正确的依赖安装步骤，包括npm包安装
- **FR-3**：配置Electron应用的构建步骤
- **FR-4**：配置DMG包的生成步骤
- **FR-5**：确保构建产物能够正确上传为GitHub Artifact

## 非功能需求
- **NFR-1**：构建时间不超过10分钟
- **NFR-2**：构建过程稳定可靠，成功率高
- **NFR-3**：构建产物命名规范，版本号清晰

## 约束
- **技术**：使用GitHub Actions，Electron框架
- **平台**：macOS-latest runner
- **依赖**：Node.js, npm, electron-builder

## 假设
- GitHub Actions环境中已安装必要的构建工具
- 应用代码已经正确配置，能够通过electron-builder构建

## 验收标准

### AC-1：GitHub Workflows配置正确
- **给定**：修改后的build.yml文件
- **当**：推送代码到GitHub时
- **则**：GitHub Actions能够自动启动构建流程
- **验证**：`programmatic`

### AC-2：依赖安装成功
- **给定**：GitHub Actions构建环境
- **当**：执行依赖安装步骤时
- **则**：所有必要的npm包能够成功安装
- **验证**：`programmatic`

### AC-3：应用构建成功
- **给定**：依赖安装完成
- **当**：执行构建步骤时
- **则**：Electron应用能够成功构建
- **验证**：`programmatic`

### AC-4：DMG包生成成功
- **给定**：应用构建完成
- **当**：执行DMG生成步骤时
- **则**：能够成功生成DMG安装包
- **验证**：`programmatic`

### AC-5：构建产物上传成功
- **给定**：DMG包生成完成
- **当**：执行上传步骤时
- **则**：DMG包能够成功上传为GitHub Artifact
- **验证**：`programmatic`

## 开放问题
- [ ] 具体的Electron版本和构建配置
- [ ] DMG包的具体命名规则
- [ ] 构建过程中的缓存策略