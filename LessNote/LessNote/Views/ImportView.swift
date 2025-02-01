import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    let groupId: UUID
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var selectedFiles: [URL] = []
    @State private var isDragging = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    let allowedTypes = [
        UTType.text,
        UTType.pdf,
        UTType.plainText,
//        UTType.markdown
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Import Files")
                .font(.title2)
                .padding(.top)
                .padding(.bottom, 20)
            
            // Content Area
            ScrollView {
                VStack(spacing: 20) {
                    // Drop zone
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .fill(isDragging ? Color.accentColor : Color.secondary)
                            .frame(height: 200)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            Text("Drop files here")
                                .foregroundColor(.secondary)
                            
                            Text("or")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                            
                            Button("Select Files") {
                                selectFiles()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    // Selected files list
                    if !selectedFiles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Files:")
                                .font(.headline)
                            
                            ForEach(selectedFiles, id: \.self) { url in
                                HStack {
                                    Image(systemName: "doc")
                                    Text(url.lastPathComponent)
                                        .lineLimit(1)
                                    Spacer()
                                    Button {
                                        selectedFiles.removeAll { $0 == url }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Divider()
                .padding(.vertical)
            
            // Footer Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Import") {
                    importFiles()
                }
                .keyboardShortcut(.return)
                .disabled(selectedFiles.isEmpty)
            }
            .padding()
        }
        .frame(width: 400, height: 300)
        .alert("Import Error",
            isPresented: $showErrorAlert,
            actions: {
                Button("OK", role: .cancel) { }
            },
            message: {
                Text(errorMessage)
            }
        )
        .onDrop(of: allowedTypes, isTargeted: $isDragging) { providers in
            Task {
                for provider in providers {
                    if let identifier = provider.registeredTypeIdentifiers.first,
                       let urlType = UTType(identifier),
                       allowedTypes.contains { $0.conforms(to: urlType) },
                       let item = try? await provider.loadItem(forTypeIdentifier: identifier),
                       let url = item as? URL {
                        selectedFiles.append(url)
                    }
                }
            }
            return true
        }
    }
    
    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = allowedTypes
        
        if panel.runModal() == .OK {
            selectedFiles.append(contentsOf: panel.urls)
        }
    }
    
    private func importFiles() {
        guard !selectedFiles.isEmpty else { return }
        
        do {
            try knowledgeManager.addFilesToGroup(urls: selectedFiles, groupId: groupId)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    private func categorizeFile(_ url: URL) -> FileCategory {
        let filename = url.lastPathComponent.lowercased()
        
        if filename.contains("syllabus") {
            return .syllabi
        } else if filename.contains("test") || filename.contains("exam") {
            return .tests
        } else {
            return .learningResources
        }
    }
}