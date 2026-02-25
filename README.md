# DiceFlipper

A fun, tactile iOS/iPadOS app for flipping a coin or rolling a dice. Built with SwiftUI, with satisfying haptics and animations.

## Features

- **Coin Flip** — 3D perspective flip animation, lands on heads or tails
- **Dice Roll** — Tumbling animation with a spring bounce on landing
- **Shake to flip/roll** — Shake your phone to trigger without tapping
- **Dice sides** — Pick d4, d6, d8, d10, d12, d20, or enter a custom number
- **Haptic feedback** — Heavy thud on coin landing, crisp click on dice landing
- **iPhone + iPad** — Adaptive layout works on all screen sizes

## Requirements

- iOS 16.0+
- Xcode 16+

## Project Structure

```
DiceFlipper/
├── Models/
│   └── AppState.swift          — App-wide state (mode, dice sides)
├── Views/
│   ├── CoinFlipView.swift      — Coin flip screen
│   ├── CoinFaceView.swift      — Coin visual (H/T with gradient)
│   ├── DiceRollView.swift      — Dice roll screen
│   ├── DiceFaceView.swift      — Dice visual (pips for d6, number for others)
│   ├── DiceSidePickerView.swift — Pill button row for selecting dice sides
│   ├── ModeToggleView.swift    — Coin / Dice toggle at the top
│   └── ResultDisplayView.swift — Large bold result text
├── ViewModels/
│   ├── CoinFlipViewModel.swift — Flip animation and result logic
│   └── DiceRollViewModel.swift — Roll animation and result logic
└── Utilities/
    ├── HapticManager.swift     — UIImpactFeedbackGenerator wrapper
    └── ShakeDetector.swift     — Shake gesture via UIViewControllerRepresentable
```

## Building

1. Open `DiceFlipper.xcodeproj` in Xcode
2. Select a simulator or connected device
3. Press `Cmd+R` to build and run

> Haptics only fire on a real device — use a physical iPhone or iPad to feel them.
