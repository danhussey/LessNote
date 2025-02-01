import SwiftUI
import UniformTypeIdentifiers

struct CourseSidebarView: View {
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @Binding var selectedGroupId: UUID?
    
    var body: some View {
        List(selection: $selectedGroupId) {
            Section {
                Button(action: addNewTopic) {
                    Label("Add Topic", systemImage: "plus.circle")
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
                    .tag(group.id)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Courses")
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