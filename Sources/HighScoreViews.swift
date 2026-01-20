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
                .foregroundColor(.black)

            Text("You completed \(difficulty.name) in \(time) seconds!")
                .font(.subheadline)
                .foregroundColor(.black)

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

struct HighScoresView: View {
    @ObservedObject var highScores: HighScores
    let onReset: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Fastest Mine Sweepers")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)

            VStack(spacing: 12) {
                ScoreRow(label: "Beginner:", entry: highScores.scores["Beginner"])
                ScoreRow(label: "Intermediate:", entry: highScores.scores["Intermediate"])
                ScoreRow(label: "Expert:", entry: highScores.scores["Expert"])
            }
            .padding(16)
            .background(ClassicColors.background)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(ClassicColors.darkBorder, lineWidth: 1)
            )

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

struct ScoreRow: View {
    let label: String
    let entry: HighScoreEntry?

    private var score: HighScoreEntry {
        entry ?? HighScoreEntry(name: "Anonymous", time: 999)
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .frame(width: 90, alignment: .trailing)

            Spacer().frame(width: 16)

            Text("\(score.time) seconds")
                .frame(width: 90, alignment: .leading)

            Spacer().frame(width: 16)

            Text(score.name)
                .frame(width: 80, alignment: .leading)
        }
        .font(.system(size: 13))
        .foregroundColor(.black)
    }
}
