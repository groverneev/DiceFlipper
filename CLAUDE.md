# DiceFlipper — Claude Context

## Project Overview
iOS/iPadOS SwiftUI app for flipping a coin or rolling a dice with haptic feedback and animations. No backend, no networking — purely local.

## Architecture

### State Management
- Uses Swift `@Observable` macro (NOT legacy `ObservableObject`/`@Published`)
- `AppState` injected via `.environment(appState)` / read with `@Environment(AppState.self)`
- ViewModels held as `@State` (not `@StateObject`) in views
- Bindings from `@Observable` objects require `@Bindable var x = x` inside `body`

### File Locations — IMPORTANT
The Xcode project lives at `DiceFlipper/DiceFlipper/` (double-nested). **Always edit files under:**
```
DiceFlipper/DiceFlipper/Models/
DiceFlipper/DiceFlipper/Views/
DiceFlipper/DiceFlipper/ViewModels/
DiceFlipper/DiceFlipper/Utilities/
```
There is a stale sibling copy at `DiceFlipper/` (single-nested) — **do not edit those files**, they are not compiled by Xcode.

### Key Files
| File | Role |
|------|------|
| `Models/AppState.swift` | `AppMode` enum, `CoinFace` enum, `@Observable AppState` |
| `ViewModels/CoinFlipViewModel.swift` | Coin flip animation logic, two-phase DispatchQueue chain |
| `ViewModels/DiceRollViewModel.swift` | Dice roll animation, 3D spring bounce logic |
| `Utilities/HapticManager.swift` | Singleton wrapping `UIImpactFeedbackGenerator` |
| `Utilities/ShakeDetector.swift` | `UIViewControllerRepresentable` bridging `motionEnded` for shake |
| `Views/CoinFaceView.swift` | Coin visual; also defines `Color(hex:)` extension |
| `Views/DiceFaceView.swift` | Per-die polygon shapes + d6 pip layout via `D6DotsView` |

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
3D tumble using two stacked `rotation3DEffect` modifiers (Y-axis spin + X-axis tilt):
- Phase 1: `.easeIn(duration: 0.35)` → `yRotation += 740` (2 spins + 20° overshoot), `xRotation += 360`, `scale = 1.15`
- Phase 2: `.spring(response: 0.45, dampingFraction: 0.45)` → `yRotation -= 20` (spring corrects overshoot back to face-up), `scale = 1.0`
- Die always lands face-up (yRotation and xRotation are always multiples of 360° at rest)

### Dice Shapes
Each standard die renders its real polygon shape via `RegularPolygon` (a custom `Shape`):
- d4: triangle up (orange), d6: rounded square with pips (purple), d8: diamond (blue)
- d10: pentagon down (teal), d12: pentagon up (green), d20: triangle down (indigo)
- Custom (non-standard): glowing circle/orb (gray) — no physical shape equivalent

### Haptics
- `.heavy` for coin landing, `.medium` for dice landing
- Call `prepare()` at tap, `impact()` at animation end

## Maintenance Note
After making any change that would be useful for future Claude sessions to know about — new patterns, architectural decisions, bug fixes with non-obvious causes, or added features — update this file to reflect it. Update the README.md if you feel it is necessary.
