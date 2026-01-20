# Minesweeper

A faithful recreation of the classic Windows Minesweeper game for macOS, built with Swift and SwiftUI.

<img width="340" height="452" alt="Minesweeper" src="https://github.com/user-attachments/assets/7d093bfd-31ad-48b9-94bd-f36153c2189d" />

## Features

- Classic Windows Minesweeper gameplay and appearance
- Three difficulty levels:
  - Beginner: 9x9 grid, 10 mines
  - Intermediate: 16x16 grid, 40 mines
  - Expert: 30x16 grid, 99 mines
- Authentic visual style with 3D beveled cells and classic gray color scheme
- LED-style mine counter and timer displays
- Smiley face button with different expressions (normal, cool sunglasses on win, X eyes on loss)
- High score tracking with persistent storage
- First click protection (first click never hits a mine)
- Chord clicking support (middle-click or double-click on revealed numbers)
- Flag and question mark cycling (right-click)
- Wrong flag indicators and triggered mine highlight on game over

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later

## Building

```bash
swift build
```

## Running

```bash
swift run
```

Or after building:

```bash
.build/debug/Minesweeper
```

## Controls

| Action | Input |
|--------|-------|
| Reveal cell | Left click |
| Flag/Question/Unflag | Right click |
| Chord (reveal adjacent) | Middle click on number |
| New game | Click smiley face or Game > New |

## Menu Options

- **Game > New** - Start a new game
- **Game > Beginner/Intermediate/Expert** - Change difficulty
- **Game > Best Times** - View high scores
- **Game > Quit** - Exit the application

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

See [COPYING](COPYING) for details.
