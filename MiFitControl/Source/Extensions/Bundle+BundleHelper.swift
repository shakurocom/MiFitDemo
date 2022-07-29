//
//  Bundle+BundleHelper.swift
//

import Foundation
import Shakuro_CommonTypes

extension Bundle {
    
    static let miFitBundleHelper: BundleHelper = {
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

}
