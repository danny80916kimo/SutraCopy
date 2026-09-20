import SwiftUI

@main
struct SutraCopyApp: App {
    @StateObject private var store = SessionStore()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
