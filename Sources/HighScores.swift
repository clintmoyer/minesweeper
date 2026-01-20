import Foundation

struct HighScoreEntry: Codable, Equatable {
    var name: String
    var time: Int
}

class HighScores: ObservableObject {
    @Published var scores: [String: HighScoreEntry] = [:]

    private let defaultName = "Anonymous"
    private let defaultTime = 999
    private let storageKey = "MinesweeperHighScores"

    init() {
        load()
    }

    func getScore(for difficulty: Difficulty) -> HighScoreEntry {
        return scores[difficulty.name] ?? HighScoreEntry(name: defaultName, time: defaultTime)
    }

    func isHighScore(difficulty: Difficulty, time: Int) -> Bool {
        let current = getScore(for: difficulty)
        return time < current.time
    }

    func setScore(for difficulty: Difficulty, name: String, time: Int) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? defaultName : trimmedName
        scores[difficulty.name] = HighScoreEntry(name: finalName, time: time)
        save()
    }

    func reset() {
        scores = [:]
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: HighScoreEntry].self, from: data) {
            scores = decoded
        }
    }
}
