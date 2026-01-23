import UIKit

/// A UIView that displays a single tab item with an icon and title stacked vertically.
@available(iOS 26.0, *)
final class TabItemLabelView<Tab: Hashable>: UIView {
    private let imageView: UIImageView
    private let titleLabel: UILabel

    var activeTintColor: UIColor = .tintColor {
        didSet { updateColors() }
    }

    var inactiveTintColor: UIColor = .label {
        didSet { updateColors() }
    }

    var isHighlighted: Bool = false

    init(tabItem: FabBarItem<Tab>) {
        imageView = UIImageView()
        titleLabel = UILabel()

        super.init(frame: .zero)

        setupViews(tabItem: tabItem)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews(tabItem: FabBarItem<Tab>) {
        // Configure image view
        // Use .large scale to match SwiftUI's .imageScale(.large)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large)

        if let imageName = tabItem.image {
            // Custom image from bundle
            let bundle = tabItem.imageBundle ?? .main
            imageView.image = UIImage(named: imageName, in: bundle, with: config)
        } else if let systemImageName = tabItem.systemImage {
            // SF Symbol
            imageView.image = UIImage(systemName: systemImageName, withConfiguration: config)
        }

        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintAdjustmentMode = .normal

        // Configure title label
        titleLabel.text = tabItem.title
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Stack them vertically
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 28),
            imageView.heightAnchor.constraint(equalToConstant: 28),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        updateColors()
    }

    func updateColors(animated: Bool = false) {
        let color = isHighlighted ? activeTintColor : inactiveTintColor

        if animated {
            UIView.transition(with: imageView, duration: 0.15, options: .transitionCrossDissolve) {
                self.imageView.tintColor = color
            }
            UIView.transition(with: titleLabel, duration: 0.15, options: .transitionCrossDissolve) {
                self.titleLabel.textColor = color
            }
        } else {
            imageView.tintColor = color
            titleLabel.textColor = color
        }
    }
}
