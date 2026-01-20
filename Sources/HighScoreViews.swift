import SwiftUI

struct HighScoreEntryDialog: View {
    let difficulty: Difficulty
    let time: Int
    let onSubmit: (String) -> Void

    @State private var playerName: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("New High Score!")
                .font(.headline)

            Text("You completed \(difficulty.name) in \(time) seconds!")
                .font(.subheadline)

            TextField("Enter your name", text: $playerName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
                .onSubmit {
                    submit()
                }

            HStack(spacing: 12) {
                Button("OK") {
                    submit()
                }
                .keyboardShortcut(.defaultAction)

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding(24)
        .background(ClassicColors.background)
    }

    private func submit() {
        onSubmit(playerName)
        dismiss()
    }
}

struct HighScoreRow: View {
    let difficulty: Difficulty
    let entry: HighScoreEntry?

    private var score: HighScoreEntry {
        entry ?? HighScoreEntry(name: "Anonymous", time: 999)
    }

    var body: some View {
        HStack {
            Text("\(difficulty.name):")
                .frame(width: 100, alignment: .leading)
            Text("\(score.time) seconds")
                .frame(width: 100, alignment: .leading)
            Text(score.name)
                .frame(width: 100, alignment: .leading)
        }
        .font(.system(.body, design: .monospaced))
        .foregroundColor(.black)
    }
}

struct HighScoresView: View {
    @ObservedObject var highScores: HighScores
    let onReset: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Fastest Mine Sweepers")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HighScoreRow(difficulty: .beginner, entry: highScores.scores["Beginner"])
                HighScoreRow(difficulty: .intermediate, entry: highScores.scores["Intermediate"])
                HighScoreRow(difficulty: .expert, entry: highScores.scores["Expert"])
            }
            .padding()
            .background(Color.white)
            .border(ClassicColors.darkBorder, width: 1)

            HStack(spacing: 12) {
                Button("Reset Scores") {
                    onReset()
                }

                Button("OK") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .background(ClassicColors.background)
    }
}
