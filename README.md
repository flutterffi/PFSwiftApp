# PFSwiftApp

PFSwiftApp is a SwiftUI application baseline built around The Composable Architecture.

## Architecture

- `PFAppFeature` owns the root state, root actions, and four tab scopes.
- `PFDashboardFeature` provides the dashboard shell.
- `PFTasksFeature` is the first complete feature and supports add, toggle, delete, and clear-completed flows.
- `PFMessagesFeature` provides the messages shell.
- `PFSettingsFeature` provides settings state and toggles.

All app-level types use the `PF` prefix.

## Resources

Resource workflow, SwiftGen usage, naming rules, and replacement order are documented in [PFResourceManagement.md](Docs/PFResourceManagement.md).
