import UIKit

protocol RoutingMapProtocol {
    func set(expanded: Bool, animated: Bool)
}

class MiFitMapViewController: UIViewController {

    var screenTopOffset: CGFloat = 0.0
    var animationDuration: TimeInterval = 0.0
    var prefferedScreenHeight: CGFloat = 0.0

    private enum Constants {
        static let routingMapPinFrame: CGRect = CGRect(x: 215.0, y: 236.0, width: 32.0, height: 32.0)
        static let distLabelTopOffset: CGFloat = 90.0
    }

    @IBOutlet private var routingMapView: UIView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var gradientView: UIView!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var distanceUnitLabel: UILabel!
    @IBOutlet private var walkDistanceLabel: UILabel!
    @IBOutlet private var speedLabel: UILabel!
    @IBOutlet private var speedUnitLabel: UILabel!
    @IBOutlet private var mapViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var timeStackView: UIStackView!
    @IBOutlet private var walkStackView: UIStackView!
    @IBOutlet private var speedStackView: UIStackView!

    private var expandedDistPos: CGPoint = .zero
    private var collapsedDistPos: CGPoint = .zero
    private var expandedDistUnitPos: CGPoint = .zero
    private var collapsedDistUnitPos: CGPoint = .zero

    private lazy var gradient: CAGradientLayer? = {
        if let start = UIColor.loadColorFromBundle(name: "mifitBackground200")?.withAlphaComponent(0.0), let end = UIColor.loadColorFromBundle(name: "mifitBackground200")?.withAlphaComponent(1.0) {
            let gradient = CAGradientLayer()

            gradient.colors = [start, end]
            gradientView.layer.insertSublayer(gradient, at: 0)

            return gradient
        }
        return nil
    }()

    private var routingMapPinView: MiFitPinView?
    private var expanded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.loadColorFromBundle(name: "mifitBackground200")

        mapViewTopConstraint.constant = screenTopOffset

        timeLabel.textColor = UIColor.loadColorFromBundle(name: "txt100")
        timeLabel.font = MiFitStylesheet.FontFace.rubikRegular.fontWithSize(22.0)
        timeLabel.text = "--:--:--"

        distanceLabel.textColor = UIColor.loadColorFromBundle(name: "txt100")
        distanceLabel.font = MiFitStylesheet.FontFace.rubikBold.fontWithSize(96.0)
        distanceLabel.text = "--.--"

        distanceUnitLabel.textColor = UIColor.loadColorFromBundle(name: "txt100")
        distanceUnitLabel.font = MiFitStylesheet.FontFace.ralewayRegular.fontWithSize(20.0)

        walkDistanceLabel.textColor = UIColor.loadColorFromBundle(name: "txt100")
        walkDistanceLabel.font = MiFitStylesheet.FontFace.rubikRegular.fontWithSize(22.0)
        walkDistanceLabel.text = "---"

        speedLabel.textColor = UIColor.loadColorFromBundle(name: "txt100")
        speedLabel.font = MiFitStylesheet.FontFace.rubikRegular.fontWithSize(22.0)
        speedLabel.text = "---"

        speedUnitLabel.textColor = UIColor.loadColorFromBundle(name: "mifitTextColor100")
        speedUnitLabel.font = MiFitStylesheet.FontFace.ralewayRegular.fontWithSize(10.0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradient?.frame = gradientView.bounds
        if let subview = createRoutingPinView() {
            routingMapView.addSubview(subview)
            routingMapPinView = subview
        }

        distanceLabel.layer.layoutIfNeeded()
        distanceUnitLabel.layer.layoutIfNeeded()

        let scale = UIScreen.main.bounds.height / prefferedScreenHeight

        expandedDistPos = distanceLabel.layer.position
        collapsedDistPos = CGPoint(x: view.bounds.midX, y: (Constants.distLabelTopOffset - screenTopOffset) * scale + distanceLabel.bounds.height * 0.5)

        expandedDistUnitPos = distanceUnitLabel.layer.position
        collapsedDistUnitPos = CGPoint(x: view.bounds.midX, y: collapsedDistPos.y + distanceLabel.bounds.height * 0.5 + distanceUnitLabel.bounds.height * 0.5 + 15.0)

        set(expanded: expanded, animated: false)
    }

