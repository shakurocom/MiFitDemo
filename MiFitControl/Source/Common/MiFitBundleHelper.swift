//
//  MiFitBundleHelper.swift
//

import Foundation
import UIKit
import Shakuro_CommonTypes

final class MiFitBundleHelper {

    /// Returns the current bundle.
    static let bundle: Bundle = {
        let miFitBundle = Bundle(for: MiFitViewController.self)
        if let miFitBundleURL = miFitBundle.url(forResource: "MiFit", withExtension: "bundle"),
           let miFitBundleInternal = Bundle(url: miFitBundleURL) {
            return miFitBundleInternal
        } else {
            return miFitBundle
        }
    }()

    private static let bundleHelper: BundleHelper = {
        let bundleHelper = BundleHelper(targetClass: MiFitViewController.self, bundleName: "MiFit")
        let fonts: [(fontName: String, fontExtension: String)] = [
            (fontName: "Raleway-Light", fontExtension: "ttf"),
            (fontName: "Raleway-Medium", fontExtension: "ttf"),
            (fontName: "Raleway-Regular", fontExtension: "ttf"),
            (fontName: "Rubik-Bold", fontExtension: "ttf"),
            (fontName: "Rubik-Regular", fontExtension: "ttf")
        ]
        bundleHelper.registerFonts(fonts)
        return bundleHelper
    }()

    /// Returns an image object using the named image asset that is compatible with the specified trait collection.
    /// - parameter named: image name.
    /// - parameter traitCollection: The traits associated with the intended environment for the image. Use this parameter to ensure that the correct variant of the image is loaded. If you specify nil, this method uses the traits associated with the main screen.
    static func image(named: String, compatibleWith: UITraitCollection? = nil) -> UIImage? {
        return bundleHelper.image(named: named, compatibleWith: compatibleWith)
    }

    /// Reads a color with the specified name from the bundle.
    /// - parameter named: color name.
    static func color(named: String, compatibleWith: UITraitCollection? = nil) -> UIColor? {
        return bundleHelper.color(named: named, compatibleWith: compatibleWith)
    }

    /**
     Returns instance of a UIViewController.

     - Parameters:
        - targetClass: View controller type,  that must be created.
        - nibName: The name of the nib file to associate with the view controller.
     - Returns: A newly initialized UIViewController object.

     - Example:
     `let exampleViewController: ExampleViewController = BundleHelper.instantiateViewControllerFromBundle(targetClass: ExampleViewController.type, nibName: "kExampleViewController")`
     */
    static func instantiateViewController<T>(targetClass: T.Type, nibName: String) -> T where T: UIViewController {
        return bundleHelper.instantiateViewController(targetClass: targetClass, nibName: nibName)
    }

}
