//
//  UIImage+Bundle.swift
//  Thermostat
//
//  Created by Eugene Klyuenkov on 17.06.2022.
//

import UIKit

public extension UIImage {

    static func loadImageFromBundle(name: String) -> UIImage? {
        let podBundle = Bundle(for: MiFitViewController.self)
        if let url = podBundle.url(forResource: "MiFit", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: name, in: bundle, compatibleWith: nil)
        } else {
            return UIImage(named: name)
        }
    }

}
