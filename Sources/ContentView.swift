import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameBoard(difficulty: .beginner)

    var body: some View {
        VStack(spacing: 0) {
            // Menu bar
            MenuBar(game: game)

            // Main game area with border
            VStack(spacing: 0) {
                // Header with counters and smiley
                SunkenPanel {
                    HeaderView(game: game)
                }
                .padding(6)

                // Game board
                SunkenPanel {
                    GameBoardView(game: game)
                }
                .padding(.horizontal, 6)
                .padding(.bottom, 6)
            }
            .background(ClassicColors.background)
            .overlay(
                RaisedBorder()
            )
        }
        .background(ClassicColors.background)
    }
}

struct MenuBar: View {
    @ObservedObject var game: GameBoard

    var body: some View {
        HStack(spacing: 0) {
            Menu("Game") {
                Button("New") {
                    game.resetGame()
                }
                .keyboardShortcut("n", modifiers: .command)

                Divider()

                ForEach(Difficulty.allCases, id: \.name) { difficulty in
                    Button {
                        game.changeDifficulty(difficulty)
                    } label: {
                        HStack {
                            if game.difficulty == difficulty {
                                Image(systemName: "checkmark")
                            }
                            Text(difficulty.name)
                        }
                    }
                }

                Divider()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .padding(.horizontal, 8)
            .padding(.vertical, 2)

            Spacer()
        }
        .background(ClassicColors.background)
    }
}

struct SunkenPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(ClassicColors.background)
            .overlay(
                SunkenBorder()
            )
    }
}

struct RaisedBorder: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Light top-left
            Path { path in
                path.move(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w - 3, y: 3))
                path.addLine(to: CGPoint(x: 3, y: 3))
                path.addLine(to: CGPoint(x: 3, y: h - 3))
                path.closeSubpath()
            }
            .fill(ClassicColors.lightBorder)

            // Dark bottom-right
            Path { path in
                path.move(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 3, y: h - 3))
                path.addLine(to: CGPoint(x: w - 3, y: h - 3))
                path.addLine(to: CGPoint(x: w - 3, y: 3))
                path.closeSubpath()
            }
            .fill(ClassicColors.darkBorder)
        }
        .allowsHitTesting(false)
    }
}

struct SunkenBorder: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Dark top-left
            Path { path in
                path.move(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w - 2, y: 2))
                path.addLine(to: CGPoint(x: 2, y: 2))
                path.addLine(to: CGPoint(x: 2, y: h - 2))
                path.closeSubpath()
            }
            .fill(ClassicColors.darkBorder)

            // Light bottom-right
            Path { path in
                path.move(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 2, y: h - 2))
                path.addLine(to: CGPoint(x: w - 2, y: h - 2))
                path.addLine(to: CGPoint(x: w - 2, y: 2))
                path.closeSubpath()
            }
            .fill(ClassicColors.lightBorder)
        }
        .allowsHitTesting(false)
    }
}
