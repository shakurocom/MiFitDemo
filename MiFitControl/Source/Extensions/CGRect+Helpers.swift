import UIKit

extension CGRect {
    func scalePos(_ xScale: CGFloat, _ yScale: CGFloat) -> CGRect {
        return CGRect(x: origin.x * xScale, y: origin.y * yScale, width: width, height: height)
    }
}
