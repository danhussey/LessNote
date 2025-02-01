import SwiftUI

struct TopicDetailView: View {
    let group: KnowledgeGroup
    @State private var showImportSheet = false
    @State private var selectedGenerationMode = GenerationMode.conservative
    @State private var numberOfClozes = 5
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    
    enum GenerationMode: String, CaseIterable {
        case conservative = "Conservative"
        case balanced = "Balanced"
        case aggressive = "Aggressive"
    }
    
    private func iconName(for file: ImportedFile) -> String {
        switch file.url.pathExtension.lowercased() {
        case "pdf":
            return "doc.fill"
        case "txt":
            return "doc.text"
        case "md", "markdown":
            return "doc.plaintext"
        default:
            return "doc"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                HStack {
                    VStack(alignment: .leading) {
                        Text(group.name)
                            .font(.title)
                            .bold()
                        Text("\(group.files.count) files · \(group.clozeItems.count) items")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showImportSheet.toggle() }) {
                        Label("Import Files", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom)
                
                // Files Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Source Files")
                                .font(.headline)
                            Spacer()
                        }
                        
                        if group.files.isEmpty {
                            ContentUnavailableView {
                                Label("No Files", systemImage: "doc")
                            } description: {
                                Text("Import files to generate cloze items")
                            } actions: {
                                Button("Import Files") {
                                    showImportSheet.toggle()
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            FileListView(files: group.files)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                
                // Generation Controls
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Cloze Generation")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Generation Mode", selection: $selectedGenerationMode) {
                                ForEach(GenerationMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            HStack {
                                Text("Items to Generate:")
                                Stepper("\(numberOfClozes)", value: $numberOfClozes, in: 1...50)
                            }
                            
                            Button(action: generateClozes) {
                                Label("Generate Cloze Items", systemImage: "wand.and.stars")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(group.files.isEmpty)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                
                // Generated Sets Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Generated Sets")
                            .font(.headline)
                        
                        if group.clozeItems.isEmpty {
                            ContentUnavailableView {
                                Label("No Generated Items", systemImage: "square.stack.3d.up")
                            } description: {
                                Text("Generate your first set of cloze items")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            GeneratedSetsView(items: group.clozeItems)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showImportSheet) {
            ImportView(groupId: group.id)
                .frame(width: 400, height: 300)
        }
    }
    
    private func generateClozes() {
        // Placeholder for AI-based generation
        // This will be implemented when AI integration is added
    }
}

private struct FileListView: View {
    let files: [ImportedFile]
    
    var body: some View {
        ForEach(FileCategory.allCases, id: \.self) { category in
            let categoryFiles = files.filter { $0.category == category }
            if !categoryFiles.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(categoryFiles) { file in
                        HStack {
                            Image(systemName: "doc")
                                .foregroundColor(.accentColor)
                            Text(file.url.lastPathComponent)
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                Divider()
            }
        }
    }
}

private struct GeneratedSetsView: View {
    let items: [ClozeItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
                if index < 3 {  // Preview only first 3 items
                    HStack {
                        Text(item.text)
                            .lineLimit(2)
                        Spacer()
                        Text(item.priority.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(item.priority.color.opacity(0.2))
                            .foregroundColor(item.priority.color)
                            .cornerRadius(4)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            
            if items.count > 3 {
                Text("+ \(items.count - 3) more items")
                    .foregroundColor(.secondary)
                    .padding(.leading)
            }
        }
    }
}
