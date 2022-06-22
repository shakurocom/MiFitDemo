import UIKit

class WeakTarget: NSObject {
    weak var controller: MiFitViewController?

    @objc func updateUI() {
        self.controller?.updateUI()
    }
}

class MiFitViewController: UIViewController {

    struct Option {}

    private enum Constants {
        static let prefferedScreenHeight: CGFloat = 896.0
        static let animationDuration: TimeInterval = 0.5
        static let topScreenTopOffset: CGFloat = UIScreen.main.bounds.height < prefferedScreenHeight ? -117.0 : -56.0
    }

    @IBOutlet private var containerView: MiFitContainerView!
    @IBOutlet private var toogleOpenButton: MiFitToogleOpenButton!
    @IBOutlet private var middleViewTop: NSLayoutConstraint!

    private lazy var routingMap: MiFitMapViewController? = {
        let options = MiFitMapViewController.Option(
            screenTopOffset: Constants.topScreenTopOffset,
            animationDuration: Constants.animationDuration,
            prefferedScreenHeight: Constants.prefferedScreenHeight)

        if let viewController = router?.viewController(type: MiFitMapViewController.self, options: options) as? MiFitMapViewController {
            addChildViewController(viewController, notifyAboutAppearanceTransition: false, targetContainerView: containerView.clippingView)
            return viewController
        }
        return nil
    }()

    private var displayLink: CADisplayLink?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.loadColorFromBundle(name: "mifitBackground100")
        containerView.delegate = self

        toogleOpenButton.layer.shadowColor = UIColor.loadColorFromBundle(name: "start_pause_button_shadow")?.cgColor
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

// MARK: - BaseViewControllerProtocol

extension MiFitViewController: BaseViewControllerProtocol {
    static func instantiateViewController(_ coordinator: AppCoordinator, options: Option) -> UIViewController {
        let viewController = R.unwrap({ R.storyboard.miFit.miFitViewController() })
        viewController.router = coordinator
        return viewController
    }
}
