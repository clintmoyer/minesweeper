import Foundation

enum CellState {
    case hidden
    case revealed
    case flagged
    case questioned
}

enum GameState {
    case ready
    case playing
    case won
    case lost
}

enum Difficulty: CaseIterable {
    case beginner
    case intermediate
    case expert

    var rows: Int {
        switch self {
        case .beginner: return 9
        case .intermediate: return 16
        case .expert: return 16
        }
    }

    var columns: Int {
        switch self {
        case .beginner: return 9
        case .intermediate: return 16
        case .expert: return 30
        }
    }

    var mines: Int {
        switch self {
        case .beginner: return 10
        case .intermediate: return 40
        case .expert: return 99
        }
    }

    var name: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .expert: return "Expert"
        }
    }
}

struct Cell: Identifiable {
    let id: Int
    let row: Int
    let column: Int
    var isMine: Bool = false
    var state: CellState = .hidden
    var adjacentMines: Int = 0
    var isTriggeredMine: Bool = false
    var isWrongFlag: Bool = false
}

class GameBoard: ObservableObject {
    @Published var cells: [[Cell]] = []
    @Published var gameState: GameState = .ready
    @Published var flagCount: Int = 0
    @Published var elapsedTime: Int = 0
    @Published var difficulty: Difficulty = .beginner

    var rows: Int { difficulty.rows }
    var columns: Int { difficulty.columns }
    var totalMines: Int { difficulty.mines }

    private var timer: Timer?
    private var firstClick: Bool = true

    init(difficulty: Difficulty = .beginner) {
        self.difficulty = difficulty
        resetGame()
    }

    func resetGame() {
        stopTimer()
        gameState = .ready
        flagCount = 0
        elapsedTime = 0
        firstClick = true
        initializeBoard()
    }

    func changeDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
        resetGame()
    }

    private func initializeBoard() {
        cells = []
        var id = 0
        for row in 0..<rows {
            var rowCells: [Cell] = []
            for col in 0..<columns {
                rowCells.append(Cell(id: id, row: row, column: col))
                id += 1
            }
            cells.append(rowCells)
        }
    }

    private func placeMines(excludeRow: Int, excludeCol: Int) {
        var minesPlaced = 0
        while minesPlaced < totalMines {
            let row = Int.random(in: 0..<rows)
            let col = Int.random(in: 0..<columns)

            // Don't place mine on first click or adjacent cells
            let isExcluded = abs(row - excludeRow) <= 1 && abs(col - excludeCol) <= 1

            if !cells[row][col].isMine && !isExcluded {
                cells[row][col].isMine = true
                minesPlaced += 1
            }
        }
        calculateAdjacentMines()
    }

    private func calculateAdjacentMines() {
        for row in 0..<rows {
            for col in 0..<columns {
                if !cells[row][col].isMine {
                    cells[row][col].adjacentMines = countAdjacentMines(row: row, col: col)
                }
            }
        }
    }

    private func countAdjacentMines(row: Int, col: Int) -> Int {
        var count = 0
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let newRow = row + dr
                let newCol = col + dc
                if isValidCell(row: newRow, col: newCol) && cells[newRow][newCol].isMine {
                    count += 1
                }
            }
        }
        return count
    }

    private func isValidCell(row: Int, col: Int) -> Bool {
        return row >= 0 && row < rows && col >= 0 && col < columns
    }

    func revealCell(row: Int, col: Int) {
        guard gameState == .ready || gameState == .playing else { return }
        guard isValidCell(row: row, col: col) else { return }
        guard cells[row][col].state == .hidden else { return }

        if firstClick {
            firstClick = false
            placeMines(excludeRow: row, excludeCol: col)
            gameState = .playing
            startTimer()
        }

        cells[row][col].state = .revealed

        if cells[row][col].isMine {
            cells[row][col].isTriggeredMine = true
            gameOver()
            return
        }

        if cells[row][col].adjacentMines == 0 {
            // Flood fill for empty cells
            for dr in -1...1 {
                for dc in -1...1 {
                    if dr == 0 && dc == 0 { continue }
                    revealCell(row: row + dr, col: col + dc)
                }
            }
        }

        checkWinCondition()
    }

    func toggleFlag(row: Int, col: Int) {
        guard gameState == .ready || gameState == .playing else { return }
        guard isValidCell(row: row, col: col) else { return }

        switch cells[row][col].state {
        case .hidden:
            cells[row][col].state = .flagged
            flagCount += 1
        case .flagged:
            cells[row][col].state = .questioned
            flagCount -= 1
        case .questioned:
            cells[row][col].state = .hidden
        case .revealed:
            break
        }
    }

    func chordCell(row: Int, col: Int) {
        guard gameState == .playing else { return }
        guard isValidCell(row: row, col: col) else { return }
        guard cells[row][col].state == .revealed else { return }
        guard cells[row][col].adjacentMines > 0 else { return }

        // Count adjacent flags
        var flagCount = 0
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let newRow = row + dr
                let newCol = col + dc
                if isValidCell(row: newRow, col: newCol) && cells[newRow][newCol].state == .flagged {
                    flagCount += 1
                }
            }
        }

        // If flags match adjacent mines, reveal all non-flagged neighbors
        if flagCount == cells[row][col].adjacentMines {
            for dr in -1...1 {
                for dc in -1...1 {
                    if dr == 0 && dc == 0 { continue }
                    let newRow = row + dr
                    let newCol = col + dc
                    if isValidCell(row: newRow, col: newCol) && cells[newRow][newCol].state == .hidden {
                        revealCell(row: newRow, col: newCol)
                    }
                }
            }
        }
    }

    private func gameOver() {
        gameState = .lost
        stopTimer()
        // Reveal all mines and mark wrong flags
        for row in 0..<rows {
            for col in 0..<columns {
                if cells[row][col].isMine && cells[row][col].state != .flagged {
                    cells[row][col].state = .revealed
                } else if !cells[row][col].isMine && cells[row][col].state == .flagged {
                    cells[row][col].isWrongFlag = true
                }
            }
        }
    }

    private func checkWinCondition() {
        var hiddenNonMines = 0
        for row in 0..<rows {
            for col in 0..<columns {
                if !cells[row][col].isMine && cells[row][col].state != .revealed {
                    hiddenNonMines += 1
                }
            }
        }

        if hiddenNonMines == 0 {
            gameState = .won
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.elapsedTime < 999 {
                self.elapsedTime += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
