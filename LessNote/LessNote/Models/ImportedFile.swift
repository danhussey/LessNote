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
    
    enum CodingKeys: String, CodingKey {
        case id, category
        case url
    }
    
    init(id: UUID = UUID(), url: URL, category: FileCategory) {
        self.id = id
        self.url = url
        self.category = category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        category = try container.decode(FileCategory.self, forKey: .category)
        
        let urlString = try container.decode(String.self, forKey: .url)
        url = URL(fileURLWithPath: urlString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(url.path, forKey: .url)
    }
}