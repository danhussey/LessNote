import SwiftUI
import UniformTypeIdentifiers

class KnowledgeManager: ObservableObject {
    @Published var knowledgeGroups: [KnowledgeGroup] = []
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        guard knowledgeGroups.isEmpty else { return }
        
        // Sample Group 1: Biology
        let biologyFiles = [
            ImportedFile(url: URL(fileURLWithPath: "CellStructure.txt"), category: .learningResources),
            ImportedFile(url: URL(fileURLWithPath: "Exam-Prep.txt"), category: .tests)
        ]
        
        let biologyClozeItems = [
            ClozeItem(
                text: "The cell membrane controls the movement of substances in and out of _____.",
                original: "The cell membrane controls the movement of substances in and out of cells.",
                priority: .high
            ),
            ClozeItem(
                text: "Mitochondria are often called the powerhouses of the _____.",
                original: "Mitochondria are often called the powerhouses of the cell.",
                priority: .medium
            )
        ]
        
        let biologyGroup = KnowledgeGroup(
            name: "Biology",
            files: biologyFiles,
            clozeItems: biologyClozeItems
        )
        
        knowledgeGroups.append(biologyGroup)
    }
    
    func ingestFilesIntoNewGroup(urls: [URL]) {
        let alert = NSAlert()
        alert.messageText = "Enter a Group Name"
        alert.informativeText = "Provide a name for the new group:"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = input
        
        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }
        
        let groupName = input.stringValue.trimmingCharacters(in: .whitespaces)
        guard !groupName.isEmpty else { return }
        
        let importedFiles = urls.map { url in
            ImportedFile(url: url, category: guessCategory(for: url))
        }
        
        var allClozeItems: [ClozeItem] = []
        for url in urls {
            if let content = try? String(contentsOf: url, encoding: .utf8) {
                let items = generateClozeItems(from: content)
                allClozeItems.append(contentsOf: items)
            }
        }
        
        let newGroup = KnowledgeGroup(
            name: groupName,
            files: importedFiles,
            clozeItems: allClozeItems
        )
        
        knowledgeGroups.append(newGroup)
    }
    
    private func guessCategory(for url: URL) -> FileCategory {
        let fileName = url.lastPathComponent.lowercased()
        if fileName.contains("syllabus") {
            return .syllabi
        } else if fileName.contains("test") || fileName.contains("exam") {
            return .tests
        } else {
            return .learningResources
        }
    }
    
    private func generateClozeItems(from text: String) -> [ClozeItem] {
        let sentences = text.components(separatedBy: ".").filter { !$0.isEmpty }
        return sentences.compactMap { sentence in
            let words = sentence.split(separator: " ")
            guard let randomWord = words.randomElement() else { return nil }
            
            let cleanSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            let clozeText = cleanSentence.replacingOccurrences(
                of: String(randomWord),
                with: "_____"
            )
            
            return ClozeItem(
                text: clozeText,
                original: cleanSentence,
                priority: [.high, .medium, .low].randomElement() ?? .medium
            )
        }
    }
    
    func exportClozeItemsToCSV(for group: KnowledgeGroup) throws -> URL {
        let fileName = "\(group.name).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var csvText = "Text,Original,Priority\n"
        for item in group.clozeItems {
            csvText += "\"\(item.text)\",\"\(item.original)\",\(item.priority.rawValue)\n"
        }
        
        try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}