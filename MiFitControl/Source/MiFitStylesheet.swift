import UIKit

public enum MiFitStylesheet {

    enum FontFace: String {
        case rubikBold = "Rubik-Bold"
        case rubikRegular = "Rubik-Regular"
        case ralewayMedium = "Raleway-Medium"
        case ralewayRegular = "Raleway-Regular"
        case ralewayLight = "Raleway-Light"
    }

}

// MARK: - Helpers

extension MiFitStylesheet.FontFace {

    func fontWithSize(_ size: CGFloat) -> UIFont {
        guard let actualFont: UIFont = UIFont(name: self.rawValue, size: size) else {
            debugPrint("Can't load fon with name!!! \(self.rawValue)")
            return UIFont.systemFont(ofSize: size)
        }
        return actualFont
    }

    static func printAvailableFonts() {
        for name in UIFont.familyNames {
            debugPrint("<<<<<<< Font Family: \(name)")
            for fontName in UIFont.fontNames(forFamilyName: name) {
                debugPrint("Font Name: \(fontName)")
            }
        }
    }

}
