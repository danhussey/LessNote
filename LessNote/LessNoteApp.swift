import SwiftUI

@main
struct LessNoteApp: App {
    @StateObject private var knowledgeManager = KnowledgeManager()
    
    var body: some Scene {
        WindowGroup {
            ThreeColumnView()
                .environmentObject(knowledgeManager)
        }
        .windowStyle(.titleBar)
    }
}