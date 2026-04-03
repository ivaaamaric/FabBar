import UIKit

/// The root UIKit view that assembles the tab bar with glass effects.
/// Uses UIGlassContainerEffect to enable morphing between the segmented control and FAB.
@available(iOS 26.0, *)
final class GlassTabBarView: UIView {
    let containerEffectView: UIVisualEffectView
    let segmentedGlassView: UIVisualEffectView
    let segmentedControl: TabBarSegmentedControl
    let fabGlassView: UIVisualEffectView
    private var appearance: FabBarAppearance
    private var fabButton: UIButton?
    private var action: FabBarAction?
    private var fabConstraints: [NSLayoutConstraint] = []
    private var fabGlassViewConstraints: [NSLayoutConstraint] = []
    private var segmentedLeadingConstraint: NSLayoutConstraint?
    private var segmentedCenterXConstraint: NSLayoutConstraint?
    private var segmentedHiddenWidthConstraint: NSLayoutConstraint?
    private var actionTransitionID: UInt = 0

    private let spacing: CGFloat = Constants.fabSpacing
    private let contentPadding: CGFloat = Constants.contentPadding

    private(set) var tabCount: Int
    private var segmentedTrailingConstraint: NSLayoutConstraint?

    init(
        segmentedControl: TabBarSegmentedControl,
        tabCount: Int,
        action: FabBarAction?,
        appearance: FabBarAppearance
    ) {
        self.segmentedControl = segmentedControl
        self.tabCount = tabCount
        self.action = action
        self.appearance = appearance

        // Create glass container effect for morphing
        let containerEffect = UIGlassContainerEffect()
        containerEffect.spacing = Constants.fabSpacing
        containerEffectView = UIVisualEffectView(effect: containerEffect)

        // Create segmented control glass effect
        let segmentedGlassEffect = UIGlassEffect()
        segmentedGlassEffect.isInteractive = true
        segmentedGlassView = UIVisualEffectView(effect: segmentedGlassEffect)

        // Create FAB button
        let fabGlassEffect = UIGlassEffect()
        fabGlassEffect.isInteractive = true
        fabGlassEffect.tintColor = appearance.colors.fabBackgroundTint
        fabGlassView = UIVisualEffectView(effect: fabGlassEffect)

        super.init(frame: .zero)

        // Ensure tint adjustment mode is automatic so views dim when sheets are presented
        tintAdjustmentMode = .automatic
        fabGlassView.tintAdjustmentMode = .automatic

        setupViews()

        // Ensure deterministic initial appearance (no “missing plus” on first render).
        // `updateAction` may be called before the view is in a window, so we avoid starting at alpha 0.
        fabGlassView.alpha = 1
        fabGlassView.isHidden = action == nil
        fabGlassView.isUserInteractionEnabled = action != nil
        applyFabTintEffect()

        updateAction(action)
    }

    private func applyFabTintEffect() {
        // Recreate the effect to ensure tint is applied immediately/reliably.
        fabGlassView.tintColor = appearance.colors.fabBackgroundTint
        // Clearing the effect first makes UIKit reliably re-render the tint
        // when toggling hidden/shown quickly.
        fabGlassView.effect = nil
        let effect = UIGlassEffect()
        effect.isInteractive = true
        effect.tintColor = fabGlassView.tintColor
        fabGlassView.effect = effect
    }

    func updateAppearance(_ appearance: FabBarAppearance) {
        self.appearance = appearance
        applyFabTintEffect()
        fabButton?.tintColor = appearance.colors.fabIconTint
    }

