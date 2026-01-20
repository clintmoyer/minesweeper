import SwiftUI

@main
struct MinesweeperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
