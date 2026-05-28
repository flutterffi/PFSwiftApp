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
Swift language mode: 6
```

## Rules

1. Prefer current Apple platform APIs.
2. Keep package dependencies on latest compatible versions.
3. Do not raise deployment targets just because a newer OS exists.
4. Do not add compatibility shims for unsupported OS versions.
5. Remove deprecated APIs when a modern replacement is available.
6. Keep Swift 6 language mode enabled.
7. Keep tests passing on the current Xcode release.

## Swift 6 Readiness

The package declares `swiftLanguageModes: [.v6]` so new code is checked in Swift 6 mode by
default.

Guidelines:

1. Keep dependency clients, models, and async closures `Sendable`.
2. Prefer actor-isolated state for mutable shared test or preview storage.
3. Avoid `nonisolated(unsafe)` outside tightly scoped test doubles.
4. Do not silence concurrency diagnostics with unchecked conformance unless a review note explains
   the invariant.
5. Prefer structured concurrency over detached tasks or main queue dispatch.

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
4. Swift 6 diagnostics are not silenced without a documented reason.
5. Commit message is English.
