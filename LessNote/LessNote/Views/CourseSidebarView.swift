import SwiftUI
import UniformTypeIdentifiers

struct CourseSidebarView: View {
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @Binding var selectedGroupId: UUID?
    @State private var showImportSheet = false
    
    var body: some View {
        List(selection: $selectedGroupId) {
            Section {
                Button(action: addNewTopic) {
                    Label("Add Topic", systemImage: "plus.circle")
                }
                Button(action: { showImportSheet.toggle() }) {
                    Label("Import Files", systemImage: "square.and.arrow.down")
                }
            }
            
            Section("Course Topics") {
                ForEach(knowledgeManager.knowledgeGroups) { group in
                    NavigationLink(
                        isActive: Binding(
                            get: { selectedGroupId == group.id },
                            set: { if $0 { selectedGroupId = group.id } }
                        )
                    ) {
                        EmptyView()
                    } label: {
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
        .sheet(isPresented: $showImportSheet) {
            ImportView()
                .frame(width: 400, height: 300)
        }
    }
    
    private func addNewTopic() {
        let alert = NSAlert()
        alert.messageText = "New Topic"
        alert.informativeText = "Enter the name for the new topic:"
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = input
        
        if alert.runModal() == .alertFirstButtonReturn {
            let topicName = input.stringValue.trimmingCharacters(in: .whitespaces)
            if !topicName.isEmpty {
                let newGroup = KnowledgeGroup(
                    name: topicName,
                    files: [],
                    clozeItems: []
                )
                knowledgeManager.knowledgeGroups.append(newGroup)
                selectedGroupId = newGroup.id
            }
        }
    }
}

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var groupName: String = ""
    @State private var selectedFiles: [URL] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Import Files")
                .font(.title)
                .padding()
            
            TextField("Group Name", text: $groupName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            if selectedFiles.isEmpty {
                ContentUnavailableView {
                    Label("No Files Selected", systemImage: "doc")
                } description: {
                    Text("Choose files to import")
                }
            } else {
                List(selectedFiles, id: \.self) { url in
                    Label(url.lastPathComponent, systemImage: "doc")
                }
                .frame(height: 100)
            }
            
            HStack(spacing: 16) {
                Button("Select Files") {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseDirectories = false
                    panel.allowedContentTypes = [
                        UTType.plainText,
                        UTType(filenameExtension: "md")!,
                        UTType(filenameExtension: "markdown")!,
                        UTType.pdf
                    ]
                    
                    if panel.runModal() == .OK {
                        selectedFiles = panel.urls
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Import") {
                    guard !groupName.isEmpty, !selectedFiles.isEmpty else { return }
                    knowledgeManager.ingestFilesIntoNewGroup(urls: selectedFiles)
                    dismiss()
                }
                .buttonStyle(.bordered)
                .disabled(groupName.isEmpty || selectedFiles.isEmpty)
            }
            .padding()
            
            Spacer()
        }
    }
}