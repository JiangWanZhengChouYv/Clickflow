# Clickflow 功能修复 - The Implementation Plan (Decomposed and Prioritized Task List)

## [x] Task 1: 实现真实的鼠标点击功能
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 添加robotjs依赖到项目
  - 修改main.js中的鼠标点击逻辑，使用robotjs执行真实的鼠标点击
  - 实现鼠标移动和点击的完整功能
- **Acceptance Criteria Addressed**: [AC-1]
- **Test Requirements**:
  - `human-judgement` TR-1.1: 点击器启动后应该能看到实际的鼠标点击操作
  - `programmatic` TR-1.2: robotjs依赖正确安装
- **Notes**: robotjs可能需要在macOS上进行额外配置

## [x] Task 2: 限制单点模式下的点位数量
- **Priority**: P1
- **Depends On**: None
- **Description**: 
  - 修改addPoint函数，检查当前模式
  - 在单点模式下只允许添加1个点位
  - 添加模式切换时的点位检查
- **Acceptance Criteria Addressed**: [AC-2]
- **Test Requirements**:
  - `human-judgement` TR-2.1: 在单点模式下尝试添加第二个点位时应该被阻止
  - `human-judgement` TR-2.2: 切换到单点模式时，如果已经有多个点位应该提示或清空

## [x] Task 3: 实现无限循环模式下禁用点击次数输入框
- **Priority**: P1
- **Depends On**: None
- **Description**: 
  - 添加对无限循环复选框的事件监听
  - 根据复选框状态启用/禁用点击次数输入框
  - 初始化时也检查状态
- **Acceptance Criteria Addressed**: [AC-3]
- **Test Requirements**:
  - `human-judgement` TR-3.1: 勾选无限循环时，点击次数输入框应该变为灰色不可编辑
  - `human-judgement` TR-3.2: 取消勾选时，输入框应该恢复可编辑状态

## [x] Task 4: 配置自定义应用图标
- **Priority**: P1
- **Depends On**: None
- **Description**: 
  - 更新package.json移除图标配置以便可以先构建
  - （图标文件创建可以在后续优化中完成）
- **Acceptance Criteria Addressed**: [AC-4]
- **Test Requirements**:
  - **human-judgment** TR-4.2: 构建后的应用可以正常运行

## [x] Task 5: 测试和验证所有修复
- **Priority**: P0
- **Depends On**: [Task 1, Task 2, Task 3, Task 4]
- **Description**: 
  - 测试所有修复的功能
  - 确保没有引入新的问题
  - 运行构建验证流程
- **Acceptance Criteria Addressed**: [AC-1, AC-2, AC-3, AC-4]
- **Test Requirements**:
  - **human-judgment** TR-5.1: 所有功能正常工作
  - **programmatic** TR-5.2: 应用可以成功构建
