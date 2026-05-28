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
            .overlay {
                if store.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "Settings Error",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            store.send(.settingsErrorDismissed)
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.errorMessage ?? "")
            }
            .task {
                await store.send(.task).finish()
            }
        }
    }
}
