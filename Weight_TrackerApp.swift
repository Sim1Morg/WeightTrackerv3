import SwiftUI

@main
struct WeightTrackerApp: App {
    @StateObject var DataManager = DataManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DataManager)
        }
    }
}
