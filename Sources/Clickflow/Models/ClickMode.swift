import Foundation

enum ClickMode: String, CaseIterable, Identifiable {
    case single = "单点"
    case multi = "多点"
    
    var id: String { rawValue }
}
