import SwiftUI

/// Brand colors shared by every Takwa home-screen widget, mirroring
/// packages/takwa_ui/lib/src/theme/app_colors.dart's `AppColorsExtension`
/// (`.light` / `.dark`) so these widgets look like Takwa, not a one-off
/// palette invented for the widget.
///
/// WidgetKit has no hook into the *app's* own in-app theme setting — like
/// the Android side (`values-night/widget_colors.xml`), these follow the
/// system's light/dark appearance instead, resolved once per render via
/// `TakwaWidgetTheme.resolve(colorScheme)`.
struct TakwaWidgetTheme {
    let cardGradientStart: Color
    let cardGradientEnd: Color
    let border: Color
    let textPrimary: Color
    let textSecondary: Color
    /// AA-contrast-safe gold for *text* — the raw brand gold fails contrast
    /// on the light card, same reasoning as `AppColorsExtension.goldText`.
    let gold: Color
    /// Same reasoning as `gold`, for teal (`AppColorsExtension.tealText`).
    let teal: Color
    let divider: Color

    // ≈ AppColorsExtension.light
    static let light = TakwaWidgetTheme(
        cardGradientStart: Color(red: 1.00, green: 1.00, blue: 1.00), // card
        cardGradientEnd: Color(red: 0.953, green: 0.957, blue: 0.965), // card2/deep #F3F4F6
        border: Color(red: 0.886, green: 0.910, blue: 0.941), // #E2E8F0
        textPrimary: Color(red: 0.067, green: 0.094, blue: 0.153), // #111827
        textSecondary: Color(red: 0.294, green: 0.333, blue: 0.388), // #4B5563
        gold: Color(red: 0.420, green: 0.325, blue: 0.125), // goldText #6B5320
        teal: Color(red: 0.059, green: 0.361, blue: 0.341), // tealText #0F5C57
        divider: Color.black.opacity(0.1)
    )

    // ≈ AppColorsExtension.dark
    static let dark = TakwaWidgetTheme(
        cardGradientStart: Color(red: 0.051, green: 0.067, blue: 0.090), // night #0D1117
        cardGradientEnd: Color(red: 0.118, green: 0.176, blue: 0.251), // card2 #1E2D40
        border: Color(red: 0.165, green: 0.227, blue: 0.314), // #2A3A50
        textPrimary: Color(red: 0.910, green: 0.929, blue: 0.953), // #E8EDF3
        textSecondary: Color(red: 0.561, green: 0.639, blue: 0.733), // #8FA3BB
        gold: Color(red: 0.784, green: 0.663, blue: 0.431), // gold #C8A96E
        teal: Color(red: 0.227, green: 0.686, blue: 0.663), // teal #3AAFA9
        divider: Color.white.opacity(0.15)
    )

    static func resolve(_ scheme: ColorScheme) -> TakwaWidgetTheme {
        scheme == .dark ? .dark : .light
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [cardGradientStart, cardGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
