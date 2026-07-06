import Foundation

enum MouseButton: String, CaseIterable, Identifiable {
    case left = "左键"
    case right = "右键"
    
    var id: String { rawValue }
}