    private func setupViews() {
        // Add container effect view
        addSubview(containerEffectView)
        containerEffectView.translatesAutoresizingMaskIntoConstraints = false

        // Add segmented glass view to container's contentView
        containerEffectView.contentView.addSubview(segmentedGlassView)
        segmentedGlassView.translatesAutoresizingMaskIntoConstraints = false

        // Add segmented control to segmented glass view's contentView
        segmentedGlassView.contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        // Always add the FAB glass view so the segmented control keeps a stable width
        // whether the button is shown or hidden.
        containerEffectView.contentView.addSubview(fabGlassView)
        fabGlassView.translatesAutoresizingMaskIntoConstraints = false

        // Extra bottom inset compensates for UISegmentedControl's internal padding,
        // visually centering the content within the glass container.
        let segmentedControlBottomInsetAdjustment: CGFloat = 1

        let segmentedLeading = segmentedGlassView.leadingAnchor.constraint(equalTo: containerEffectView.contentView.leadingAnchor)
        segmentedLeadingConstraint = segmentedLeading

        let segmentedCenterX = segmentedGlassView.centerXAnchor.constraint(equalTo: containerEffectView.contentView.centerXAnchor)
        segmentedCenterXConstraint = segmentedCenterX
        segmentedCenterX.isActive = false

        // When the FAB is hidden we still want the segmented capsule to be the same width
        // as when the FAB is shown (i.e. reserve FAB width + spacing).
        let segmentedHiddenWidth = segmentedGlassView.widthAnchor.constraint(
            equalTo: containerEffectView.contentView.widthAnchor,
            constant: -(Constants.barHeight + Constants.fabSpacing)
        )
        segmentedHiddenWidthConstraint = segmentedHiddenWidth
        segmentedHiddenWidth.isActive = false

        let constraints: [NSLayoutConstraint] = [
            containerEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerEffectView.topAnchor.constraint(equalTo: topAnchor),
            containerEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            segmentedGlassView.topAnchor.constraint(equalTo: containerEffectView.contentView.topAnchor),
            segmentedGlassView.bottomAnchor.constraint(equalTo: containerEffectView.contentView.bottomAnchor),
            segmentedLeading,

            segmentedControl.leadingAnchor.constraint(equalTo: segmentedGlassView.contentView.leadingAnchor, constant: contentPadding),
            segmentedControl.trailingAnchor.constraint(equalTo: segmentedGlassView.contentView.trailingAnchor, constant: -contentPadding),
            segmentedControl.topAnchor.constraint(equalTo: segmentedGlassView.contentView.topAnchor, constant: contentPadding),
            segmentedControl.bottomAnchor.constraint(equalTo: segmentedGlassView.contentView.bottomAnchor, constant: -contentPadding - segmentedControlBottomInsetAdjustment),
        ]

        NSLayoutConstraint.activate(constraints)

        // FAB glass view constraints are always active (space reservation).
        fabGlassViewConstraints = [
            fabGlassView.trailingAnchor.constraint(equalTo: containerEffectView.contentView.trailingAnchor),
            fabGlassView.topAnchor.constraint(equalTo: containerEffectView.contentView.topAnchor),
            fabGlassView.bottomAnchor.constraint(equalTo: containerEffectView.contentView.bottomAnchor),
            fabGlassView.widthAnchor.constraint(equalTo: fabGlassView.heightAnchor),
        ]
        NSLayoutConstraint.activate(fabGlassViewConstraints)

        // Set up the trailing constraint based on tab count
        segmentedTrailingConstraint = makeSegmentedTrailingConstraint()
        segmentedTrailingConstraint?.isActive = true
    }

