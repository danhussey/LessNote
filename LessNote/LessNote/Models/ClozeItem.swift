import SwiftUI

struct ClozeSet: Identifiable, Codable, Hashable {
    var id: UUID
    let createdAt: Date
    let items: [ClozeItem]
    
    init(id: UUID = UUID(), items: [ClozeItem]) {
        self.id = id
        self.createdAt = Date()
        self.items = items
    }
    
    static func == (lhs: ClozeSet, rhs: ClozeSet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ClozeItem: Identifiable, Codable, Hashable {
    enum PriorityLevel: String, Codable, Identifiable {
        case high
        case medium
        case low
        
        var id: String { self.rawValue }
        
        var color: Color {
            switch self {
            case .high:
                return .red
            case .medium:
                return .orange
            case .low:
                return .green
            }
        }
    }
    
    var id: UUID
    let text: String      // The text with the cloze deletion
    let original: String  // The original text (without the deletion)
    let priority: PriorityLevel
    
    init(id: UUID = UUID(), text: String, original: String, priority: PriorityLevel) {
        self.id = id
        self.text = text
        self.original = original
        self.priority = priority
    }
    
    static func == (lhs: ClozeItem, rhs: ClozeItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}