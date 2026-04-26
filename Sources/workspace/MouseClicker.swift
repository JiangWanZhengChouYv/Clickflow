import Foundation

// 鼠标点击模拟核心功能模块
class MouseClicker: @unchecked Sendable {
    
    // 点击类型枚举
    enum ClickType {
        case left
        case right
        case middle
    }
    
    // 执行鼠标点击
    func click(at x: Int, y: Int, type: ClickType = .left) {
        // 使用X11库执行鼠标点击
        guard let display = XOpenDisplay(nil) else {
            print("无法打开显示")
            return
        }
        
        defer {
            XCloseDisplay(display)
        }
        
        let rootWindow = XDefaultRootWindow(display)
        
        // 移动鼠标到指定位置
        XWarpPointer(display, None, rootWindow, 0, 0, 0, 0, Int32(x), Int32(y))
        
        // 模拟鼠标按下和释放
        let button = buttonCode(for: type)
        
        // 注意：display已经在guard中检查过不为nil，所以这里可以安全使用
        // 按下鼠标按钮
        simulateMouseEvent(display: display, window: rootWindow, button: button, isPress: true)
        
        // 释放鼠标按钮
        simulateMouseEvent(display: display, window: rootWindow, button: button, isPress: false)
        
        // 刷新显示
        XFlush(display)
    }
    
    // 模拟鼠标事件
    private func simulateMouseEvent(display: OpaquePointer, window: UInt32, button: UInt32, isPress: Bool) {
        // 创建鼠标事件
        var event = XButtonEvent(
            type: isPress ? ButtonPress : ButtonRelease,
            serial: 0,
            send_event: false,
            display: display,
            window: window,
            root: XDefaultRootWindow(display),
            subwindow: 0,
            time: 0,
            x: 0,
            y: 0,
            x_root: 0,
            y_root: 0,
            state: 0,
            button: button,
            same_screen: true
        )
        
        // 发送事件
        withUnsafeMutablePointer(to: &event) { eventPtr in
            XSendEvent(display, window, false, ButtonPressMask | ButtonReleaseMask, eventPtr)
        }
    }
    
    // 获取鼠标按钮代码
    private func buttonCode(for type: ClickType) -> UInt32 {
        switch type {
        case .left:
            return 1
        case .right:
            return 3
        case .middle:
            return 2
        }
    }
    
    // 延迟执行
    func delay(_ milliseconds: Int) {
        usleep(useconds_t(milliseconds * 1000))
    }
    
    // 执行连续点击
    func clickMultipleTimes(at x: Int, y: Int, count: Int, interval: Int, type: ClickType = .left) {
        for i in 0..<count {
            click(at: x, y: y, type: type)
            if i < count - 1 {
                delay(interval)
            }
        }
    }
    
    // 获取当前鼠标位置
    func getCurrentMousePosition() -> (x: Int, y: Int)? {
        guard let display = XOpenDisplay(nil) else {
            print("无法打开显示")
            return nil
        }
        
        defer {
            XCloseDisplay(display)
        }
        
        let rootWindow = XDefaultRootWindow(display)
        var root: UInt32 = 0
        var child: UInt32 = 0
        var rootX: Int32 = 0
        var rootY: Int32 = 0
        var winX: Int32 = 0
        var winY: Int32 = 0
        var mask: UInt32 = 0
        
        if XQueryPointer(display, rootWindow, &root, &child, &rootX, &rootY, &winX, &winY, &mask) {
            return (x: Int(rootX), y: Int(rootY))
        }
        
        return nil
    }
}

// 点击模式协议
protocol ClickMode {
    var clicker: MouseClicker { get }
    var interval: Int { get set }
    var clickType: MouseClicker.ClickType { get set }
    
    func start()
    func stop()
}

// 固定单点连点模式
class SinglePointMode: ClickMode, @unchecked Sendable {
    let clicker: MouseClicker
    var interval: Int
    var clickType: MouseClicker.ClickType
    
    private let x: Int
    private let y: Int
    private let count: Int
    private var isRunning: Bool = false
    
    init(clicker: MouseClicker, x: Int, y: Int, count: Int, interval: Int, clickType: MouseClicker.ClickType = .left) {
        self.clicker = clicker
        self.x = x
        self.y = y
        self.count = count
        self.interval = interval
        self.clickType = clickType
    }
    
    func start() {
        isRunning = true
        
        let clicker = self.clicker
        let x = self.x
        let y = self.y
        let count = self.count
        let interval = self.interval
        let clickType = self.clickType
        
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0..<count {
                if !self.isRunning {
                    break
                }
                
                clicker.click(at: x, y: y, type: clickType)
                
                if i < count - 1 && self.isRunning {
                    clicker.delay(interval)
                }
            }
        }
    }
    
    func stop() {
        isRunning = false
    }
}

