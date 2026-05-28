# PF Resource Management

This document defines the team workflow for app resources, generated accessors, and placeholder replacement.

## Scope

Resources live under:

```text
Sources/PFSwiftApp/Resources
```

SwiftGen is configured in:

```text
swiftgen.yml
```

Generated files are build artifacts and must not be committed:

```text
PFAsset.swift
PFStrings.swift
PFJSON.swift
```

SwiftPM runs `SwiftGenPlugin` during build and writes generated files into derived sources.

## Resource Categories

Use these categories before adding new resource types:

| Category | Location | Generated API | Current status |
| --- | --- | --- | --- |
| App icon preview | `Assets.xcassets/PFAppIconPreview.imageset` | `PFAsset.pfAppIconPreview` | Placeholder |
| Tab icons | `Assets.xcassets/PFTab*.imageset` | `PFAsset.pfTabDashboard`, etc. | Placeholder |
| Empty state images | `Assets.xcassets/PFEmptyState.imageset` | `PFAsset.pfEmptyState` | Placeholder |
| Colors | `Assets.xcassets/PF*.colorset` | `PFAsset.pfPrimary.swiftUIColor`, etc. | Placeholder tokens |
| Strings | `en.lproj/Localizable.strings` | `PFStrings.*` | Active |
| JSON mocks | `Mock/*.json` | `PFJSON.*` | Active |
| Fonts | `Fonts/*.ttf` or `Fonts/*.otf` | Future `PFFont.*` | Not enabled yet |

## Naming Rules

All app-owned resources must use the `PF` prefix.

Use these patterns:

```text
PFAppIconPreview
PFTabDashboard
PFTabTasks
PFTabMessages
PFTabSettings
PFEmptyState
PFPrimary
PFSuccess
PFWarning
```

Do not access resources by raw strings in app code when SwiftGen provides a generated API.

Preferred:

```swift
Text(PFStrings.Tasks.Empty.title)
PFAsset.pfPrimary.swiftUIColor
PFAsset.pfEmptyState.swiftUIImage
```

Avoid:

```swift
Text("No tasks in this view.")
Color("PFPrimary")
Image("PFEmptyState")
```

## Add Or Replace Resource Order

Follow this order for every resource change:

1. Add or replace files under `Sources/PFSwiftApp/Resources`.
2. Keep the `PF` prefix and use descriptive names.
3. Update `swiftgen.yml` only when adding a new resource parser or input group.
4. Build locally with `swift test`.
5. Use generated APIs from `PFAsset`, `PFStrings`, or `PFJSON`.
6. Run `git diff --check`.
7. Review `git diff --stat` before commit.
8. Commit with an English message.
9. Tag the release with the next semantic version.

## App Icon

The current `PFAppIconPreview` is a replaceable preview image, not the final platform app icon set.

When the final brand icon is ready:

1. Add platform-specific app icon files in the Xcode app target or asset catalog expected by the release target.
2. Keep `PFAppIconPreview` for in-app preview, documentation, and debug surfaces.
3. Do not use the preview image as a release icon unless it has all required sizes.

## Tab Icons

Current tab icon placeholders:

```text
PFTabDashboard
PFTabTasks
PFTabMessages
PFTabSettings
```

When replacing them, keep the asset names stable so existing generated APIs do not change.

Tab titles are localized through:

```text
tab.dashboard
tab.tasks
tab.messages
tab.settings
```

Tab UI must use both generated accessors:

```swift
PFAsset.pfTabDashboard.swiftUIImage
Text(PFStrings.Tab.dashboard)
```

## Empty State Images

Use `PFEmptyState` for generic empty views until feature-specific artwork is introduced.

If a feature needs a dedicated empty state, use:

```text
PFTasksEmptyState
PFMessagesEmptyState
PFSettingsEmptyState
```

## Color Tokens

Current placeholder tokens:

```text
PFPrimary
PFSuccess
PFWarning
```

Add new tokens only when a repeated semantic role exists. Prefer semantic names over visual names.

Preferred:

```text
PFPrimary
PFSuccess
PFWarning
PFDanger
PFMuted
```

Avoid:

```text
PFBlue
PFGreen
PFOrange
```

## Fonts

Fonts are not enabled in `swiftgen.yml` yet because the repository does not contain a valid `.ttf` or `.otf` file.

When adding fonts:

1. Add files under `Sources/PFSwiftApp/Resources/Fonts`.
2. Confirm license and redistribution rights before commit.
3. Add the SwiftGen `fonts` parser to `swiftgen.yml`.
4. Generate `PFFont.swift`.
5. Use generated font names instead of raw strings.

Expected future config:

```yaml
fonts:
  inputs:
    - Fonts
  outputs:
    - templateName: swift5
      params:
        enumName: PFFont
      output: PFFont.swift
```

## Localized Strings

Primary source:

```text
Sources/PFSwiftApp/Resources/en.lproj/Localizable.strings
```

Rules:

1. Use lower-case dotted keys.
2. Group by feature.
3. Keep copy short and product-facing.
4. Use `PFStrings` in Swift code.

Examples:

```text
dashboard.title
tasks.empty.title
messages.empty.title
settings.notifications.alerts
```

## JSON Mock Resources

Mock JSON files live under:

```text
Sources/PFSwiftApp/Resources/Mock
```

Use JSON mocks for static sample data, previews, and future fixture loading. Keep mock files deterministic and small.

Current files:

```text
PFDashboardSummary.json
PFTabItems.json
```

Use generated `PFJSON` accessors when reading these resources.

## Review Checklist

Before merging resource changes:

```text
swift test
git diff --check
```

Confirm:

1. No raw resource string was introduced when a generated API exists.
2. Placeholder resources are named as placeholders or documented as replaceable.
3. Resource names are stable and prefixed with `PF`.
4. Generated files are not committed.
5. Commit message is English.
