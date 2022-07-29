import UIKit

struct Activity {
    enum ActivityType {
        case running
        case treadmill
        case cycling
        case walking
    }

    let image: UIImage?
    let title: String?
    let backgroundColor: UIColor?
    let textColor: UIColor?
    let type: ActivityType
}

struct ActivityList {
    let items: [Activity]
}

extension ActivityList {
    static func generate() -> ActivityList {
        return ActivityList(items: [
            Activity(
                image: Bundle.miFitBundleHelper.image(named: "running_icon"),
                title: NSLocalizedString("Running", comment: ""),
                backgroundColor: Bundle.miFitBundleHelper.color(named: "txt100"),
                textColor: Bundle.miFitBundleHelper.color(named: "mifitTextColor100"),
                type: .running),
            Activity(
                image: Bundle.miFitBundleHelper.image(named: "treadmill_icon"),
                title: NSLocalizedString("Treadmill", comment: ""),
                backgroundColor: Bundle.miFitBundleHelper.color(named: "txt100"),
                textColor: Bundle.miFitBundleHelper.color(named: "mifitTextColor100"),
                type: .treadmill),
            Activity(
                image: Bundle.miFitBundleHelper.image(named: "cycling_icon"),
                title: NSLocalizedString("Cycling", comment: ""),
                backgroundColor: Bundle.miFitBundleHelper.color(named: "txt100"),
                textColor: Bundle.miFitBundleHelper.color(named: "mifitTextColor100"),
                type: .cycling),
            Activity(
                image: Bundle.miFitBundleHelper.image(named: "walking_icon"),
                title: NSLocalizedString("Walking", comment: ""),
                backgroundColor: Bundle.miFitBundleHelper.color(named: "mifit"),
                textColor: Bundle.miFitBundleHelper.color(named: "txt100"),
                type: .walking)
        ])
    }
}

class MiFitActivityButton: UIView {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    /// Activity type for button style. The defaul value is `nil`.
    var activity: Activity? {
        didSet {
            backgroundColor = activity?.backgroundColor

            imageView.image = activity?.image
            imageView.tintColor = activity?.textColor
            titleLabel.text = activity?.title
            titleLabel.textColor = activity?.textColor
            titleLabel.font = MiFitStylesheet.FontFace.ralewayRegular.fontWithSize(12.0)
        }
    }

    /// Button style if selected. The default value is `false`.
    var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? Bundle.miFitBundleHelper.color(named: "mifit") : Bundle.miFitBundleHelper.color(named: "txt100")
            imageView.tintColor = isSelected ? Bundle.miFitBundleHelper.color(named: "txt100") : Bundle.miFitBundleHelper.color(named: "mifitTextColor100")
            titleLabel.textColor = isSelected ? Bundle.miFitBundleHelper.color(named: "txt100") : Bundle.miFitBundleHelper.color(named: "mifitTextColor100")
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        layer.masksToBounds = true
        layer.cornerRadius = 4.0
    }
}