// 多点顺序循环连点模式
class MultiPointMode: ClickMode, @unchecked Sendable {
    let clicker: MouseClicker
    var interval: Int
    var clickType: MouseClicker.ClickType
    
    private let points: [(x: Int, y: Int)]
    private let count: Int
    private var isRunning: Bool = false
    
    init(clicker: MouseClicker, points: [(x: Int, y: Int)], count: Int, interval: Int, clickType: MouseClicker.ClickType = .left) {
        self.clicker = clicker
        self.points = points
        self.count = count
        self.interval = interval
        self.clickType = clickType
    }
    
    func start() {
        isRunning = true
        
        let clicker = self.clicker
        let points = self.points
        let count = self.count
        let interval = self.interval
        let clickType = self.clickType
        
        DispatchQueue.global(qos: .userInitiated).async {
            let totalClicks = count * points.count
            
            for i in 0..<totalClicks {
                if !self.isRunning {
                    break
                }
                
                let pointIndex = i % points.count
                let point = points[pointIndex]
                
                clicker.click(at: point.x, y: point.y, type: clickType)
                
                if i < totalClicks - 1 && self.isRunning {
                    clicker.delay(interval)
                }
            }
        }
    }
    
    func stop() {
        isRunning = false
    }
}

// 位置管理类
class PositionManager {
    private var positions: [(x: Int, y: Int)] = []
    private let clicker: MouseClicker
    
    init(clicker: MouseClicker) {
        self.clicker = clicker
    }
    
    // 手动录入坐标
    func addPosition(x: Int, y: Int) {
        positions.append((x: x, y: y))
    }
    
    // 鼠标拾取实时点位
    func addCurrentMousePosition() -> (x: Int, y: Int)? {
        if let position = clicker.getCurrentMousePosition() {
            positions.append(position)
            return position
        }
        return nil
    }
    
    // 获取所有位置
    func getAllPositions() -> [(x: Int, y: Int)] {
        return positions
    }
    
    // 清除所有位置
    func clearPositions() {
        positions.removeAll()
    }
    
    // 删除指定位置
    func removePosition(at index: Int) {
        if index >= 0 && index < positions.count {
            positions.remove(at: index)
        }
    }
    
    // 更新指定位置
    func updatePosition(at index: Int, x: Int, y: Int) {
        if index >= 0 && index < positions.count {
            positions[index] = (x: x, y: y)
        }
    }
}

// 模式管理类
class ModeManager {
    private let clicker: MouseClicker
    private var currentMode: ClickMode?
    private let positionManager: PositionManager
    
    init() {
        self.clicker = MouseClicker()
        self.positionManager = PositionManager(clicker: clicker)
    }
    
    // 获取位置管理器
    func getPositionManager() -> PositionManager {
        return positionManager
    }
    
    // 设置为固定单点连点模式
    func setSinglePointMode(x: Int, y: Int, count: Int, interval: Int, clickType: MouseClicker.ClickType = .left) {
        stopCurrentMode()
        currentMode = SinglePointMode(clicker: clicker, x: x, y: y, count: count, interval: interval, clickType: clickType)
    }
    
    // 设置为多点顺序循环连点模式
    func setMultiPointMode(points: [(x: Int, y: Int)], count: Int, interval: Int, clickType: MouseClicker.ClickType = .left) {
        stopCurrentMode()
        currentMode = MultiPointMode(clicker: clicker, points: points, count: count, interval: interval, clickType: clickType)
    }
    
    // 启动当前模式
    func start() {
        currentMode?.start()
    }
    
    // 停止当前模式
    func stop() {
        currentMode?.stop()
    }
    
    // 停止当前模式（私有方法）
    private func stopCurrentMode() {
        currentMode?.stop()
        currentMode = nil
    }
}

// X11 相关函数声明
@_silgen_name("XOpenDisplay")
func XOpenDisplay(_ display: UnsafePointer<CChar>?) -> OpaquePointer?

@_silgen_name("XCloseDisplay")
func XCloseDisplay(_ display: OpaquePointer?)

@_silgen_name("XDefaultRootWindow")
func XDefaultRootWindow(_ display: OpaquePointer?) -> UInt32

@_silgen_name("XWarpPointer")
func XWarpPointer(_ display: OpaquePointer?, _ src_w: UInt32, _ dest_w: UInt32, _ src_x: Int, _ src_y: Int, _ src_width: UInt, _ src_height: UInt, _ dest_x: Int32, _ dest_y: Int32)

