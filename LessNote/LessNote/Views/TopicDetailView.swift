import SwiftUI

struct TopicDetailView: View {
    let group: KnowledgeGroup
    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    
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
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text(group.name)
                        .font(.title)
                        .bold()
                    Text("\(group.files.count) files · \(group.clozeItems.count) items")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { showImportSheet.toggle() }) {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { showExportSheet.toggle() }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.bottom)
            
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Files")
                            .font(.headline)
                        Spacer()
                    }
                    
                    if group.files.isEmpty {
                        ContentUnavailableView {
                            Label("No Files", systemImage: "doc")
                        } description: {
                            Text("Import files to get started")
                        } actions: {
                            Button("Import Files") {
                                showImportSheet.toggle()
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(FileCategory.allCases, id: \.self) { category in
                                    let categoryFiles = group.files.filter { $0.category == category }
                                    if !categoryFiles.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(category.rawValue.capitalized)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .padding(.leading, 4)
                                            
                                            VStack(spacing: 4) {
                                                ForEach(categoryFiles) { file in
                                                    HStack {
                                                        Image(systemName: iconName(for: file))
                                                            .foregroundColor(.accentColor)
                                                        Text(file.url.lastPathComponent)
                                                            .lineLimit(1)
                                                        Spacer()
                                                        Text(file.url.pathExtension.uppercased())
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color.secondary.opacity(0.1))
                                                            .cornerRadius(4)
                                                    }
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 6)
                                                    .background(Color.secondary.opacity(0.05))
                                                    .cornerRadius(8)
                                                }
                                            }
                                        }
                                        
                                        if category != FileCategory.allCases.last {
                                            Divider()
                                                .padding(.vertical, 8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            
            GroupBox("Statistics") {
                Grid(alignment: .leading) {
                    GridRow {
                        Text("High Priority")
                        Text("\(highPriorityCount)")
                            .foregroundColor(.red)
                    }
                    GridRow {
                        Text("Medium Priority")
                        Text("\(mediumPriorityCount)")
                            .foregroundColor(.orange)
                    }
                    GridRow {
                        Text("Low Priority")
                        Text("\(lowPriorityCount)")
                            .foregroundColor(.green)
                    }
                }
                .padding()
            }
        }
        .padding()
        .sheet(isPresented: $showExportSheet) {
            ExportView(group: group)
        }
        .sheet(isPresented: $showImportSheet) {
            ImportView()
                .frame(width: 400, height: 300)
        }
    }
    
    private var highPriorityCount: Int {
        group.clozeItems.filter { $0.priority == .high }.count
    }
    
    private var mediumPriorityCount: Int {
        group.clozeItems.filter { $0.priority == .medium }.count
    }
    
    private var lowPriorityCount: Int {
        group.clozeItems.filter { $0.priority == .low }.count
    }
}

private struct ExportView: View {
    let group: KnowledgeGroup
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var exportError: Error?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Items")
                .font(.title)
            
            Text("Export \(group.clozeItems.count) cloze items from '\(group.name)' as CSV")
                .multilineTextAlignment(.center)
            
            Button("Export to CSV") {
                do {
                    let url = try knowledgeManager.exportClozeItemsToCSV(for: group)
                    NSWorkspace.shared.open(url)
                    dismiss()
                } catch {
                    exportError = error
                    showError = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(width: 300, height: 200)
        .padding()
        .alert("Export Error", isPresented: $showError, presenting: exportError) { _ in
            Button("OK") { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}