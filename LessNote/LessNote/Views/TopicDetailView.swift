import SwiftUI

struct TopicDetailView: View {
    let group: KnowledgeGroup
    @State private var showImportSheet = false
    @State private var selectedGenerationMode = GenerationMode.conservative
    @State private var numberOfClozes = 5
    @State private var selectedSet: ClozeSet?
    @Binding var selectedClozeItem: ClozeItem?
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
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
                        Text("\(group.clozeSets.flatMap { $0.items }.count) items")
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
                        
                        if group.clozeSets.isEmpty {
                            ContentUnavailableView {
                                Label("No Generated Sets", systemImage: "square.stack.3d.up")
                            } description: {
                                Text("Generate your first set of cloze items")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(group.clozeSets) { set in
                                        Button(action: { selectedSet = set }) {
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text("Generated Set")
                                                        .font(.headline)
                                                    Text(dateFormatter.string(from: set.createdAt))
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                Text("\(set.items.count) items")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding()
                                            .background(selectedSet?.id == set.id ? Color.accentColor.opacity(0.1) : Color.clear)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxHeight: 300)
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

private struct ClozeSetListView: View {
    let sets: [ClozeSet]
    @Binding var selectedSet: ClozeSet?
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        List(sets, selection: $selectedSet) { set in
            HStack {
                VStack(alignment: .leading) {
                    Text("Generated Set")
                        .font(.headline)
                    Text(dateFormatter.string(from: set.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(set.items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .tag(set)
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
    }
}