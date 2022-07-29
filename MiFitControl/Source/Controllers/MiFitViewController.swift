import UIKit

class WeakTarget: NSObject {
    weak var controller: MiFitViewController?

    @objc func updateUI() {
        self.controller?.updateUI()
    }
}

public class MiFitViewController: UIViewController {

    private enum Constants {
        static let prefferedScreenHeight: CGFloat = 896.0
        static let animationDuration: TimeInterval = 0.5
        static let topScreenTopOffset: CGFloat = UIScreen.main.bounds.height < prefferedScreenHeight ? -117.0 : -56.0
    }

    static func loadFromNib() -> MiFitViewController {
        return Bundle.miFitBundleHelper.instantiateViewController(targetClass: MiFitViewController.self, nibName: "MiFitViewController")
    }

    @IBOutlet private var containerView: MiFitContainerView!
    @IBOutlet private var toogleOpenButton: MiFitToogleOpenButton!
    @IBOutlet private var middleViewTop: NSLayoutConstraint!

    private lazy var routingMap: MiFitMapViewController? = {
        let viewController = MiFitMapViewController.loadFromNib()
        viewController.screenTopOffset = Constants.topScreenTopOffset
        viewController.animationDuration = Constants.animationDuration
        viewController.prefferedScreenHeight = Constants.prefferedScreenHeight
        addChildViewController(viewController, notifyAboutAppearanceTransition: false, targetContainerView: containerView.clippingView)
        return viewController
    }()

    private var displayLink: CADisplayLink?

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Bundle.miFitBundleHelper.color(named: "mifitBackground100")
        containerView.delegate = self

        toogleOpenButton.layer.shadowColor = Bundle.miFitBundleHelper.color(named: "start_pause_button_shadow")?.cgColor
        toogleOpenButton.layer.shadowOpacity = 0.48
        toogleOpenButton.layer.shadowRadius = 20.0
        toogleOpenButton.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        toogleOpenButton.isOpen = containerView.isOpen

        containerView.recalcLayersFrames(offset: Constants.topScreenTopOffset)
        middleViewTop.constant = MiFitContainerView.Constants.arcShapeSize.height + Constants.topScreenTopOffset + 30.0
        routingMap?.set(expanded: containerView.isOpen, animated: false)
        routingMap?.setActivity(containerView.activity)
        containerView.didSelectActivity = { [weak self] (activity) in
            self?.routingMap?.setActivity(activity)
        }
    }
}

private extension MiFitViewController {
    func updateUI() {
        if toogleOpenButton.frame.contains(containerView.collisionPoint) {
            displayLink?.invalidate()
            toogleOpenButton.layer.add(shakeAnimation(), forKey: nil)
        }
    }

    @IBAction private func toogleOpenButtonTapped() {
        containerView.toogleOpen(duration: Constants.animationDuration)
        toogleOpenButton.runToogleOpenAnimation()
        routingMap?.set(expanded: containerView.isOpen, animated: true)
    }
}

extension MiFitViewController: MiFitContainerViewDelegate {
    func mifitContainerViewWillChangeClippingSize() {
        let weakTarget = WeakTarget()
        weakTarget.controller = self

        displayLink = CADisplayLink(target: weakTarget, selector: #selector(WeakTarget.updateUI))
        displayLink?.add(to: .main, forMode: .common)
    }
}

private extension MiFitViewController {

    private func shakeAnimation() -> CAKeyframeAnimation {
        let values = [0.0, (containerView.isOpen ? 70.0 : -70.0), (containerView.isOpen ? -70.0 : 70.0), 0.0]
        let valueFunction = CAValueFunction(name: .translateY)

        return CALayer.keyFrameAnimation(for: #keyPath(CALayer.transform), values: values, duration: Constants.animationDuration, valueFunction: valueFunction)
    }

}
