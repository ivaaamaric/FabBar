import UIKit

@available(iOS 26.0, *)
public struct FabBarAppearance: Sendable {
    /// Colors used by FabBar's UIKit-backed rendering.
    public struct Colors: Sendable {
        /// Background tint applied to the floating action button container.
        public var fabBackgroundTint: UIColor

        /// Icon tint color for the floating action button.
        public var fabIconTint: UIColor

        /// Tab item icon/title color (light mode).
        public var tabItemTintLight: UIColor

        /// Tab item icon/title color (dark mode).
        public var tabItemTintDark: UIColor

        /// Selection indicator tint (light mode).
        public var segmentIndicatorTintLight: UIColor

        /// Selection indicator tint (dark mode).
        public var segmentIndicatorTintDark: UIColor

        public init(
            fabBackgroundTint: UIColor,
            fabIconTint: UIColor,
            tabItemTintLight: UIColor,
            tabItemTintDark: UIColor,
            segmentIndicatorTintLight: UIColor,
            segmentIndicatorTintDark: UIColor
        ) {
            self.fabBackgroundTint = fabBackgroundTint
            self.fabIconTint = fabIconTint
            self.tabItemTintLight = tabItemTintLight
            self.tabItemTintDark = tabItemTintDark
            self.segmentIndicatorTintLight = segmentIndicatorTintLight
            self.segmentIndicatorTintDark = segmentIndicatorTintDark
        }
    }

    public var colors: Colors

    public init(colors: Colors) {
        self.colors = colors
    }

    public static var `default`: FabBarAppearance {
        FabBarAppearance(
            colors: Colors(
                fabBackgroundTint: .systemBlue,
                fabIconTint: .white,
                tabItemTintLight: .label,
                tabItemTintDark: .white,
                segmentIndicatorTintLight: .label.withAlphaComponent(0.08),
                segmentIndicatorTintDark: .label.withAlphaComponent(0.15)
            )
        )
    }
}

