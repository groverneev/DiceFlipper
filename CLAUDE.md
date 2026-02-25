# DiceFlipper — Claude Context

## Project Overview
iOS/iPadOS SwiftUI app for flipping a coin or rolling a dice with haptic feedback and animations. No backend, no networking — purely local.

## Architecture

### State Management
- Uses Swift `@Observable` macro (NOT legacy `ObservableObject`/`@Published`)
- `AppState` injected via `.environment(appState)` / read with `@Environment(AppState.self)`
- ViewModels held as `@State` (not `@StateObject`) in views
- Bindings from `@Observable` objects require `@Bindable var x = x` inside `body`

### Key Files
| File | Role |
|------|------|
| `Models/AppState.swift` | `AppMode` enum, `CoinFace` enum, `@Observable AppState` |
| `ViewModels/CoinFlipViewModel.swift` | Coin flip animation logic, two-phase DispatchQueue chain |
| `ViewModels/DiceRollViewModel.swift` | Dice roll animation, spring bounce logic |
| `Utilities/HapticManager.swift` | Singleton wrapping `UIImpactFeedbackGenerator` |
| `Utilities/ShakeDetector.swift` | `UIViewControllerRepresentable` bridging `motionEnded` for shake |
| `Views/CoinFaceView.swift` | Coin visual; also defines `Color(hex:)` extension |
| `Views/DiceFaceView.swift` | d6 pip layout via `D6DotsView`; other dice show large number |

## Build Requirements
- Xcode 16+ (uses `PBXFileSystemSynchronizedRootGroup` — files auto-synced, no manual project registration needed)
- iOS 17.6 minimum deployment target
- Swift 6, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`

## Important Patterns

### Coin Animation
- Phase 1: `.easeIn(duration: 0.4)` → `rotationAngle += 900`
- Phase 2: `.easeOut(duration: 0.5)` → land at `0°` (heads) or `180°` (tails)
- `displayedFace` is derived purely from angle — NOT from `coinResult` — to avoid face-flip bug on result update

### Dice Animation
- Phase 1: `.easeIn(duration: 0.35)` → `rotationDegrees += 1080`, `scale = 1.15`
- Phase 2: `.spring(response: 0.45, dampingFraction: 0.45)` → `+45°`, `scale = 1.0`

### Haptics
- `.heavy` for coin landing, `.medium` for dice landing
- Call `prepare()` at tap, `impact()` at animation end

## Maintenance Note
After making any change that would be useful for future Claude sessions to know about — new patterns, architectural decisions, bug fixes with non-obvious causes, or added features — update this file to reflect it. Update the README.md if you feel it is necessary.
