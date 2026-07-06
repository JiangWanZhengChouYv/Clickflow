import Foundation
import SwiftUI
import AppKit
import Combine

class CrosshairOverlayService {
    static let shared = CrosshairOverlayService()

    private var window: NSWindow?
    private var mouseMonitor: Any?
    private var clickMonitor: Any?
    private var keyMonitor: Any?
    private var completionHandler: ((CGPoint?) -> Void)?

    private init() {}

    func showCrosshair(completion: @escaping (CGPoint?) -> Void) {
        self.completionHandler = completion

        // 创建窗口
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 120),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]

        // 创建 SwiftUI 视图
        let contentView = CrosshairView()
        let hostingView = NSHostingView(rootView: contentView)
        window.contentView = hostingView

        // 设置初始位置
        updateWindowPosition(window)

        window.makeKeyAndOrderFront(nil)
        self.window = window

        // 开始监听事件
        startMonitoring()
    }

    func hideCrosshair() {
        stopMonitoring()
        window?.close()
        window = nil
    }

    private func updateWindowPosition(_ window: NSWindow) {
        let mouseLocation = NSEvent.mouseLocation
        let windowSize: CGFloat = 120
        let originX = mouseLocation.x - windowSize / 2
        let originY = mouseLocation.y - windowSize / 2

        window.setFrameOrigin(NSPoint(x: originX, y: originY))
    }

    private func startMonitoring() {
        // 监听鼠标移动
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]) { [weak self] event in
            guard let self = self, let window = self.window else { return }
            self.updateWindowPosition(window)
        }

        // 监听鼠标点击
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self else { return }
            let mouseLocation = NSEvent.mouseLocation
            let screenHeight = NSScreen.main?.frame.height ?? 1080
            let y = screenHeight - mouseLocation.y
            let point = CGPoint(x: mouseLocation.x, y: y)
            self.completionHandler?(point)
            self.hideCrosshair()
        }

        // 监听 ESC 键
        keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            if event.keyCode == 53 { // ESC 键
                self.completionHandler?(nil)
                self.hideCrosshair()
            }
        }
    }

    private func stopMonitoring() {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMonitor = nil
        }
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
}

struct CrosshairView: View {
    var body: some View {
        ZStack {
            // 十字准星
            CrosshairShape()
                .stroke(Color.red, lineWidth: 1.5)

            // 坐标显示
            VStack {
                Spacer()
                CoordinateText()
                    .offset(y: 20)
            }
        }
        .frame(width: 120, height: 120)
    }
}

struct CrosshairShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let centerX = rect.midX
        let centerY = rect.midY
        let crossLength: CGFloat = 15

        // 水平线
        path.move(to: CGPoint(x: centerX - crossLength, y: centerY))
        path.addLine(to: CGPoint(x: centerX + crossLength, y: centerY))

        // 垂直线
        path.move(to: CGPoint(x: centerX, y: centerY - crossLength))
        path.addLine(to: CGPoint(x: centerX, y: centerY + crossLength))

        // 外圈
        let circleRadius: CGFloat = 20
        path.addEllipse(in: CGRect(x: centerX - circleRadius, y: centerY - circleRadius, width: circleRadius * 2, height: circleRadius * 2))

        return path
    }
}

struct CoordinateText: View {
    var body: some View {
        let mouseLocation = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 1080
        let y = screenHeight - mouseLocation.y

        Text("X: \(Int(mouseLocation.x))  Y: \(Int(y))")
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.75))
            .cornerRadius(4)
    }
}