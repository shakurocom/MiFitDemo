import UIKit
import CoreGraphics

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}

protocol MiFitContainerViewDelegate: AnyObject {
    func mifitContainerViewWillChangeClippingSize()
}

class MiFitContainerView: UIView {

    enum Constants {
        static let arcShapeSize = CGSize(width: 660.0, height: 320.0)
    }

    var activity: Activity? {
        return activityView.activity
    }
    var didSelectActivity: ((_: Activity) -> Void)? {
        get {
            return activityView.didSelectActivity
        }
        set {
            activityView.didSelectActivity = newValue
        }
    }

    @IBOutlet private(set) var clippingView: PassThroughView!
    @IBOutlet private(set) var activityView: MiFitActivityContainer!

    private let arcShapeLayer = CAShapeLayer()
    private let clippingLayer = CAShapeLayer()

    private let arcShapeStartPath = UIBezierPath()
    private let arcShapeFinalPath = UIBezierPath()

    private let clippingStartPath = UIBezierPath()
    private let clippingFinalPath = UIBezierPath()

    private var startArcShapeBounds: CGRect = .zero
    private var finalArcShapeBounds: CGRect = .zero

    private var startArcShapePosition: CGPoint = .zero
    private var finalArcShapePosition: CGPoint = .zero

    private var viewTopOffset: CGFloat = 0.0
    private(set) var isOpen: Bool = false

    private var arcShapeOrigin: CGPoint {
        return CGPoint(x: (bounds.width - Constants.arcShapeSize.width) * 0.5, y: 0.0)
    }

    private var arcShapeFrame: CGRect {
        return CGRect(origin: arcShapeOrigin, size: Constants.arcShapeSize)
    }

    var collisionPoint: CGPoint {
        guard let frame = arcShapeLayer.presentation()?.frame else {
            return .zero
        }
        return CGPoint(x: frame.midX, y: frame.maxY)
    }

    weak var delegate: MiFitContainerViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        arcShapeLayer.fillColor = UIColor.white.cgColor
        arcShapeLayer.shadowColor = UIColor.black.cgColor
        arcShapeLayer.shadowOpacity = 0.1
        arcShapeLayer.shadowRadius = 20.0
        arcShapeLayer.shadowOffset = CGSize(width: 0.0, height: -2.0)

        layer.insertSublayer(arcShapeLayer, at: 0)

        clippingView.layer.backgroundColor = UIColor.clear.cgColor
        clippingView.layer.mask = clippingLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        drawArcShapeLayer()
        drawClippingLayer()

        activityView.centerSctollView()
    }

    func toogleOpen(duration: TimeInterval) {
        delegate?.mifitContainerViewWillChangeClippingSize()

        isOpen.toggle()

        resizeArcShapeLayer(duration: duration)
        resizeClippingLayer(duration: duration)
    }

    func recalcLayersFrames(offset: CGFloat) {
        viewTopOffset = offset

        drawArcShapeLayer()
        drawClippingLayer()
    }
}

