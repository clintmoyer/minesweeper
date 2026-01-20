import SwiftUI

struct LEDDigit: View {
    let digit: Character

    var body: some View {
        Text(String(digit))
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(Color.red)
            .frame(width: 13, height: 23)
    }
}

struct LEDDisplay: View {
    let value: Int

    var body: some View {
        let displayValue = max(-99, min(999, value))
        let text = String(format: "%03d", abs(displayValue))
        let prefix = displayValue < 0 ? "-" : ""
        let displayText = displayValue < 0 ? prefix + String(text.dropFirst()) : text

        HStack(spacing: 0) {
            ForEach(Array(displayText.enumerated()), id: \.offset) { _, char in
                LEDDigit(digit: char)
            }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
        .background(Color.black)
        .border(Color(red: 128/255, green: 128/255, blue: 128/255), width: 1)
    }
}

struct SmileyButton: View {
    let gameState: GameState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // 3D raised button
                RoundedRectangle(cornerRadius: 0)
                    .fill(ClassicColors.background)
                    .frame(width: 26, height: 26)

                // Top-left highlight
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 26))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 26, y: 0))
                    path.addLine(to: CGPoint(x: 24, y: 2))
                    path.addLine(to: CGPoint(x: 2, y: 2))
                    path.addLine(to: CGPoint(x: 2, y: 24))
                    path.closeSubpath()
                }
                .fill(ClassicColors.lightBorder)

                // Bottom-right shadow
                Path { path in
                    path.move(to: CGPoint(x: 26, y: 0))
                    path.addLine(to: CGPoint(x: 26, y: 26))
                    path.addLine(to: CGPoint(x: 0, y: 26))
                    path.addLine(to: CGPoint(x: 2, y: 24))
                    path.addLine(to: CGPoint(x: 24, y: 24))
                    path.addLine(to: CGPoint(x: 24, y: 2))
                    path.closeSubpath()
                }
                .fill(ClassicColors.darkBorder)

                // Smiley face
                smileyFace
            }
        }
        .buttonStyle(.plain)
        .frame(width: 26, height: 26)
    }

    @ViewBuilder
    private var smileyFace: some View {
        ZStack {
            // Yellow face
            Circle()
                .fill(Color.yellow)
                .frame(width: 20, height: 20)

            Circle()
                .stroke(Color.black, lineWidth: 1)
                .frame(width: 20, height: 20)

            switch gameState {
            case .ready, .playing:
                // Normal smiley
                // Eyes
                Circle()
                    .fill(Color.black)
                    .frame(width: 2, height: 2)
                    .offset(x: -4, y: -3)

                Circle()
                    .fill(Color.black)
                    .frame(width: 2, height: 2)
                    .offset(x: 4, y: -3)

                // Smile
                Path { path in
                    path.addArc(center: CGPoint(x: 13, y: 11),
                               radius: 5,
                               startAngle: .degrees(30),
                               endAngle: .degrees(150),
                               clockwise: true)
                }
                .stroke(Color.black, lineWidth: 1)

            case .won:
                // Sunglasses cool face
                // Sunglasses
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 6, height: 3)
                    .offset(x: -4, y: -3)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 6, height: 3)
                    .offset(x: 4, y: -3)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 4, height: 1)
                    .offset(x: 0, y: -3)

                // Smile
                Path { path in
                    path.addArc(center: CGPoint(x: 13, y: 11),
                               radius: 5,
                               startAngle: .degrees(30),
                               endAngle: .degrees(150),
                               clockwise: true)
                }
                .stroke(Color.black, lineWidth: 1)

            case .lost:
                // Dead face X eyes
                Path { path in
                    path.move(to: CGPoint(x: 7, y: 6))
                    path.addLine(to: CGPoint(x: 11, y: 10))
                    path.move(to: CGPoint(x: 11, y: 6))
                    path.addLine(to: CGPoint(x: 7, y: 10))
                }
                .stroke(Color.black, lineWidth: 1)

                Path { path in
                    path.move(to: CGPoint(x: 15, y: 6))
                    path.addLine(to: CGPoint(x: 19, y: 10))
                    path.move(to: CGPoint(x: 19, y: 6))
                    path.addLine(to: CGPoint(x: 15, y: 10))
                }
                .stroke(Color.black, lineWidth: 1)

                // Frown
                Path { path in
                    path.addArc(center: CGPoint(x: 13, y: 17),
                               radius: 4,
                               startAngle: .degrees(210),
                               endAngle: .degrees(330),
                               clockwise: false)
                }
                .stroke(Color.black, lineWidth: 1)
            }
        }
    }
}

struct HeaderView: View {
    @ObservedObject var game: GameBoard

    var remainingMines: Int {
        game.totalMines - game.flagCount
    }

    var body: some View {
        HStack {
            LEDDisplay(value: remainingMines)

            Spacer()

            SmileyButton(gameState: game.gameState) {
                game.resetGame()
            }

            Spacer()

            LEDDisplay(value: game.elapsedTime)
        }
        .padding(5)
        .background(ClassicColors.background)
    }
}
