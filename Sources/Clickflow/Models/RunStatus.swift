import Foundation

enum RunStatus: String, CaseIterable, Identifiable {
    case ready = "就绪"
    case running = "运行中"
    case paused = "已暂停"
    
    var id: String { rawValue }
}
