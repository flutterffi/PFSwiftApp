import SwiftUI

struct PFColorToken: Equatable, Sendable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double

    init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }

    static func rgb(red: Int, green: Int, blue: Int, opacity: Double = 1) -> PFColorToken {
        PFColorToken(
            red: normalized(red),
            green: normalized(green),
            blue: normalized(blue),
            opacity: opacity
        )
    }

    static func hex(_ value: String, opacity: Double = 1) -> PFColorToken? {
        let sanitized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        guard sanitized.count == 6 || sanitized.count == 8 else {
            return nil
        }

        guard let rawValue = UInt64(sanitized, radix: 16) else {
            return nil
        }

        let red: Int
        let green: Int
        let blue: Int
        let resolvedOpacity: Double

        if sanitized.count == 8 {
            red = Int((rawValue & 0xFF00_0000) >> 24)
            green = Int((rawValue & 0x00FF_0000) >> 16)
            blue = Int((rawValue & 0x0000_FF00) >> 8)
            resolvedOpacity = Double(rawValue & 0x0000_00FF) / 255
        } else {
            red = Int((rawValue & 0xFF0000) >> 16)
            green = Int((rawValue & 0x00FF00) >> 8)
            blue = Int(rawValue & 0x0000FF)
            resolvedOpacity = opacity
        }

        return .rgb(red: red, green: green, blue: blue, opacity: resolvedOpacity)
    }

    private static func normalized(_ value: Int) -> Double {
        Double(min(max(value, 0), 255)) / 255
    }
}
