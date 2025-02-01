import Foundation

struct KnowledgeGroup: Identifiable, Codable {
    var id: UUID
    let name: String
    var files: [ImportedFile]
    var clozeSets: [ClozeSet]
    
    init(id: UUID = UUID(), name: String, files: [ImportedFile], clozeSets: [ClozeSet] = []) {
        self.id = id
        self.name = name
        self.files = files
        self.clozeSets = clozeSets
    }
}