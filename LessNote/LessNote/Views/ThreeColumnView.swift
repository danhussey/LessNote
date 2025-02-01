import SwiftUI

struct ThreeColumnView: View {
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var selectedGroupId: UUID? = nil
    @State private var selectedClozeItem: ClozeItem? = nil
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Left Sidebar - Course Weeks/Topics
            CourseSidebarView(selectedGroupId: $selectedGroupId)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } content: {
            // Middle Section - Topic Details and Controls
            Group {
                if let selectedId = selectedGroupId,
                   let selectedGroup = knowledgeManager.knowledgeGroups.first(where: { $0.id == selectedId }) {
                    TopicDetailView(group: selectedGroup)
                } else {
                    ContentUnavailableView("Select a Topic",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Choose a course topic from the sidebar or import new materials"))
                }
            }
            .navigationSplitViewColumnWidth(min: 400, ideal: 500, max: .infinity)
        } detail: {
            // Right Sidebar - Cloze Items
            Group {
                if let selectedId = selectedGroupId,
                   let selectedGroup = knowledgeManager.knowledgeGroups.first(where: { $0.id == selectedId }) {
                    ClozeItemsSidebar(group: selectedGroup, selectedItem: $selectedClozeItem)
                } else {
                    ContentUnavailableView("No Cloze Items",
                        systemImage: "doc.text.fill",
                        description: Text("Select a topic to view its cloze deletions"))
                }
            }
            .navigationSplitViewColumnWidth(min: 300, ideal: 350, max: 400)
        }
        .navigationSplitViewStyle(.balanced)
    }
}