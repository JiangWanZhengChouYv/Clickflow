import Foundation
import SwiftUI
import AppKit
import Combine

class CrosshairState: ObservableObject {
    @Published var mouseLocation: NSPoint = .zero
    @Published var screenHeight: CGFloat = 1080
    
    var flippedY: CGFloat {
        screenHeight - mouseLocation.y
    }
}

class CrosshairOverlayService {
    static let shared = CrosshairOverlayService()
    
    private var window: NSWindow?
    private var globalMouseMonitor: Any?
    private var globalClickMonitor: Any?
    private var globalKeyMonitor: Any?
    private var localMouseMonitor: Any?
    private var localClickMonitor: Any?
    private var localKeyMonitor: Any?
    private var completionHandler: ((CGPoint?) -> Void)?
    private var updateTimer: Timer?
    private var timeoutTimer: Timer?
    private let crosshairState = CrosshairState()
    
    private let timeoutInterval: TimeInterval = 30
    private let updateInterval: TimeInterval = 1.0 / 60.0
    
    private init() {}
    
    func showCrosshair(completion: @escaping (CGPoint?) -> Void) {
        self.completionHandler = completion
        
        let hasPermission = checkAccessibilityPermissions()
        if !hasPermission {
            DispatchQueue.main.async { [weak self] in
                self?.showAccessibilityAlert()
            }
        }
        
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        
        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.isMovable = false
        
        let contentView = CrosshairView(state: crosshairState)
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.autoresizingMask = [.width, .height]
        hostingView.frame = screenFrame
        window.contentView = hostingView
        
        let clickView = ClickThroughView(frame: screenFrame)
        clickView.autoresizingMask = [.width, .height]
        window.contentView?.addSubview(clickView, positioned: .above, relativeTo: nil)
        
        clickView.onClick = { [weak self] location in
            self?.handleClick(at: location)
        }
        clickView.onRightClick = { [weak self] location in
            self?.handleClick(at: location)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.crosshairState.screenHeight = screenFrame.height
            self.crosshairState.mouseLocation = NSEvent.mouseLocation
        }
        
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        self.window = window
        
        startMonitoring()
        startUpdateTimer()
        startTimeoutTimer()
    }
    
    func hideCrosshair() {
        stopMonitoring()
        stopUpdateTimer()
        stopTimeoutTimer()
        window?.close()
        window = nil
        completionHandler = nil
    }
    
    private func checkAccessibilityPermissions() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        return accessEnabled
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "Clickflow 需要辅助功能权限才能全局监听鼠标事件。请在系统设置 > 隐私与安全性 > 辅助功能中启用 Clickflow。"
        alert.addButton(withTitle: "确定")
        alert.alertStyle = .warning
        alert.runModal()
    }
    
    private func updateCrosshairLocation() {
        let location = NSEvent.mouseLocation
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.crosshairState.mouseLocation = location
        }
    }
    
    private func handleClick(at location: NSPoint) {
        let screenHeight = NSScreen.main?.frame.height ?? 1080
        let y = screenHeight - location.y
        let point = CGPoint(x: location.x, y: y)
        completionHandler?(point)
        hideCrosshair()
    }
    
    private func handleESC() {
        completionHandler?(nil)
        hideCrosshair()
    }
    
    private func startMonitoring() {
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]) { [weak self] _ in
            self?.updateCrosshairLocation()
        }
        
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]) { [weak self] event in
            self?.updateCrosshairLocation()
            return event
        }
        
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self else { return }
            let location = NSEvent.mouseLocation
            self.handleClick(at: location)
        }
        
        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self else { return event }
            let location = event.locationInWindow
            if let window = self.window {
                let screenLocation = window.convertPoint(toScreen: location)
                self.handleClick(at: screenLocation)
            }
            return nil
        }
        
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            if event.keyCode == 53 {
                self.handleESC()
            }
        }
        
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            if event.keyCode == 53 {
                self.handleESC()
                return nil
            }
            return event
        }
    }
    
    private func stopMonitoring() {
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseMonitor = nil
        }
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
            globalClickMonitor = nil
        }
        if let monitor = globalKeyMonitor {
            NSEvent.removeMonitor(monitor)
            globalKeyMonitor = nil
        }
        if let monitor = localMouseMonitor {
            NSEvent.removeMonitor(monitor)
            localMouseMonitor = nil
        }
        if let monitor = localClickMonitor {
            NSEvent.removeMonitor(monitor)
            localClickMonitor = nil
        }
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
    }
    
    private func startUpdateTimer() {
        stopUpdateTimer()
        let timer = Timer(timeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateCrosshairLocation()
        }
        RunLoop.main.add(timer, forMode: .common)
        updateTimer = timer
    }
    
    private func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func startTimeoutTimer() {
        stopTimeoutTimer()
        let timer = Timer(timeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            self?.handleESC()
        }
        RunLoop.main.add(timer, forMode: .common)
        timeoutTimer = timer
    }
    
    private func stopTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
}

class ClickThroughView: NSView {
    var onClick: ((NSPoint) -> Void)?
    var onRightClick: ((NSPoint) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, to: nil)
        if let window = self.window {
            let screenLocation = window.convertPoint(toScreen: location)
            onClick?(screenLocation)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, to: nil)
        if let window = self.window {
            let screenLocation = window.convertPoint(toScreen: location)
            onRightClick?(screenLocation)
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
}

struct CrosshairView: View {
    @ObservedObject var state: CrosshairState
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                
                CrosshairShape()
                    .stroke(Color.red, lineWidth: 1.5)
                    .frame(width: 120, height: 120)
                    .position(
                        x: state.mouseLocation.x - geometry.frame(in: .global).minX,
                        y: geometry.size.height - (state.mouseLocation.y - geometry.frame(in: .global).minY) - 60
                    )
                
                CoordinateText(x: state.mouseLocation.x, y: state.flippedY)
                    .position(
                        x: state.mouseLocation.x - geometry.frame(in: .global).minX,
                        y: geometry.size.height - (state.mouseLocation.y - geometry.frame(in: .global).minY) + 40
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CrosshairShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let centerX = rect.midX
        let centerY = rect.midY
        let crossLength: CGFloat = 15
        
        path.move(to: CGPoint(x: centerX - crossLength, y: centerY))
        path.addLine(to: CGPoint(x: centerX + crossLength, y: centerY))
        
        path.move(to: CGPoint(x: centerX, y: centerY - crossLength))
        path.addLine(to: CGPoint(x: centerX, y: centerY + crossLength))
        
        let circleRadius: CGFloat = 20
        path.addEllipse(in: CGRect(x: centerX - circleRadius, y: centerY - circleRadius, width: circleRadius * 2, height: circleRadius * 2))
        
        return path
    }
}

struct CoordinateText: View {
    let x: CGFloat
    let y: CGFloat
    
    var body: some View {
        Text("X: \(Int(x))  Y: \(Int(y))")
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.75))
            .cornerRadius(4)
    }
}
