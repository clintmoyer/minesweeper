import SwiftUI

struct ClassicColors {
    // Windows classic gray color scheme
    static let background = Color(red: 192/255, green: 192/255, blue: 192/255)
    static let lightBorder = Color.white
    static let darkBorder = Color(red: 128/255, green: 128/255, blue: 128/255)
    static let darkerBorder = Color(red: 64/255, green: 64/255, blue: 64/255)

    // Number colors matching Windows Minesweeper
    static func numberColor(_ number: Int) -> Color {
        switch number {
        case 1: return Color(red: 0, green: 0, blue: 1)           // Blue
        case 2: return Color(red: 0, green: 0.5, blue: 0)         // Green
        case 3: return Color(red: 1, green: 0, blue: 0)           // Red
        case 4: return Color(red: 0, green: 0, blue: 0.5)         // Dark blue
        case 5: return Color(red: 0.5, green: 0, blue: 0)         // Dark red (maroon)
        case 6: return Color(red: 0, green: 0.5, blue: 0.5)       // Cyan/Teal
        case 7: return Color.black                                 // Black
        case 8: return Color.gray                                  // Gray
        default: return Color.black
        }
    }
}

struct CellView: View {
    let cell: Cell
    let gameState: GameState
    let cellSize: CGFloat = 16

    var body: some View {
        ZStack {
            if cell.state == .revealed {
                revealedCell
            } else {
                hiddenCell
            }
        }
        .frame(width: cellSize, height: cellSize)
    }

    private var hiddenCell: some View {
        ZStack {
            // 3D raised button look
            Rectangle()
                .fill(ClassicColors.background)

            // Top and left light border
            Path { path in
                path.move(to: CGPoint(x: 0, y: cellSize))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cellSize, y: 0))
                path.addLine(to: CGPoint(x: cellSize - 2, y: 2))
                path.addLine(to: CGPoint(x: 2, y: 2))
                path.addLine(to: CGPoint(x: 2, y: cellSize - 2))
                path.closeSubpath()
            }
            .fill(ClassicColors.lightBorder)

            // Bottom and right dark border
            Path { path in
                path.move(to: CGPoint(x: cellSize, y: 0))
                path.addLine(to: CGPoint(x: cellSize, y: cellSize))
                path.addLine(to: CGPoint(x: 0, y: cellSize))
                path.addLine(to: CGPoint(x: 2, y: cellSize - 2))
                path.addLine(to: CGPoint(x: cellSize - 2, y: cellSize - 2))
                path.addLine(to: CGPoint(x: cellSize - 2, y: 2))
                path.closeSubpath()
            }
            .fill(ClassicColors.darkBorder)

            // Flag or question mark
            if cell.state == .flagged {
                flagIcon
            } else if cell.state == .questioned {
                Text("?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }

    private var revealedCell: some View {
        ZStack {
            Rectangle()
                .fill(ClassicColors.background)

            // Sunken border for revealed cells
            Rectangle()
                .stroke(ClassicColors.darkBorder, lineWidth: 1)

            if cell.isMine {
                mineIcon
            } else if cell.adjacentMines > 0 {
                Text("\(cell.adjacentMines)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(ClassicColors.numberColor(cell.adjacentMines))
            }
        }
    }

    private var flagIcon: some View {
        ZStack {
            // Flag pole
            Path { path in
                path.move(to: CGPoint(x: 9, y: 3))
                path.addLine(to: CGPoint(x: 9, y: 12))
            }
            .stroke(Color.black, lineWidth: 1)

            // Flag
            Path { path in
                path.move(to: CGPoint(x: 4, y: 3))
                path.addLine(to: CGPoint(x: 9, y: 5))
                path.addLine(to: CGPoint(x: 4, y: 7))
                path.closeSubpath()
            }
            .fill(Color.red)

            // Base
            Path { path in
                path.move(to: CGPoint(x: 5, y: 12))
                path.addLine(to: CGPoint(x: 12, y: 12))
            }
            .stroke(Color.black, lineWidth: 2)
        }
    }

    private var mineIcon: some View {
        ZStack {
            // Red background if this was the clicked mine
            if gameState == .lost {
                Rectangle()
                    .fill(Color.red)
            }

            // Mine body
            Circle()
                .fill(Color.black)
                .frame(width: 8, height: 8)

            // Spikes
            ForEach(0..<4) { i in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 2, height: 10)
                    .rotationEffect(.degrees(Double(i) * 45))
            }

            // Shine
            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
                .offset(x: -1, y: -1)
        }
    }
}
