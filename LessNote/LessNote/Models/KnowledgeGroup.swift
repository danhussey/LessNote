import Foundation

struct KnowledgeGroup: Identifiable, Codable {
    var id: UUID
    let name: String
    var files: [ImportedFile]
    var clozeItems: [ClozeItem]
    
    init(id: UUID = UUID(), name: String, files: [ImportedFile], clozeItems: [ClozeItem]) {
        self.id = id
        self.name = name
        self.files = files
        self.clozeItems = clozeItems
    }
}