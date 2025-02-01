import SwiftUI

struct ClozeItemsSidebar: View {
    let group: KnowledgeGroup
    let selectedSet: ClozeSet?
    @Binding var selectedItem: ClozeItem?
    @State private var searchText = ""
    @State private var priorityFilter: ClozeItem.PriorityLevel?
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter controls
            VStack(spacing: 8) {
                TextField("Search items...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    ForEach([ClozeItem.PriorityLevel.high,
                            ClozeItem.PriorityLevel.medium,
                            ClozeItem.PriorityLevel.low], id: \.self) { priority in
                        FilterButton(
                            title: priority.rawValue.capitalized,
                            isSelected: priorityFilter == priority,
                            color: priority.color
                        ) {
                            priorityFilter = priorityFilter == priority ? nil : priority
                        }
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Cloze items list
            List(filteredItems, selection: $selectedItem) {
                ClozeItemRow(item: $0)
            }
            .listStyle(.plain)
        }
        .navigationTitle("Cloze Items")
    }
    
    private var filteredItems: [ClozeItem] {
        let items = selectedSet?.items ?? []
        return items.filter { item in
            let matchesSearch = searchText.isEmpty ||
                item.text.localizedCaseInsensitiveContains(searchText)
            let matchesPriority = priorityFilter == nil || item.priority == priorityFilter
            return matchesSearch && matchesPriority
        }
    }
}

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? color.opacity(0.2) : Color.clear)
                .foregroundColor(isSelected ? color : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ClozeItemRow: View {
    let item: ClozeItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.text)
                .lineLimit(3)
            HStack {
                Text(item.priority.rawValue.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.priority.color.opacity(0.2))
                    .foregroundColor(item.priority.color)
                    .cornerRadius(4)
                
                Spacer()
                
                Button {
                    // Add review functionality here
                } label: {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
