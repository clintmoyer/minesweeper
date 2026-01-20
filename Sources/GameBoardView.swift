import SwiftUI
import AppKit

struct GameBoardView: View {
    @ObservedObject var game: GameBoard
    let cellSize: CGFloat = 24

    var body: some View {
        ClickableBoard(game: game, cellSize: cellSize)
            .frame(width: CGFloat(game.columns) * cellSize,
                   height: CGFloat(game.rows) * cellSize)
    }
}

struct ClickableBoard: NSViewRepresentable {
    @ObservedObject var game: GameBoard
    let cellSize: CGFloat

    func makeNSView(context: Context) -> BoardNSView {
        let view = BoardNSView()
        view.game = game
        view.cellSize = cellSize
        return view
    }

    func updateNSView(_ nsView: BoardNSView, context: Context) {
        nsView.game = game
        nsView.cellSize = cellSize
        nsView.needsDisplay = true
    }
}

class BoardNSView: NSView {
    var game: GameBoard!
    var cellSize: CGFloat = 24
    var pressedCell: (row: Int, col: Int)? = nil

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        // Colors
        let bgColor = NSColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        let lightColor = NSColor.white
        let darkColor = NSColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)

        let numberColors: [Int: NSColor] = [
            1: NSColor(red: 0, green: 0, blue: 1, alpha: 1),
            2: NSColor(red: 0, green: 0.5, blue: 0, alpha: 1),
            3: NSColor(red: 1, green: 0, blue: 0, alpha: 1),
            4: NSColor(red: 0, green: 0, blue: 0.5, alpha: 1),
            5: NSColor(red: 0.5, green: 0, blue: 0, alpha: 1),
            6: NSColor(red: 0, green: 0.5, blue: 0.5, alpha: 1),
            7: NSColor.black,
            8: NSColor.gray
        ]

        for row in 0..<game.rows {
            for col in 0..<game.columns {
                let cell = game.cells[row][col]
                let x = CGFloat(col) * cellSize
                let y = CGFloat(game.rows - 1 - row) * cellSize  // Flip Y for NSView

                let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)

                if cell.state == .revealed {
                    // Revealed cell - flat with border
                    bgColor.setFill()
                    context.fill(rect)

                    darkColor.setStroke()
                    context.stroke(rect, width: 1)

                    if cell.isMine {
                        // Draw mine with red background only for triggered mine
                        if cell.isTriggeredMine {
                            NSColor.red.setFill()
                            context.fill(rect)
                        }
                        drawMine(in: context, at: rect)
                    } else if cell.adjacentMines > 0 {
                        // Draw number
                        let number = "\(cell.adjacentMines)"
                        let color = numberColors[cell.adjacentMines] ?? NSColor.black
                        let font = NSFont.monospacedSystemFont(ofSize: 16, weight: .bold)
                        let attrs: [NSAttributedString.Key: Any] = [
                            .font: font,
                            .foregroundColor: color
                        ]
                        let str = NSAttributedString(string: number, attributes: attrs)
                        let textSize = str.size()
                        let textRect = CGRect(
                            x: x + (cellSize - textSize.width) / 2,
                            y: y + (cellSize - textSize.height) / 2,
                            width: textSize.width,
                            height: textSize.height
                        )
                        str.draw(in: textRect)
                    }
                } else {
                    // Hidden cell - 3D raised button
                    let isPressed = pressedCell?.row == row && pressedCell?.col == col

                    if isPressed {
                        // Pressed appearance
                        bgColor.setFill()
                        context.fill(rect)
                        darkColor.setStroke()
                        context.stroke(rect, width: 1)
                    } else {
                        // Normal raised button
                        bgColor.setFill()
                        context.fill(rect)

                        let borderWidth: CGFloat = 3

                        // Light border (top-left)
                        lightColor.setFill()
                        let lightPath = CGMutablePath()
                        lightPath.move(to: CGPoint(x: x, y: y))
                        lightPath.addLine(to: CGPoint(x: x, y: y + cellSize))
                        lightPath.addLine(to: CGPoint(x: x + cellSize, y: y + cellSize))
                        lightPath.addLine(to: CGPoint(x: x + cellSize - borderWidth, y: y + cellSize - borderWidth))
                        lightPath.addLine(to: CGPoint(x: x + borderWidth, y: y + cellSize - borderWidth))
                        lightPath.addLine(to: CGPoint(x: x + borderWidth, y: y + borderWidth))
                        lightPath.closeSubpath()
                        context.addPath(lightPath)
                        context.fillPath()

                        // Dark border (bottom-right)
                        darkColor.setFill()
                        let darkPath = CGMutablePath()
                        darkPath.move(to: CGPoint(x: x + cellSize, y: y + cellSize))
                        darkPath.addLine(to: CGPoint(x: x + cellSize, y: y))
                        darkPath.addLine(to: CGPoint(x: x, y: y))
                        darkPath.addLine(to: CGPoint(x: x + borderWidth, y: y + borderWidth))
                        darkPath.addLine(to: CGPoint(x: x + cellSize - borderWidth, y: y + borderWidth))
                        darkPath.addLine(to: CGPoint(x: x + cellSize - borderWidth, y: y + cellSize - borderWidth))
                        darkPath.closeSubpath()
                        context.addPath(darkPath)
                        context.fillPath()
                    }

                    // Draw flag or question mark
                    if cell.state == .flagged {
                        drawFlag(in: context, at: rect)
                        if cell.isWrongFlag {
                            drawWrongMark(in: context, at: rect)
                        }
                    } else if cell.state == .questioned {
                        let str = NSAttributedString(
                            string: "?",
                            attributes: [
                                .font: NSFont.boldSystemFont(ofSize: 16),
                                .foregroundColor: NSColor.black
                            ]
                        )
                        let textSize = str.size()
                        let textRect = CGRect(
                            x: x + (cellSize - textSize.width) / 2,
                            y: y + (cellSize - textSize.height) / 2,
                            width: textSize.width,
                            height: textSize.height
                        )
                        str.draw(in: textRect)
                    }
                }
            }
        }
    }

    private func drawMine(in context: CGContext, at rect: CGRect) {
        let centerX = rect.midX
        let centerY = rect.midY
        let scale = rect.width / 16.0
        let radius: CGFloat = 4 * scale

        // Mine body
        context.setFillColor(NSColor.black.cgColor)
        context.fillEllipse(in: CGRect(x: centerX - radius, y: centerY - radius,
                                        width: radius * 2, height: radius * 2))

        // Spikes
        context.setStrokeColor(NSColor.black.cgColor)
        context.setLineWidth(2 * scale)

        let spikeLength = 6 * scale
        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 4
            let x1 = centerX + cos(angle) * spikeLength
            let y1 = centerY + sin(angle) * spikeLength
            let x2 = centerX - cos(angle) * spikeLength
            let y2 = centerY - sin(angle) * spikeLength
            context.move(to: CGPoint(x: x1, y: y1))
            context.addLine(to: CGPoint(x: x2, y: y2))
        }
        context.strokePath()

        // Shine
        context.setFillColor(NSColor.white.cgColor)
        let shineSize = 2 * scale
        context.fillEllipse(in: CGRect(x: centerX - shineSize, y: centerY + scale, width: shineSize, height: shineSize))
    }

    private func drawFlag(in context: CGContext, at rect: CGRect) {
        let x = rect.minX
        let y = rect.minY
        let scale = rect.width / 16.0

        // Pole
        context.setStrokeColor(NSColor.black.cgColor)
        context.setLineWidth(1 * scale)
        context.move(to: CGPoint(x: x + 9 * scale, y: y + 3 * scale))
        context.addLine(to: CGPoint(x: x + 9 * scale, y: y + 13 * scale))
        context.strokePath()

        // Flag
        context.setFillColor(NSColor.red.cgColor)
        let flagPath = CGMutablePath()
        flagPath.move(to: CGPoint(x: x + 4 * scale, y: y + 13 * scale))
        flagPath.addLine(to: CGPoint(x: x + 9 * scale, y: y + 10 * scale))
        flagPath.addLine(to: CGPoint(x: x + 4 * scale, y: y + 7 * scale))
        flagPath.closeSubpath()
        context.addPath(flagPath)
        context.fillPath()

        // Base
        context.setStrokeColor(NSColor.black.cgColor)
        context.setLineWidth(2 * scale)
        context.move(to: CGPoint(x: x + 5 * scale, y: y + 3 * scale))
        context.addLine(to: CGPoint(x: x + 12 * scale, y: y + 3 * scale))
        context.strokePath()
    }

    private func drawWrongMark(in context: CGContext, at rect: CGRect) {
        // Draw X over wrong flag
        let scale = rect.width / 16.0
        let inset = 3 * scale
        context.setStrokeColor(NSColor.red.cgColor)
        context.setLineWidth(2 * scale)
        context.move(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset))
        context.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        context.move(to: CGPoint(x: rect.maxX - inset, y: rect.minY + inset))
        context.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset))
        context.strokePath()
    }

    private func cellAt(point: NSPoint) -> (row: Int, col: Int)? {
        let col = Int(point.x / cellSize)
        let row = game.rows - 1 - Int(point.y / cellSize)  // Flip Y

        guard row >= 0 && row < game.rows && col >= 0 && col < game.columns else {
            return nil
        }
        return (row, col)
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if let cell = cellAt(point: point) {
            pressedCell = cell
            needsDisplay = true
        }
    }

    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if let cell = cellAt(point: point), let pressed = pressedCell,
           cell.row == pressed.row && cell.col == pressed.col {
            game.revealCell(row: cell.row, col: cell.col)
        }
        pressedCell = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let newCell = cellAt(point: point)

        if let pressed = pressedCell {
            if newCell?.row != pressed.row || newCell?.col != pressed.col {
                pressedCell = nil
                needsDisplay = true
            }
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if let cell = cellAt(point: point) {
            game.toggleFlag(row: cell.row, col: cell.col)
            needsDisplay = true
        }
    }

    override func otherMouseUp(with event: NSEvent) {
        // Middle click for chord
        let point = convert(event.locationInWindow, from: nil)
        if let cell = cellAt(point: point) {
            game.chordCell(row: cell.row, col: cell.col)
            needsDisplay = true
        }
    }
}
