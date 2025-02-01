import SwiftUI

struct ThreeColumnView: View {
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var selectedGroupId: UUID? = nil
    @State private var selectedClozeItem: ClozeItem? = nil
    
    var body: some View {
        NavigationView {
            // Left Sidebar - Course Weeks/Topics
            CourseSidebarView(selectedGroupId: $selectedGroupId)
                .frame(minWidth: 200, maxWidth: 300)
            
            // Middle Section - Topic Details and Controls
            if let selectedId = selectedGroupId,
               let selectedGroup = knowledgeManager.knowledgeGroups.first(where: { group in group.id == selectedId }) {
                TopicDetailView(group: selectedGroup)
                    .frame(minWidth: 400)
            } else {
                ContentUnavailableView("Select a Topic",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Choose a course topic from the sidebar or import new materials"))
                    .frame(minWidth: 400)
            }
            
            // Right Sidebar - Cloze Items
            if let selectedId = selectedGroupId,
               let selectedGroup = knowledgeManager.knowledgeGroups.first(where: { group in group.id == selectedId }) {
                ClozeItemsSidebar(group: selectedGroup, selectedItem: $selectedClozeItem)
                    .frame(minWidth: 300, maxWidth: .infinity)
            } else {
                ContentUnavailableView("No Cloze Items",
                    systemImage: "doc.text.fill",
                    description: Text("Select a topic to view its cloze deletions"))
                    .frame(minWidth: 300, maxWidth: .infinity)
            }
        }
        .navigationViewStyle(.automatic)
        .frame(minWidth: 1000, minHeight: 600)
    }
}