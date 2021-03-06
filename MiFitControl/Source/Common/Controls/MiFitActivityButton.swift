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
                image: MiFitBundleHelper.image(named: "running_icon"),
                title: NSLocalizedString("Running", comment: ""),
                backgroundColor: MiFitBundleHelper.color(named: "txt100"),
                textColor: MiFitBundleHelper.color(named: "mifitTextColor100"),
                type: .running),
            Activity(
                image: MiFitBundleHelper.image(named: "treadmill_icon"),
                title: NSLocalizedString("Treadmill", comment: ""),
                backgroundColor: MiFitBundleHelper.color(named: "txt100"),
                textColor: MiFitBundleHelper.color(named: "mifitTextColor100"),
                type: .treadmill),
            Activity(
                image: MiFitBundleHelper.image(named: "cycling_icon"),
                title: NSLocalizedString("Cycling", comment: ""),
                backgroundColor: MiFitBundleHelper.color(named: "txt100"),
                textColor: MiFitBundleHelper.color(named: "mifitTextColor100"),
                type: .cycling),
            Activity(
                image: MiFitBundleHelper.image(named: "walking_icon"),
                title: NSLocalizedString("Walking", comment: ""),
                backgroundColor: MiFitBundleHelper.color(named: "mifit"),
                textColor: MiFitBundleHelper.color(named: "txt100"),
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
            backgroundColor = isSelected ? MiFitBundleHelper.color(named: "mifit") : MiFitBundleHelper.color(named: "txt100")
            imageView.tintColor = isSelected ? MiFitBundleHelper.color(named: "txt100") : MiFitBundleHelper.color(named: "mifitTextColor100")
            titleLabel.textColor = isSelected ? MiFitBundleHelper.color(named: "txt100") : MiFitBundleHelper.color(named: "mifitTextColor100")
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        layer.masksToBounds = true
        layer.cornerRadius = 4.0
    }
}
