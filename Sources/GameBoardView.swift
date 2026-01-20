import SwiftUI

struct GameBoardView: View {
    @ObservedObject var game: GameBoard
    let cellSize: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<game.rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<game.columns, id: \.self) { col in
                        CellView(cell: game.cells[row][col], gameState: game.gameState)
                            .onTapGesture {
                                game.revealCell(row: row, col: col)
                            }
                            .simultaneousGesture(
                                TapGesture(count: 2).onEnded {
                                    game.chordCell(row: row, col: col)
                                }
                            )
                            .contextMenu {
                                Button(game.cells[row][col].state == .flagged ? "Remove Flag" : "Flag") {
                                    game.toggleFlag(row: row, col: col)
                                }
                            }
                            .onLongPressGesture(minimumDuration: 0.2) {
                                game.toggleFlag(row: row, col: col)
                            }
                    }
                }
            }
        }
    }
}