    func setActivity(_ activity: Activity?) {
        guard let actActivity = activity else {
            return
        }
        let distance: String
        let speed: String
        let walkDistance: String
        let time: String
        switch actActivity.type {
        case .running:
            distance = "3.5"
            speed = "9"
            walkDistance = "12 861"
            time = "00:23:00"
            walkStackView.isHidden = false
        case .treadmill:
            distance = "1.5"
            speed = "8"
            walkDistance = "2 143"
            time = "00:11:00"
            walkStackView.isHidden = false
        case .cycling:
            distance = "50"
            speed = "25"
            walkDistance = "1"
            time = "02:00:00"
            walkStackView.isHidden = true
        case .walking:
            distance = "5.0"
            speed = "5"
            walkDistance = "7145"
            time = "01:05:00"
            walkStackView.isHidden = false
        }

        timeLabel.text = time
        distanceLabel.text = distance
        walkDistanceLabel.text = walkDistance
        speedLabel.text = speed

    }
}

private extension MiFitMapViewController {
    private func createRoutingPinView() -> MiFitPinView? {
        if routingMapPinView == nil, let size = UIImage.loadImageFromBundle(name: "map")?.size {
            let xScale = routingMapView.bounds.width / size.width
            let yScale = routingMapView.bounds.height / size.height

            return MiFitPinView(frame: Constants.routingMapPinFrame.scalePos(xScale, yScale))
        }
        return nil
    }

    private func runFadeAnimation(animated: Bool) {
        let fromValue: Float = expanded ? 0.0 : 1.0
        let toValue: Float = expanded ? 1.0 : 0.0

        imageView.layer.opacity = toValue
        routingMapPinView?.layer.opacity = toValue
        timeStackView.layer.opacity = toValue
        walkStackView.layer.opacity = toValue
        speedStackView.layer.opacity = toValue
        speedUnitLabel.layer.opacity = toValue

        if animated {
            let keyPath = #keyPath(CALayer.opacity)
            let animation1 = CALayer.basicAnimation(for: keyPath, fromValue: fromValue, toValue: toValue, duration: animationDuration)
            let animation2 = CALayer.basicAnimation(for: keyPath, fromValue: fromValue, toValue: toValue, duration: max(animationDuration - 0.2, 0.0))

            imageView.layer.add(animation1, forKey: keyPath)
            routingMapPinView?.layer.add(animation1, forKey: keyPath)
            timeStackView.layer.add(animation2, forKey: keyPath)
            walkStackView.layer.add(animation2, forKey: keyPath)
            speedStackView.layer.add(animation2, forKey: keyPath)
            speedUnitLabel.layer.add(animation2, forKey: keyPath)
        }
    }

    private func runPosAnimation(animated: Bool) {
        let distFromValue = expanded ? NSValue(cgPoint: collapsedDistPos) : NSValue(cgPoint: expandedDistPos)
        let distToValue = expanded ? NSValue(cgPoint: expandedDistPos) : NSValue(cgPoint: collapsedDistPos)
        let unitFromValue = expanded ? NSValue(cgPoint: collapsedDistUnitPos) : NSValue(cgPoint: expandedDistUnitPos)
        let unitToValue = expanded ? NSValue(cgPoint: expandedDistUnitPos) : NSValue(cgPoint: collapsedDistUnitPos)

        distanceLabel.layer.position = distToValue.cgPointValue
        distanceUnitLabel.layer.position = unitToValue.cgPointValue

        if animated {
            let keyPath = #keyPath(CALayer.position)
            let animation1 = CALayer.basicAnimation(for: keyPath, fromValue: distFromValue, toValue: distToValue, duration: animationDuration)
            let animation2 = CALayer.basicAnimation(for: keyPath, fromValue: unitFromValue, toValue: unitToValue, duration: animationDuration)

            distanceLabel.layer.add(animation1, forKey: keyPath)
            distanceUnitLabel.layer.add(animation2, forKey: keyPath)
        }
    }
}

extension MiFitMapViewController: RoutingMapProtocol {
    func set(expanded: Bool, animated: Bool) {
        self.expanded = expanded

        runFadeAnimation(animated: animated)
        runPosAnimation(animated: animated)
    }
}
