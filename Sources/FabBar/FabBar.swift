import SwiftUI

/// A customizable iOS 26 glass tab bar with a floating action button.
///
/// FabBar provides a native-looking iOS 26 tab bar where you control what goes in it,
/// including a FAB that morphs with the glass effect.
///
/// ## Usage
///
/// ```swift
/// enum AppTab: Hashable {
///     case home, explore, profile
/// }
///
/// struct ContentView: View {
///     @State private var selectedTab: AppTab = .home
///
///     var body: some View {
///         VStack {
///             // Your tab content here
///
///             FabBar(
///                 selection: $selectedTab,
///                 items: [
///                     FabBarItem(tab: .home, title: "Home", systemImage: "house.fill"),
///                     FabBarItem(tab: .explore, title: "Explore", systemImage: "compass"),
///                     FabBarItem(tab: .profile, title: "Profile", systemImage: "person.fill"),
///                 ],
///                 action: FabAction(
///                     systemImage: "plus",
///                     tint: .blue,
///                     accessibilityLabel: "Add Item"
///                 ) {
///                     // Handle tap
///                 }
///             )
///         }
///     }
/// }
/// ```

/// The intrinsic height of the tab bar.
///
/// Changing this value will grow or shrink the glass capsules, but the icons (28pt)
/// and labels (10pt) inside remain fixed size—they'll just have more or less
/// vertical padding around them.
private let fabBarHeight: CGFloat = 62

@available(iOS 26.0, *)
public struct FabBar<Tab: Hashable>: View {
    /// The currently selected tab.
    @Binding public var selection: Tab

    /// The tab items to display.
    public let items: [FabBarItem<Tab>]

    /// The tint color for the active (selected) tab.
    public var activeTint: Color

    /// The tint color for inactive tabs.
    public var inactiveTint: Color

    /// The floating action button configuration.
    public var action: FabAction

    /// Callback invoked when the user taps an already-selected tab.
    public var onReselect: ((Tab) -> Void)?

    /// Creates a FabBar with the specified configuration.
    ///
    /// - Parameters:
    ///   - selection: A binding to the currently selected tab.
    ///   - items: The tab items to display.
    ///   - activeTint: The tint color for the active (selected) tab. Defaults to `.accentColor`.
    ///   - inactiveTint: The tint color for inactive tabs. Defaults to `.primary`.
    ///   - action: The floating action button configuration.
    ///   - onReselect: Optional callback invoked when the user taps an already-selected tab.
    public init(
        selection: Binding<Tab>,
        items: [FabBarItem<Tab>],
        activeTint: Color = .accentColor,
        inactiveTint: Color = .primary,
        action: FabAction,
        onReselect: ((Tab) -> Void)? = nil
    ) {
        self._selection = selection
        self.items = items
        self.activeTint = activeTint
        self.inactiveTint = inactiveTint
        self.action = action
        self.onReselect = onReselect
    }

    public var body: some View {
        GeometryReader { geo in
            FabBarRepresentable(
                size: geo.size,
                items: items,
                activeTint: activeTint,
                inactiveTint: inactiveTint,
                action: action,
                activeTab: $selection,
                onReselect: onReselect
            )
        }
        .frame(height: fabBarHeight)
    }
}
