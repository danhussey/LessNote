import SwiftUI

struct TopicDetailView: View {
    let group: KnowledgeGroup
    @State private var showExportSheet = false
    
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
                
                Button(action: { showExportSheet.toggle() }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom)
            
            GroupBox("Files") {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(group.files) { file in
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.accentColor)
                                Text(file.url.lastPathComponent)
                                Spacer()
                                Text(file.category.rawValue)
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            Divider()
                        }
                    }
                    .padding()
                }
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