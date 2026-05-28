import ComposableArchitecture
import SwiftUI

struct PFDashboardView: View {
    let store: StoreOf<PFDashboardFeature>

    var body: some View {
        NavigationStack {
            List {
                Section("Tasks") {
                    ForEach(store.taskSummaryItems) { item in
                        PFDashboardSummaryRow(item: item)
                    }
                }

                Section("Messages") {
                    ForEach(store.messageSummaryItems) { item in
                        PFDashboardSummaryRow(item: item)
                    }
                }

                Section("System") {
                    ForEach(store.systemSummaryItems) { item in
                        PFDashboardSummaryRow(item: item)
                    }
                }
            }
            .navigationTitle(store.title)
        }
    }
}

private struct PFDashboardSummaryRow: View {
    let item: PFDashboardSummary

    var body: some View {
        HStack {
            Text(item.title)
            Spacer()
            Text(item.value)
                .foregroundStyle(.secondary)
        }
    }
}