@_silgen_name("XSendEvent")
func XSendEvent(_ display: OpaquePointer?, _ w: UInt32, _ propagate: Bool, _ event_mask: UInt32, _ event_send: UnsafeMutablePointer<XButtonEvent>?)

@_silgen_name("XFlush")
func XFlush(_ display: OpaquePointer?)

@_silgen_name("XQueryPointer")
func XQueryPointer(_ display: OpaquePointer?, _ win: UInt32, _ root_return: UnsafeMutablePointer<UInt32>?, _ child_return: UnsafeMutablePointer<UInt32>?, _ root_x_return: UnsafeMutablePointer<Int32>?, _ root_y_return: UnsafeMutablePointer<Int32>?, _ win_x_return: UnsafeMutablePointer<Int32>?, _ win_y_return: UnsafeMutablePointer<Int32>?, _ mask_return: UnsafeMutablePointer<UInt32>?) -> Bool

// X11 事件类型和掩码
let ButtonPress: CUnsignedLong = 4
let ButtonRelease: CUnsignedLong = 5
let ButtonPressMask: UInt32 = 1 << 2
let ButtonReleaseMask: UInt32 = 1 << 3
let None: UInt32 = 0

// X11 按钮事件结构体
struct XButtonEvent {
    var type: CUnsignedLong
    var serial: UInt32
    var send_event: Bool
    var display: OpaquePointer?
    var window: UInt32
    var root: UInt32
    var subwindow: UInt32
    var time: UInt32
    var x: Int16
    var y: Int16
    var x_root: Int16
    var y_root: Int16
    var state: UInt32
    var button: UInt32
    var same_screen: Bool
}

// 测试位置管理功能
func testPositionManager() {
    print("开始测试位置管理功能...")
    
    // 创建鼠标点击器
    let clicker = MouseClicker()
    
    // 创建位置管理器
    let positionManager = PositionManager(clicker: clicker)
    
    // 测试手动录入坐标
    print("测试手动录入坐标...")
    positionManager.addPosition(x: 100, y: 200)
    positionManager.addPosition(x: 300, y: 400)
    
    // 测试鼠标拾取实时点位
    print("测试鼠标拾取实时点位...")
    if let currentPosition = positionManager.addCurrentMousePosition() {
        print("成功获取当前鼠标位置: (currentPosition.x), currentPosition.y))")
    } else {
        print("获取当前鼠标位置失败")
    }
    
    // 测试获取所有位置
    print("测试获取所有位置...")
    let positions = positionManager.getAllPositions()
    for (index, position) in positions.enumerated() {
        print("位置 index + 1): (position.x), position.y))")
    }
    
    // 测试更新位置
    print("测试更新位置...")
    positionManager.updatePosition(at: 0, x: 500, y: 600)
    let updatedPositions = positionManager.getAllPositions()
    for (index, position) in updatedPositions.enumerated() {
        print("更新后位置 index + 1): (position.x), position.y))")
    }
    
    // 测试删除位置
    print("测试删除位置...")
    positionManager.removePosition(at: 1)
    let deletedPositions = positionManager.getAllPositions()
    for (index, position) in deletedPositions.enumerated() {
        print("删除后位置 index + 1): (position.x), position.y))")
    }
    
    // 测试清除所有位置
    print("测试清除所有位置...")
    positionManager.clearPositions()
    let clearedPositions = positionManager.getAllPositions()
    print("清除后位置数量: clearedPositions.count)")
    
    print("位置管理功能测试完成！")
}

// 测试模式管理器中的位置管理
func testModeManagerWithPosition() {
    print("\n开始测试模式管理器中的位置管理...")
    
    // 创建模式管理器
    let modeManager = ModeManager()
    
    // 获取位置管理器
    let positionManager = modeManager.getPositionManager()
    
    // 测试添加位置
    positionManager.addPosition(x: 100, y: 200)
    positionManager.addPosition(x: 300, y: 400)
    
    // 测试获取所有位置
    let positions = positionManager.getAllPositions()
    print("位置数量: positions.count)")
    for (index, position) in positions.enumerated() {
        print("位置 index + 1): (position.x), position.y))")
    }
    
    // 测试设置为多点模式
    print("测试设置为多点模式...")
    modeManager.setMultiPointMode(points: positions, count: 2, interval: 100)
    
    print("模式管理器中的位置管理测试完成！")
}

// 运行测试
// testPositionManager()
// testModeManagerWithPosition()
