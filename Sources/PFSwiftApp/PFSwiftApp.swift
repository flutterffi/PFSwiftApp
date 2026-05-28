import ComposableArchitecture
import SwiftUI

@main
struct PFSwiftApp: App {
    var body: some Scene {
        WindowGroup {
            PFAppView(
                store: Store(initialState: PFAppFeature.State()) {
                    PFAppFeature()
                }
            )
        }
    }
}
