// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

@main
struct WorkspaceApp {
    static func main() {
        print("鼠标点击模拟功能演示")
        print("===========================")
        
        // 运行点位管理测试
        testPositionManagement()
        
        // 运行点击模式测试
        testClickModes()
        
        print("演示完成")
    }
}

// 测试点位管理功能
func testPositionManagement() {
    print("\n开始测试点位管理功能...")
    
    let manager = ModeManager()
    let positionManager = manager.getPositionManager()
    
    // 演示点位管理菜单
    showPositionManagementMenu(positionManager: positionManager)
}

// 显示点位管理菜单
func showPositionManagementMenu(positionManager: PositionManager) {
    var isRunning = true
    
    while isRunning {
        print("\n点位管理菜单")
        print("===========================")
        print("1. 添加自定义点位")
        print("2. 添加当前鼠标位置")
        print("3. 查看点位列表")
        print("4. 编辑点位")
        print("5. 删除点位")
        print("6. 清空所有点位")
        print("7. 退出点位管理")
        print("===========================")
        
        print("请选择操作: ")
        if let input = readLine(), let choice = Int(input) {
            switch choice {
            case 1:
                addCustomPosition(positionManager: positionManager)
            case 2:
                addCurrentMousePosition(positionManager: positionManager)
            case 3:
                showPositionList(positionManager: positionManager)
            case 4:
                editPosition(positionManager: positionManager)
            case 5:
                deletePosition(positionManager: positionManager)
            case 6:
                clearAllPositions(positionManager: positionManager)
            case 7:
                isRunning = false
                print("退出点位管理")
            default:
                print("无效的选择，请重新输入")
            }
        } else {
            print("无效的输入，请重新输入")
        }
    }
}

// 添加自定义点位
func addCustomPosition(positionManager: PositionManager) {
    print("\n添加自定义点位")
    print("请输入X坐标: ")
    if let xInput = readLine(), let x = Int(xInput) {
        print("请输入Y坐标: ")
        if let yInput = readLine(), let y = Int(yInput) {
            positionManager.addPosition(x: x, y: y)
            print("成功添加点位: (x, y)")
        } else {
            print("无效的Y坐标")
        }
    } else {
        print("无效的X坐标")
    }
}

// 添加当前鼠标位置
func addCurrentMousePosition(positionManager: PositionManager) {
    print("\n添加当前鼠标位置")
    if let position = positionManager.addCurrentMousePosition() {
        print("成功添加当前鼠标位置: (position.x, position.y)")
    } else {
        print("获取当前鼠标位置失败")
    }
}

// 查看点位列表
func showPositionList(positionManager: PositionManager) {
    print("\n点位列表")
    print("===========================")
    
    let positions = positionManager.getAllPositions()
    
    if positions.isEmpty {
        print("当前没有点位")
    } else {
        for (index, position) in positions.enumerated() {
            print("index + 1). X: position.x), Y: position.y)")
        }
    }
    
    print("===========================")
    print("总点位数量: positions.count)")
}

// 编辑点位
func editPosition(positionManager: PositionManager) {
    print("\n编辑点位")
    
    let positions = positionManager.getAllPositions()
    if positions.isEmpty {
        print("当前没有点位可编辑")
        return
    }
    
    showPositionList(positionManager: positionManager)
    
    print("请输入要编辑的点位序号: ")
    if let input = readLine(), let index = Int(input), index > 0, index <= positions.count {
        let positionIndex = index - 1
        
        print("当前点位: X: positions[positionIndex].x), Y: positions[positionIndex].y)")
        print("请输入新的X坐标: ")
        if let xInput = readLine(), let x = Int(xInput) {
            print("请输入新的Y坐标: ")
            if let yInput = readLine(), let y = Int(yInput) {
                positionManager.updatePosition(at: positionIndex, x: x, y: y)
                print("成功更新点位: (x, y)")
            } else {
                print("无效的Y坐标")
            }
        } else {
            print("无效的X坐标")
        }
    } else {
        print("无效的点位序号")
    }
}

// 删除点位
func deletePosition(positionManager: PositionManager) {
    print("\n删除点位")
    
    let positions = positionManager.getAllPositions()
    if positions.isEmpty {
        print("当前没有点位可删除")
        return
    }
    
    showPositionList(positionManager: positionManager)
    
    print("请输入要删除的点位序号: ")
    if let input = readLine(), let index = Int(input), index > 0, index <= positions.count {
        let positionIndex = index - 1
        let deletedPosition = positions[positionIndex]
        positionManager.removePosition(at: positionIndex)
        print("成功删除点位: deletedPosition.x), deletedPosition.y)")
    } else {
        print("无效的点位序号")
    }
}

// 清空所有点位
func clearAllPositions(positionManager: PositionManager) {
    print("\n清空所有点位")
    print("确定要清空所有点位吗？(y/n): ")
    if let input = readLine(), input.lowercased() == "y" {
        positionManager.clearPositions()
        print("成功清空所有点位")
    } else {
        print("取消清空操作")
    }
}

// 测试点击模式功能
func testClickModes() {
    print("\n开始测试点击模式...")
    
    let manager = ModeManager()
    let positionManager = manager.getPositionManager()
    
    // 检查是否有点位
    let positions = positionManager.getAllPositions()
    if !positions.isEmpty {
        print("\n使用已保存的点位进行测试")
        print("点位数量: positions.count)")
        
        // 测试多点顺序循环连点模式
        print("\n测试多点顺序循环连点模式:")
        print("在已保存的点位处各点击 2 次，间隔 300ms")
        
        manager.setMultiPointMode(points: positions, count: 2, interval: 300)
        manager.start()
        
        // 等待测试完成
        Thread.sleep(forTimeInterval: 3.0) // 3秒
    } else {
        // 测试固定单点连点模式
        print("\n测试固定单点连点模式:")
        print("在坐标 (100, 100) 处点击 5 次，间隔 500ms")
        
        manager.setSinglePointMode(x: 100, y: 100, count: 5, interval: 500)
        manager.start()
        
        // 等待测试完成
        Thread.sleep(forTimeInterval: 3.0) // 3秒
        
        // 测试多点顺序循环连点模式
        print("\n测试多点顺序循环连点模式:")
        print("在坐标 (200, 200), (300, 300), (400, 400) 处各点击 2 次，间隔 300ms")
        
        let points = [(x: 200, y: 200), (x: 300, y: 300), (x: 400, y: 400)]
        manager.setMultiPointMode(points: points, count: 2, interval: 300)
        manager.start()
        
        // 等待测试完成
        Thread.sleep(forTimeInterval: 3.0) // 3秒
    }
    
    print("\n测试完成!")
}
