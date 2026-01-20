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
        let faceSize: CGFloat = 26
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
                // Eyes
                Circle()
                    .fill(Color.black)
                    .frame(width: 3, height: 3)
                    .offset(x: -5, y: -4)

                Circle()
                    .fill(Color.black)
                    .frame(width: 3, height: 3)
                    .offset(x: 5, y: -4)

                // Smile - use a simple arc shape
                SmileArc(startAngle: .degrees(20), endAngle: .degrees(160))
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 14, height: 14)
                    .offset(y: 2)

            case .won:
                // Sunglasses
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 7, height: 3)
                    .offset(x: -5, y: -4)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 7, height: 3)
                    .offset(x: 5, y: -4)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 4, height: 1.5)
                    .offset(x: 0, y: -4)

                // Smile
                SmileArc(startAngle: .degrees(20), endAngle: .degrees(160))
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 14, height: 14)
                    .offset(y: 2)

            case .lost:
                // X eyes
                XShape()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 5, height: 5)
                    .offset(x: -5, y: -4)

                XShape()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 5, height: 5)
                    .offset(x: 5, y: -4)

                // Frown
                SmileArc(startAngle: .degrees(200), endAngle: .degrees(340))
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 10, height: 10)
                    .offset(y: 6)
            }
        }
    }
}

// Custom shape for smile arc
struct SmileArc: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

// Custom shape for X
struct XShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
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
