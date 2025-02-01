import Foundation

enum FileCategory: String, CaseIterable, Codable {
    case syllabi
    case learningResources
    case tests
}

struct ImportedFile: Identifiable, Codable {
    var id: UUID
    let url: URL
    var category: FileCategory
    
    init(id: UUID = UUID(), url: URL, category: FileCategory) {
        self.id = id
        self.url = url
        self.category = category
    }
}