private extension MiFitContainerView {
    private func drawArcShapeLayer() {
        arcShapeLayer.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: Constants.arcShapeSize.height))

        startArcShapeBounds = arcShapeLayer.bounds
        finalArcShapeBounds = bounds

        startArcShapePosition = arcShapeLayer.position
        finalArcShapePosition = center

        let arcShapePoint1 = CGPoint(x: arcShapeFrame.maxX, y: arcShapeFrame.minY)
        let arcShapePoint2 = CGPoint(x: arcShapeFrame.maxX, y: arcShapeFrame.midY)
        let arcShapePoint3 = CGPoint(x: arcShapeFrame.minX, y: arcShapeFrame.midY)

        arcShapeStartPath.move(to: arcShapeOrigin)
        arcShapeStartPath.addLine(to: arcShapePoint1)
        arcShapeStartPath.addLine(to: arcShapePoint2)
        arcShapeStartPath.addQuadCurve(to: arcShapePoint3, controlPoint: CGPoint(x: arcShapeFrame.midX, y: arcShapeFrame.maxY + arcShapeFrame.size.height * 0.5))
        arcShapeStartPath.close()

        arcShapeFinalPath.move(to: arcShapeOrigin)
        arcShapeFinalPath.addLine(to: CGPoint(x: arcShapeFrame.width, y: arcShapeOrigin.y))
        arcShapeFinalPath.addLine(to: CGPoint(x: arcShapeFrame.width, y: bounds.height))
        arcShapeFinalPath.addLine(to: CGPoint(x: arcShapeOrigin.x, y: bounds.height))
        arcShapeFinalPath.close()

        arcShapeStartPath.apply(CGAffineTransform(translationX: 0.0, y: viewTopOffset))

        arcShapeLayer.path = arcShapeStartPath.cgPath
        arcShapeLayer.shadowPath = arcShapeStartPath.cgPath
    }

    private func drawClippingLayer() {
        let arcRadius = bounds.midX
        let topOffset = arcShapeFrame.height - arcRadius - 10.0

        clippingStartPath.move(to: bounds.origin)
        clippingStartPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        clippingStartPath.addLine(to: CGPoint(x: bounds.maxX, y: topOffset))
        clippingStartPath.addLine(to: CGPoint(x: bounds.minX, y: topOffset))
        clippingStartPath.addArc(withCenter: CGPoint(x: bounds.midX, y: topOffset), radius: arcRadius, startAngle: 0.0, endAngle: .pi, clockwise: true)
        clippingStartPath.close()

        clippingFinalPath.move(to: bounds.origin)
        clippingFinalPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        clippingFinalPath.addLine(to: CGPoint(x: bounds.maxX, y: topOffset))
        clippingFinalPath.addLine(to: CGPoint(x: bounds.minX, y: topOffset))
        clippingFinalPath.addArc(withCenter: CGPoint(x: bounds.midX, y: topOffset), radius: bounds.height, startAngle: 0.0, endAngle: .pi, clockwise: true)
        clippingFinalPath.close()

        clippingStartPath.apply(CGAffineTransform(translationX: 0.0, y: viewTopOffset))

        clippingLayer.path = clippingStartPath.cgPath
    }

    private func resizeArcShapeLayer(duration: TimeInterval) {
        let oldBounds = isOpen ? NSValue(cgRect: startArcShapeBounds) : NSValue(cgRect: finalArcShapeBounds)
        let newBounds = isOpen ? NSValue(cgRect: finalArcShapeBounds) : NSValue(cgRect: startArcShapeBounds)

        let oldPosition = isOpen ? NSValue(cgPoint: startArcShapePosition) : NSValue(cgPoint: finalArcShapePosition)
        let newPosition = isOpen ? NSValue(cgPoint: finalArcShapePosition) : NSValue(cgPoint: startArcShapePosition)

        let oldPath = isOpen ? arcShapeStartPath.cgPath : arcShapeFinalPath.cgPath
        let newPath = isOpen ? arcShapeFinalPath.cgPath : arcShapeStartPath.cgPath

        let oldShadowPath = isOpen ? arcShapeStartPath.cgPath : arcShapeFinalPath.cgPath
        let newShadowPath = isOpen ? arcShapeFinalPath.cgPath : arcShapeStartPath.cgPath

        let animation = CALayer.groupAnimations(
            for: [
                #keyPath(CAShapeLayer.bounds): (from: oldBounds, to: newBounds),
                #keyPath(CAShapeLayer.position): (from: oldPosition, to: newPosition),
                #keyPath(CAShapeLayer.path): (from: oldPath, to: newPath),
                #keyPath(CAShapeLayer.shadowPath): (from: oldShadowPath, to: newShadowPath)],
            duration: max(duration - 0.2, 0.0))

        arcShapeLayer.bounds = newBounds.cgRectValue
        arcShapeLayer.position = newPosition.cgPointValue
        arcShapeLayer.path = newPath
        arcShapeLayer.shadowPath = newPath

        arcShapeLayer.add(animation, forKey: nil)
    }

    private func resizeClippingLayer(duration: TimeInterval) {
        let newPath = isOpen ? clippingFinalPath.cgPath : clippingStartPath.cgPath
        let oldPath = isOpen ? clippingStartPath.cgPath : clippingFinalPath.cgPath
        let keyPath = #keyPath(CAShapeLayer.path)
        let animation = CALayer.basicAnimation(for: keyPath, fromValue: oldPath, toValue: newPath, duration: duration)

        clippingLayer.path = newPath
        clippingLayer.add(animation, forKey: keyPath)
    }
}
