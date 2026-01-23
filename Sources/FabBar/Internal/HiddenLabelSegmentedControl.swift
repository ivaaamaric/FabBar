import UIKit

/// A UISegmentedControl subclass customized for use as a tab bar replacement.
///
/// This subclass provides three key customizations:
///
/// 1. **Hidden labels and images**: Hides all UILabel subviews recursively and segment
///    background/separator images while preserving the selected segment indicator.
///    This allows custom UIKit views to be overlaid on top for full rendering flexibility.
///
/// 2. **Immediate glass effect on touch down**: By default, UISegmentedControl only shows
///    the interactive glass hover effect when dragging from the currently selected segment.
///    This subclass overrides touch handling to move the indicator immediately on touch down,
///    which triggers the glass effect animation for any segment tap—matching the behavior
///    of UITabBar. The actual selection change is deferred until touch up via `sendActions(for:)`.
///
/// 3. **Highlight tracking**: Reports which segment is visually highlighted during touch,
///    allowing overlaid labels to update their colors to match the glass indicator position.
///
/// 4. **Reselection callback**: Notifies when user taps an already-selected segment.
@available(iOS 26.0, *)
final class HiddenLabelSegmentedControl: UISegmentedControl {
    /// The segment index before touch began, used to restore on cancel and detect actual changes.
    private var originalIndex: Int?

    /// Called when user taps the already-selected segment.
    var onReselect: ((Int) -> Void)?

    /// Called when the highlighted segment changes during touch interaction.
    /// The parameter is the currently highlighted segment index.
    var onHighlightChange: ((Int) -> Void)?

    /// Called when touch ends or is cancelled, indicating highlight should return to selection.
    var onHighlightEnd: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        hideLabelsRecursively(self)
        // Hide segment background/separator images while preserving the selected indicator (last subview)
        for subview in subviews {
            if subview is UIImageView && subview != subviews.last {
                subview.alpha = 0
            }
        }
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        hideLabelsRecursively(subview)
    }

    private func hideLabelsRecursively(_ view: UIView) {
        if view is UILabel {
            view.isHidden = true
        }
        for sub in view.subviews {
            hideLabelsRecursively(sub)
        }
    }

    private func segmentIndex(at point: CGPoint) -> Int {
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        return min(max(Int(point.x / segmentWidth), 0), numberOfSegments - 1)
    }

    /// Whether to use custom touch handling for immediate glass effect feedback.
    /// Disabled for accessibility content sizes to preserve standard behavior.
    private var useCustomTouchHandling: Bool {
        !traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard useCustomTouchHandling, let touch = touches.first else {
            super.touchesBegan(touches, with: event)
            return
        }

        originalIndex = selectedSegmentIndex
        let newIndex = segmentIndex(at: touch.location(in: self))
        selectedSegmentIndex = newIndex
        onHighlightChange?(newIndex)
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard useCustomTouchHandling, let touch = touches.first else {
            super.touchesMoved(touches, with: event)
            return
        }

        let newIndex = segmentIndex(at: touch.location(in: self))
        if selectedSegmentIndex != newIndex {
            selectedSegmentIndex = newIndex
            onHighlightChange?(newIndex)
        }
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard useCustomTouchHandling else {
            super.touchesEnded(touches, with: event)
            return
        }

        if let originalIndex {
            if selectedSegmentIndex != originalIndex {
                sendActions(for: .valueChanged)
            } else {
                // User tapped the already-selected segment
                onReselect?(selectedSegmentIndex)
            }
        }
        originalIndex = nil
        onHighlightEnd?()
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard useCustomTouchHandling else {
            super.touchesCancelled(touches, with: event)
            return
        }

        if let originalIndex {
            selectedSegmentIndex = originalIndex
        }
        originalIndex = nil
        onHighlightEnd?()
        super.touchesCancelled(touches, with: event)
    }
}
