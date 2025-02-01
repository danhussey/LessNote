import SwiftUI
import UniformTypeIdentifiers

struct CourseSidebarView: View {
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @Binding var selectedGroupId: UUID?
    @State private var showImportSheet = false
    
    var body: some View {
        List(selection: $selectedGroupId) {
            Section {
                Button(action: { showImportSheet.toggle() }) {
                    Label("Import Files", systemImage: "doc.badge.plus")
                }
                .sheet(isPresented: $showImportSheet) {
                    ImportView()
                        .frame(width: 400, height: 300)
                }
            }
            
            Section("Course Topics") {
                ForEach(knowledgeManager.knowledgeGroups) { group in
                    NavigationLink(value: group.id) {
                        VStack(alignment: .leading) {
                            Text(group.name)
                                .font(.headline)
                            Text("\(group.clozeItems.count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Courses")
    }
}

private struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    
    var body: some View {
        VStack {
            Text("Import Files")
                .font(.title)
                .padding()
            
            Button("Select Files") {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = true
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [
                    UTType.plainText,
//                    UTType.markdown,
                    UTType.pdf
                ]
                
                if panel.runModal() == .OK {
                    knowledgeManager.ingestFilesIntoNewGroup(urls: panel.urls)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Spacer()
        }
    }
}
