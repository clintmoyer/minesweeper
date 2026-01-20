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
