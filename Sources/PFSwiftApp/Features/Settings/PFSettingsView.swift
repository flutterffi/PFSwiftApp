import ComposableArchitecture
import SwiftUI

struct PFSettingsView: View {
    @Bindable var store: StoreOf<PFSettingsFeature>

    var body: some View {
        NavigationStack {
            Form {
                Section("Telemetry") {
                    Toggle(
                        "Analytics",
                        isOn: $store.isAnalyticsEnabled.sending(\.analyticsChanged)
                    )
                    Toggle(
                        "Crash Reporting",
                        isOn: $store.isCrashReportingEnabled.sending(\.crashReportingChanged)
                    )
                }
            }
            .navigationTitle("Settings")
        }
    }
}
