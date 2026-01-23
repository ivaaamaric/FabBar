import Foundation

/// A tab item configuration for FabBar.
///
/// Each item represents a tab in the tab bar with an icon and title.
/// The tab is identified by a generic `Tab` type that must conform to `Hashable`.
@available(iOS 26.0, *)
public struct FabBarItem<Tab: Hashable>: Identifiable {
    public var id: Tab { tab }

    /// The tab identifier.
    public let tab: Tab

    /// The title displayed below the icon.
    public let title: String

    /// The SF Symbol name for the icon. Used when `image` is nil.
    public let systemImage: String?

    /// The custom image name from a bundle. Takes precedence over `systemImage` when set.
    public let image: String?

    /// The bundle containing the custom image. Defaults to `.main` if not specified.
    public let imageBundle: Bundle?

    /// Creates a tab item with an SF Symbol icon.
    ///
    /// - Parameters:
    ///   - tab: The tab identifier.
    ///   - title: The title displayed below the icon.
    ///   - systemImage: The SF Symbol name for the icon.
    public init(
        tab: Tab,
        title: String,
        systemImage: String
    ) {
        self.tab = tab
        self.title = title
        self.systemImage = systemImage
        self.image = nil
        self.imageBundle = nil
    }

    /// Creates a tab item with a custom image from a bundle.
    ///
    /// - Parameters:
    ///   - tab: The tab identifier.
    ///   - title: The title displayed below the icon.
    ///   - image: The custom image name.
    ///   - imageBundle: The bundle containing the image. Defaults to `.main`.
    public init(
        tab: Tab,
        title: String,
        image: String,
        imageBundle: Bundle? = nil
    ) {
        self.tab = tab
        self.title = title
        self.systemImage = nil
        self.image = image
        self.imageBundle = imageBundle ?? .main
    }
}
