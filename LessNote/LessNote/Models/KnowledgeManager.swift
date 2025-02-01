import SwiftUI
import UniformTypeIdentifiers

extension FileManager {
    func fileExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileExists(atPath: url.path, isDirectory: &isDirectory)
    }
}

enum ImportError: LocalizedError {
    case fileAccessDenied
    case invalidFile
    
    var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            return "Unable to access one or more files"
        case .invalidFile:
            return "One or more files are invalid or corrupted"
        }
    }
}

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
    
    func addFilesToGroup(urls: [URL], groupId: UUID) throws {
        guard let groupIndex = knowledgeGroups.firstIndex(where: { $0.id == groupId }) else {
            throw ImportError.invalidFile
        }
        
        // Create ImportedFile objects and copy files to app's documents directory
        let importedFiles = try urls.compactMap { sourceURL -> ImportedFile? in
            // Get the documents directory
            guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw ImportError.fileAccessDenied
            }
            
            // Create a unique filename
            let uniqueFilename = "\(UUID().uuidString)_\(sourceURL.lastPathComponent)"
            let destinationURL = documentsDir.appendingPathComponent(uniqueFilename)
            
            // Copy the file
            do {
                if !FileManager.default.fileExists(at: sourceURL) {
                    throw ImportError.invalidFile
                }
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                return ImportedFile(url: destinationURL, category: guessCategory(for: sourceURL))
            } catch {
                print("Error copying file: \(error)")
                throw ImportError.fileAccessDenied
            }
        }
        
        var allClozeItems: [ClozeItem] = []
        for file in importedFiles {
            if let content = try? String(contentsOf: file.url, encoding: .utf8) {
                let items = generateClozeItems(from: content)
                allClozeItems.append(contentsOf: items)
            }
        }
        
        DispatchQueue.main.async {
            self.knowledgeGroups[groupIndex].files.append(contentsOf: importedFiles)
            self.knowledgeGroups[groupIndex].clozeItems.append(contentsOf: allClozeItems)
            self.objectWillChange.send()
        }
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