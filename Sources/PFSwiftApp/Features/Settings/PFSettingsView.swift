import ComposableArchitecture
import SwiftUI

struct PFSettingsView: View {
    let store: StoreOf<PFSettingsFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Form {
                    Section("Telemetry") {
                        Toggle(
                            "Analytics",
                            isOn: viewStore.binding(
                                get: \.isAnalyticsEnabled,
                                send: PFSettingsFeature.Action.analyticsChanged
                            )
                        )
                        Toggle(
                            "Crash Reporting",
                            isOn: viewStore.binding(
                                get: \.isCrashReportingEnabled,
                                send: PFSettingsFeature.Action.crashReportingChanged
                            )
                        )
                    }
                }
                .navigationTitle("Settings")
            }
        }
    }
}
