# PF Design Adaptation

This document defines the first design adaptation layer for turning design files into app code.

## Scope

Design values should enter SwiftUI through shared tokens before they reach feature views.

Primary files:

```text
Sources/PFSwiftApp/Shared/Design/PFDesignSystem.swift
Sources/PFSwiftApp/Shared/UI
```

## Token Mapping

Use these token groups when translating a design file:

| Design input | App token |
| --- | --- |
| Color styles | `PFPalette` backed by SwiftGen assets |
| Text styles | `PFTypography` |
| Spacing values | `PFSpacing` |
| Corner radius | `PFRadius` |
| Fixed component sizes | `PFSize` |
| Repeated view treatment | shared `View` modifiers |

## Current Coverage

Implemented:

```text
PFSpacing
PFRadius
PFSize
PFTypography
PFPalette
pfSecondaryText
pfListButtonRow
```

Used in:

```text
App tint
Dashboard summary metadata
Tasks list rows
Messages list rows
Empty state view
```

## Gaps

These items are intentionally not finalized until real design files are available:

```text
Full typography scale names
Dark mode semantic colors beyond current asset placeholders
Button style variants
Text field styles
Card and surface treatments
Motion and transition tokens
Device-specific layout breakpoints
```

## Design Intake Order

When a design file arrives:

1. Map color styles into asset catalog tokens with `PF` names.
2. Map text styles into `PFTypography`.
3. Map spacing and radius values into `PFSpacing` and `PFRadius`.
4. Add repeated controls under `Shared/UI`.
5. Keep feature views composed from tokens and shared controls.
6. Run `swift test` after SwiftGen regenerates derived accessors.