    func updateAction(_ newAction: FabBarAction?) {
        actionTransitionID &+= 1
        let transitionID = actionTransitionID

        let wasShowing = action != nil
        let willShow = newAction != nil

        // If we were showing and will still show, just update the button visuals/label.
        if wasShowing, willShow, let newAction {
            action = newAction

            // Important: this path also runs on first render (init already set `action`),
            // so we must create the button if it doesn't exist yet.
            if fabButton == nil {
                let button = UIButton(type: .system)
                fabButton = button
                fabGlassView.contentView.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                fabConstraints = [
                    button.leadingAnchor.constraint(equalTo: fabGlassView.contentView.leadingAnchor),
                    button.trailingAnchor.constraint(equalTo: fabGlassView.contentView.trailingAnchor),
                    button.topAnchor.constraint(equalTo: fabGlassView.contentView.topAnchor),
                    button.bottomAnchor.constraint(equalTo: fabGlassView.contentView.bottomAnchor),
                ]
                NSLayoutConstraint.activate(fabConstraints)
            }

            fabButton?.accessibilityLabel = newAction.accessibilityLabel
            let config = UIImage.SymbolConfiguration(pointSize: Constants.fabIconPointSize, weight: .medium)
            fabButton?.setImage(UIImage(systemName: newAction.systemImage, withConfiguration: config), for: .normal)
            fabButton?.tintColor = appearance.colors.fabIconTint
            // Replace action handler (simple + safe: rebuild the button actions)
            fabButton?.removeTarget(nil, action: nil, for: .allEvents)
            fabButton?.addAction(UIAction { _ in newAction.action() }, for: .touchUpInside)
            fabGlassView.isHidden = false
            fabGlassView.isUserInteractionEnabled = true
            fabGlassView.alpha = 1
            segmentedLeadingConstraint?.isActive = true
            segmentedCenterXConstraint?.isActive = false
            segmentedHiddenWidthConstraint?.isActive = false
            return
        }

        // From here on we're transitioning between showing <-> hidden.
        action = newAction

        // Cancel in-flight animations to prevent stale completions (missing icon, etc.)
        fabGlassView.layer.removeAllAnimations()
        segmentedGlassView.layer.removeAllAnimations()

        // Keep the button view stable across show/hide to avoid flicker/missing icon.
        if willShow, let newAction {
            applyFabTintEffect()
            if fabButton == nil {
                let button = UIButton(type: .system)
                fabButton = button
                fabGlassView.contentView.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                fabConstraints = [
                    button.leadingAnchor.constraint(equalTo: fabGlassView.contentView.leadingAnchor),
                    button.trailingAnchor.constraint(equalTo: fabGlassView.contentView.trailingAnchor),
                    button.topAnchor.constraint(equalTo: fabGlassView.contentView.topAnchor),
                    button.bottomAnchor.constraint(equalTo: fabGlassView.contentView.bottomAnchor),
                ]
                NSLayoutConstraint.activate(fabConstraints)
            }

            let config = UIImage.SymbolConfiguration(pointSize: Constants.fabIconPointSize, weight: .medium)
            fabButton?.setImage(UIImage(systemName: newAction.systemImage, withConfiguration: config), for: .normal)
            fabButton?.tintColor = appearance.colors.fabIconTint
            fabButton?.accessibilityLabel = newAction.accessibilityLabel
            fabButton?.accessibilityTraits = .button
            fabButton?.tintAdjustmentMode = .automatic
            fabButton?.removeTarget(nil, action: nil, for: .allEvents)
            fabButton?.addAction(UIAction { _ in newAction.action() }, for: .touchUpInside)
        }

        // Fade the FAB glass view in/out (no movement) using Core Animation so it still runs
        // even if SwiftUI disables UIView animations for the current transaction.
        let shouldAnimateFabOpacity = (wasShowing != willShow) && window != nil
        if willShow {
            fabGlassView.isHidden = false
            fabGlassView.isUserInteractionEnabled = false
            // Re-apply after unhide so tint is correct even when toggling quickly.
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard transitionID == self.actionTransitionID else { return }
                guard self.action != nil, self.fabGlassView.isHidden == false else { return }
                self.applyFabTintEffect()
            }
        } else {
            fabGlassView.isUserInteractionEnabled = false
        }

        // Tabs should animate between leading <-> centered.
        // We'll animate only if we are actually transitioning between states.
        let shouldAnimateTabs = (wasShowing != willShow) && window != nil

        // Activate target constraints for segmented glass view.
        if willShow {
            segmentedLeadingConstraint?.isActive = true
            segmentedCenterXConstraint?.isActive = false
            segmentedHiddenWidthConstraint?.isActive = false
        } else {
            segmentedLeadingConstraint?.isActive = false
            segmentedCenterXConstraint?.isActive = true
            segmentedHiddenWidthConstraint?.isActive = true
        }

