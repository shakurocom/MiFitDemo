import UIKit

class MiFitActivityContainer: UIView {

    private(set) var activity: Activity? {
        didSet {
            if let actActivity = activity {
                didSelectActivity?(actActivity)
            }
        }
    }

    /// Called when an activity is selected.
    var didSelectActivity: ((_: Activity) -> Void)?

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var leftConstraint: NSLayoutConstraint!

    private var miFitActivityButtons: [MiFitActivityButton] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.textColor = UIColor.loadColorFromBundle(name: "mifitTextColor100")
        titleLabel.text = NSLocalizedString("Choose type of activity", comment: "")
        titleLabel.font = MiFitStylesheet.FontFace.ralewayMedium.fontWithSize(16.0)

        let buttonBundle = Bundle.findBundleIfNeeded(for: MiFitActivityButton.self)
        ActivityList.generate().items.forEach { activity in
            if let subView = buttonBundle.loadNibNamed("MiFitActivityButton", owner: nil)?[0] as? MiFitActivityButton {
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                subView.addGestureRecognizer(tap)
                subView.activity = activity
                subView.translatesAutoresizingMaskIntoConstraints = false
                subView.widthAnchor.constraint(equalToConstant: 75.0).isActive = true
                miFitActivityButtons.append(subView)
                stackView.addArrangedSubview(subView)
            }
        }
        miFitActivityButtons.last?.isSelected = true
        activity = miFitActivityButtons.last?.activity
    }

    /// Sets the scrollView to the center.
    func centerSctollView() {
        let count = stackView.arrangedSubviews.count
        let spaces = stackView.spacing * CGFloat(count - 1)
        let width = CGFloat(count) * 75.0 + spaces
        leftConstraint.constant = max(0.0, bounds.width - width) * 0.5
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        miFitActivityButtons.forEach { (miFitActivityButton) in
            miFitActivityButton.isSelected = false
        }
        if let miFitActivityButton = sender?.view as? MiFitActivityButton {
            miFitActivityButton.isSelected = true
            activity = miFitActivityButton.activity
        }
    }
}
