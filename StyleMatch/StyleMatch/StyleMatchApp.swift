import SwiftUI

@main
struct StyleMatchApp: App{
    @StateObject private var catalog = Catalog()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(catalog)
        }
    }
}
