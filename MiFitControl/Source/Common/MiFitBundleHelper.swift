//
//  MiFitBundleHelper.swift
//

import Foundation
import UIKit

final class MiFitBundleHelper {

    /// Return the current bundle.
    static let bundle: Bundle = {
        let miFitBundle = Bundle(for: MiFitViewController.self)
        if let miFitBundleURL = miFitBundle.url(forResource: "MiFit", withExtension: "bundle"),
           let miFitBundleInternal = Bundle(url: miFitBundleURL) {
            return miFitBundleInternal
        } else {
            return miFitBundle
        }
    }()

    /// Registers the specified font from the bundle.
    /// - parameter name: font name.
    /// - parameter extension: font extensions.
    static func registerFont(name: String, fontExtension: String) {
        guard let fontURL = bundle.url(forResource: name, withExtension: fontExtension) else {
            debugPrint("Couldn't find font \(name)")
            return
        }
        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            debugPrint("Couldn't load data from the font \(name)")
            return
        }
        guard let font = CGFont(fontDataProvider) else {
            debugPrint("Couldn't create font(\(name)) from data")
            return
        }
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            debugPrint("Error registering font(\(name)): maybe it was already registered.")
            return
        }
    }

    /// Registers the specified fonts from the bundle.
    static func registerFonts(_ fonts: [(fontName: String, fontExtension: String)]) {
        for font in fonts {
            registerFont(name: font.fontName, fontExtension: font.fontExtension)
        }
    }

    /// Reads an image with the specified name from the bundle.
    /// - parameter named: image name.
    static func readImage(named: String) -> UIImage? {
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }

    /// Reads a color with the specified name from the bundle.
    /// - parameter named: color name.
    static func readColor(named: String) -> UIColor? {
        return UIColor(named: named, in: bundle, compatibleWith: nil)
    }

}
