# PF Platform And Dependency Policy

This project follows a latest-dependency-first policy. Keep third-party libraries current while
choosing deployment targets from product requirements, not from the newest OS release.

## Baseline

Current baseline:

```text
Swift tools: 6.3
iOS: 18.0+
macOS: 15.0+
Xcode: 26.x
```

## Rules

1. Prefer current Apple platform APIs.
2. Keep package dependencies on latest compatible versions.
3. Do not raise deployment targets just because a newer OS exists.
4. Do not add compatibility shims for unsupported OS versions.
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

1. Direct dependencies resolve to the latest compatible versions.
2. Deployment target changes have product or library requirements.
3. New APIs are available on the current baseline.
4. Commit message is English.
