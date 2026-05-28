# PF Platform Policy

This project follows a latest-platform-first policy.

## Baseline

Current baseline:

```text
Swift tools: 6.3
iOS: 26.0+
macOS: 26.0+
Xcode: 26.x
```

## Rules

1. Prefer current Apple platform APIs.
2. Do not add compatibility shims for old OS versions.
3. Do not lower deployment targets for legacy device support.
4. Keep package dependencies on latest compatible versions.
5. Remove deprecated APIs when a modern replacement is available.
6. Keep tests passing on the current Xcode release.

## Dependency Policy

Use latest compatible package ranges unless a library requires a temporary exact pin.

Preferred:

```swift
.package(url: "...", from: "1.0.0")
```

Avoid:

```swift
.package(url: "...", exact: "1.0.0")
```

Only use `exact` when a dependency has a known regression or breaking behavior inside a compatible range.

## Review Checklist

Before merging platform or dependency changes:

```text
swift package update
swift test
git diff --check
```

Confirm:

1. The deployment target was not lowered.
2. No old-platform fallback code was added.
3. New APIs are available on the current baseline.
4. Commit message is English.
