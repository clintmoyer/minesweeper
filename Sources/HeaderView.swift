import SwiftUI

struct LEDDigit: View {
    let digit: Character

    var body: some View {
        Text(String(digit))
            .font(.system(size: 28, weight: .bold, design: .monospaced))
            .foregroundColor(Color.red)
            .frame(width: 18, height: 32)
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
        .padding(.horizontal, 3)
        .padding(.vertical, 3)
        .background(Color.black)
        .border(Color(red: 128/255, green: 128/255, blue: 128/255), width: 1)
    }
}

struct SmileyButton: View {
    let gameState: GameState
    let action: () -> Void
    let size: CGFloat = 36

    var body: some View {
        Button(action: action) {
            ZStack {
                // 3D raised button
                RoundedRectangle(cornerRadius: 0)
                    .fill(ClassicColors.background)
                    .frame(width: size, height: size)

                // Top-left highlight
                Path { path in
                    path.move(to: CGPoint(x: 0, y: size))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: size, y: 0))
                    path.addLine(to: CGPoint(x: size - 3, y: 3))
                    path.addLine(to: CGPoint(x: 3, y: 3))
                    path.addLine(to: CGPoint(x: 3, y: size - 3))
                    path.closeSubpath()
                }
                .fill(ClassicColors.lightBorder)

                // Bottom-right shadow
                Path { path in
                    path.move(to: CGPoint(x: size, y: 0))
                    path.addLine(to: CGPoint(x: size, y: size))
                    path.addLine(to: CGPoint(x: 0, y: size))
                    path.addLine(to: CGPoint(x: 3, y: size - 3))
                    path.addLine(to: CGPoint(x: size - 3, y: size - 3))
                    path.addLine(to: CGPoint(x: size - 3, y: 3))
                    path.closeSubpath()
                }
                .fill(ClassicColors.darkBorder)

                // Smiley face
                smileyFace
            }
        }
        .buttonStyle(.plain)
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var smileyFace: some View {
        let faceSize: CGFloat = 28
        ZStack {
            // Yellow face
            Circle()
                .fill(Color.yellow)
                .frame(width: faceSize, height: faceSize)

            Circle()
                .stroke(Color.black, lineWidth: 1.5)
                .frame(width: faceSize, height: faceSize)

            switch gameState {
            case .ready, .playing:
                // Normal smiley - Eyes
                Circle()
                    .fill(Color.black)
                    .frame(width: 3, height: 3)
                    .offset(x: -5, y: -4)

                Circle()
                    .fill(Color.black)
                    .frame(width: 3, height: 3)
                    .offset(x: 5, y: -4)

                // Smile
                Path { path in
                    path.addArc(center: CGPoint(x: size/2, y: size/2 + 2),
                               radius: 7,
                               startAngle: .degrees(30),
                               endAngle: .degrees(150),
                               clockwise: true)
                }
                .stroke(Color.black, lineWidth: 1.5)

            case .won:
                // Sunglasses cool face
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 8, height: 4)
                    .offset(x: -5, y: -4)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 8, height: 4)
                    .offset(x: 5, y: -4)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 6, height: 1.5)
                    .offset(x: 0, y: -4)

                // Smile
                Path { path in
                    path.addArc(center: CGPoint(x: size/2, y: size/2 + 2),
                               radius: 7,
                               startAngle: .degrees(30),
                               endAngle: .degrees(150),
                               clockwise: true)
                }
                .stroke(Color.black, lineWidth: 1.5)

            case .lost:
                // Dead face X eyes
                Path { path in
                    path.move(to: CGPoint(x: size/2 - 8, y: size/2 - 7))
                    path.addLine(to: CGPoint(x: size/2 - 2, y: size/2 - 1))
                    path.move(to: CGPoint(x: size/2 - 2, y: size/2 - 7))
                    path.addLine(to: CGPoint(x: size/2 - 8, y: size/2 - 1))
                }
                .stroke(Color.black, lineWidth: 1.5)

                Path { path in
                    path.move(to: CGPoint(x: size/2 + 2, y: size/2 - 7))
                    path.addLine(to: CGPoint(x: size/2 + 8, y: size/2 - 1))
                    path.move(to: CGPoint(x: size/2 + 8, y: size/2 - 7))
                    path.addLine(to: CGPoint(x: size/2 + 2, y: size/2 - 1))
                }
                .stroke(Color.black, lineWidth: 1.5)

                // Frown
                Path { path in
                    path.addArc(center: CGPoint(x: size/2, y: size/2 + 10),
                               radius: 5,
                               startAngle: .degrees(210),
                               endAngle: .degrees(330),
                               clockwise: false)
                }
                .stroke(Color.black, lineWidth: 1.5)
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
        .padding(8)
        .background(ClassicColors.background)
    }
}
