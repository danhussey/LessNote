import SwiftUI

@main
struct LessNoteApp: App {
    @StateObject private var knowledgeManager = KnowledgeManager()
    
    var body: some Scene {
        WindowGroup {
            ThreeColumnView()
                .environmentObject(knowledgeManager)
                .frame(minWidth: 1000, minHeight: 600)
        }
        .windowStyle(.titleBar)
    }
}