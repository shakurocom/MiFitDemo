import UIKit

class MiFitPinView: UIView {

    private let innerCircle = CAShapeLayer()
    private let outerCircle = CAShapeLayer()

    private let innerSircleRadius: CGFloat = 16.0

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        innerCircle.fillColor = UIColor.white.cgColor

        outerCircle.lineWidth = 1.0
        outerCircle.strokeColor = UIColor.loadColorFromBundle(name: "mifit")?.cgColor
        outerCircle.fillColor = UIColor.loadColorFromBundle(name: "mifit")?.withAlphaComponent(0.1).cgColor
        outerCircle.lineCap = .round

        layer.addSublayer(outerCircle)
        layer.addSublayer(innerCircle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        innerCircle.frame = bounds
        outerCircle.frame = bounds

        let innerCircleFrame = CGRect(
            x: (bounds.width - innerSircleRadius) * 0.5,
            y: (bounds.height - innerSircleRadius) * 0.5,
            width: innerSircleRadius,
            height: innerSircleRadius)

        innerCircle.path = UIBezierPath(ovalIn: innerCircleFrame).cgPath
        outerCircle.path = UIBezierPath(ovalIn: innerCircleFrame).cgPath

        runPinAnimation()
    }
}

private extension MiFitPinView {
    private func runPinAnimation() {
        let keyPath = "transform.scale"
        let scale = bounds.width / innerSircleRadius
        let animation = CALayer.basicAnimation(for: keyPath, fromValue: 1.0, toValue: scale, duration: 1.0)

        animation.autoreverses = true
        animation.repeatCount = .infinity

        outerCircle.add(animation, forKey: keyPath)
    }
}