        if shouldAnimateTabs {
            UIView.animate(withDuration: 0.32, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0) {
                self.layoutIfNeeded()
            }
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }

        if shouldAnimateFabOpacity {
            let presentation = fabGlassView.layer.presentation()
            let duration: CFTimeInterval = 0.22
            let timing = CAMediaTimingFunction(name: .easeInEaseOut)

            let toOpacity: Float = willShow ? 1 : 0
            let toScale: CGFloat = willShow ? 1 : 0.01

            // Establish a deterministic start state for "show" so it doesn't pop in at full size
            // before the animation kicks in (especially when coming from isHidden = true).
            if willShow {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                fabGlassView.layer.opacity = 0
                fabGlassView.layer.transform = CATransform3DMakeScale(0.01, 0.01, 1)
                CATransaction.commit()
            }

            let fromOpacity: Float = willShow
                ? 0
                : (presentation?.opacity ?? fabGlassView.layer.opacity)

            let fromScale: CGFloat = willShow
                ? 0.01
                : ((presentation?.value(forKeyPath: "transform.scale.x") as? CGFloat) ?? 1)

            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = fromOpacity
            opacityAnimation.toValue = toOpacity

            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = fromScale
            scaleAnimation.toValue = toScale

            let group = CAAnimationGroup()
            group.animations = [opacityAnimation, scaleAnimation]
            group.duration = duration
            group.timingFunction = timing

            fabGlassView.layer.removeAnimation(forKey: "fabFade")

            CATransaction.begin()
            CATransaction.setCompletionBlock { [weak self] in
                guard let self else { return }
                guard transitionID == self.actionTransitionID else { return }

                if willShow {
                    self.fabGlassView.isHidden = false
                    self.fabGlassView.isUserInteractionEnabled = true
                } else {
                    self.fabGlassView.isUserInteractionEnabled = false
                    self.fabGlassView.isHidden = true

                    // Prep next show without any flash.
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    self.fabGlassView.layer.opacity = 1
                    self.fabGlassView.layer.transform = CATransform3DIdentity
                    CATransaction.commit()
                }
            }

            // Make the model layer authoritative immediately; the animation provides the transition.
            fabGlassView.layer.opacity = toOpacity
            fabGlassView.layer.transform = CATransform3DMakeScale(toScale, toScale, 1)
            fabGlassView.layer.add(group, forKey: "fabFade")
            CATransaction.commit()
        } else {
            fabGlassView.layer.opacity = 1
            fabGlassView.layer.transform = CATransform3DIdentity
            if willShow {
                fabGlassView.isHidden = false
                fabGlassView.isUserInteractionEnabled = true
            } else {
                fabGlassView.isUserInteractionEnabled = false
                fabGlassView.isHidden = true
            }
        }
    }

    /// Creates the appropriate trailing constraint for the segmented glass view.
    /// For 3+ tabs, fills to the FAB. For fewer tabs, floats leading-aligned.
    private func makeSegmentedTrailingConstraint() -> NSLayoutConstraint {
        if tabCount >= 3 {
            return segmentedGlassView.trailingAnchor.constraint(equalTo: fabGlassView.leadingAnchor, constant: -spacing)
        } else {
            return segmentedGlassView.trailingAnchor.constraint(lessThanOrEqualTo: fabGlassView.leadingAnchor, constant: -spacing)
        }
    }

    /// Updates the tab count and swaps the trailing constraint to match.
    func updateTabCount(_ newCount: Int) {
        guard newCount != tabCount else { return }
        tabCount = newCount
        segmentedTrailingConstraint?.isActive = false
        segmentedTrailingConstraint = makeSegmentedTrailingConstraint()
        segmentedTrailingConstraint?.isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Capsule shape for segmented control
        segmentedGlassView.cornerConfiguration = .capsule()

        // Circle shape for FAB button (capsule with equal width/height = circle)
        fabGlassView.cornerConfiguration = .capsule()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        guard fabGlassView.superview != nil else { return }
        applyFabTintEffect()
    }
}
