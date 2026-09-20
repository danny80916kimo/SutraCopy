import SwiftUI

@main
struct SutraCopyApp: App {
    @StateObject private var store = SessionStore()

    init() {
        #if DEBUG
        DebugRender.runIfRequested()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
