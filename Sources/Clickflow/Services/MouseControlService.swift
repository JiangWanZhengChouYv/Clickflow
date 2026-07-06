import Foundation
import CoreGraphics
import AppKit

class MouseControlService {
    static let shared = MouseControlService()
    
    private init() {}
    
    func moveMouse(to x: Double, _ y: Double) {
        let point = CGPoint(x: x, y: y)
        guard let event = CGEvent(mouseEventSource: nil,
                                  mouseType: .mouseMoved,
                                  mouseCursorPosition: point,
                                  mouseButton: .left) else { return }
        event.post(tap: .cghidEventTap)
    }
    
    func click(at x: Double, _ y: Double, button: MouseButton) {
        let point = CGPoint(x: x, y: y)
        let cgButton: CGMouseButton = button == .left ? .left : .right
        let downType: CGEventType = button == .left ? .leftMouseDown : .rightMouseDown
        let upType: CGEventType = button == .left ? .leftMouseUp : .rightMouseUp
        
        guard let downEvent = CGEvent(mouseEventSource: nil,
                                      mouseType: downType,
                                      mouseCursorPosition: point,
                                      mouseButton: cgButton) else { return }
        downEvent.post(tap: .cghidEventTap)
        
        guard let upEvent = CGEvent(mouseEventSource: nil,
                                    mouseType: upType,
                                    mouseCursorPosition: point,
                                    mouseButton: cgButton) else { return }
        upEvent.post(tap: .cghidEventTap)
    }
    
    func getCurrentPosition() -> (x: Double, y: Double) {
        let location = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 1080
        let y = screenHeight - location.y
        return (x: Double(location.x), y: Double(y))
    }
}
