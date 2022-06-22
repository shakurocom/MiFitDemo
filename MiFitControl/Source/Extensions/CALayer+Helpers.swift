import UIKit

extension CALayer {
    class func basicAnimation(for keyPath: String, fromValue: Any, toValue: Any, duration: TimeInterval, valueFunction: CAValueFunction? = nil) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)

        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.duration = duration
        animation.valueFunction = valueFunction

        return animation
    }

    class func keyFrameAnimation(for keyPath: String, values: [Any], duration: TimeInterval, valueFunction: CAValueFunction? = nil) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)

        animation.values = values
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.duration = duration
        animation.valueFunction = valueFunction

        return animation
    }

    class func groupAnimations(for animationDesc: [String: (from: Any, to: Any)], duration: TimeInterval) -> CAAnimationGroup {
        let animation = CAAnimationGroup()

        animation.duration = duration
        animation.animations = animationDesc.enumerated().compactMap({ (_, desc) in
            return basicAnimation(for: desc.key, fromValue: desc.value.from, toValue: desc.value.to, duration: 0.0)
        })

        return animation
    }
}
