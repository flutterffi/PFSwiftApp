# PF Modern API Audit

This document records the latest deprecated API audit for the current platform baseline.

## Baseline

```text
Swift tools: 6.3
iOS: 26.0+
macOS: 26.0+
Xcode: 26.5
Swift: 6.3.2
```

## Audit Commands

Use these commands before introducing platform or dependency changes:

```text
swift test
rg -n "NavigationView|presentationMode|UIApplication|UIScreen|Image\\(\"|Color\\(\"|@available|deprecated|exact:" Sources Tests Package.swift swiftgen.yml Docs README.md SwiftGenTemplates
```

## Current Result

The current codebase has no compiler deprecation warnings under Swift 6.3.2.

No deprecated SwiftUI navigation APIs were found:

```text
NavigationView
presentationMode
```

No raw generated resource access was found in app code:

```text
Image("...")
Color("...")
```

No exact package pins remain in `Package.swift`.

## Accepted Findings

The documentation intentionally contains examples of disallowed raw resource access:

```swift
Text("No tasks in this view.")
Color("PFPrimary")
Image("PFEmptyState")
```

These examples are kept in `PFResourceManagement.md` to show what reviewers should reject.

Tests may use Foundation primitives such as `URL(string:)` and `JSONSerialization` where they are verifying networking behavior or request payload shape.

## Review Rules

1. Prefer `NavigationStack` over `NavigationView`.
2. Prefer generated `PFAsset` and `PFStrings` accessors over raw resource strings.
3. Prefer latest-compatible package ranges over exact pins.
4. Do not add old-platform availability fallbacks.
5. Treat compiler deprecation warnings as failures unless a short migration note is added here.
