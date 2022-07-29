//
// Copyright (c) 2020 Shakuro (https://shakuro.com/)
// Sergey Laschuk
//

import AudioToolbox
import Foundation
import UIKit

//TODO: add example
/// Instanceble because new styles require preparation (done in init) to be able to play without delay.
public class VibrationGenerator {

    /// Preferrable. Supported on iPhone 7 and above AND iOS 10+
    public enum NewStyle {
        case error
        case success
        case warning
        case light
        case medium
        case heavy
        case selection
    }

    /// Supported everywhere.
    public enum OldStyle {
        /// default type of vibration
        case defaultVibration

        /// weak boom
        case peek

        /// strong boom
        case pop

        /// series of three weak booms
        case nope
    }

    private let newStyleGenerator: GeneratorWrapper?
    private let oldStyle: OldStyle?

    // MARK: - Initialization

    /// - parameter newStyle: style of vibration on newer devices. Preferable to use this.
    /// - parameter oldStyle: style of vibration on older devices. Used if `newStyle` is not provided or not supported.
    public init(newStyle: NewStyle?, oldStyle: OldStyle?) {
        self.oldStyle = oldStyle
        if let realNewStyle = newStyle, VibrationGenerator.isNewStyleSupported() {
            newStyleGenerator = GeneratorWrapper(style: realNewStyle)
        } else {
            newStyleGenerator = nil
        }
    }

    // MARK: - Public

    public func prepare() {
        newStyleGenerator?.prepare()
    }

    public func vibrate() {
        if let generator = newStyleGenerator {
            generator.vibrate()
        } else if let realOldStyle = oldStyle {
            switch realOldStyle {
            case .defaultVibration:
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            case .peek:
                AudioServicesPlaySystemSound(1519) // Actuate "Peek" feedback (weak boom)
            case .pop:
                AudioServicesPlaySystemSound(1520) // Actuate "Pop" feedback (strong boom)
            case .nope:
                AudioServicesPlaySystemSound(1521) // Actuate "Nope" feedback (series of three weak booms)
            }
        }
    }

    // MARK: - Private

    private static func isNewStyleSupported() -> Bool {
        // NOTE: currently there is no proper way (without private APIs) to solve this:
        //      https://stackoverflow.com/questions/41444274/how-to-check-if-haptic-engine-uifeedbackgenerator-is-supported
        switch DeviceType.current {
        case .iPhone2G, .iPhone3G, .iPhone3GS, .iPhone4, .iPhone4S, .iPhone5, .iPhone5C, .iPhone5S, .iPhone6, .iPhone6Plus, .iPhoneSE,
             .iPhone6S, .iPhone6SPlus,
             .iPodTouch1G, .iPodTouch2G, .iPodTouch3G, .iPodTouch4G, .iPodTouch5G, .iPodTouch6G,
             .iPad1G, .iPad2G, .iPad3G, .iPad4G,
             .iPadMini1G, .iPadMini2G, .iPadMini3G, .iPadMini4G,
             .iPadAir1G, .iPadAir2G,
             .iPadPro1G9p7Inch, .iPadPro1G10p5Inch, .iPadPro1G12p9Inch, .iPadPro2G,
             .simulator,
             .notAvailable:
            return false

        case .iPodTouch7G,
             .iPad5G, .iPad6G, .iPad7G,
             .iPadMini5G, .iPadAir3G,
             .appleWatch38mm, .appleWatch42mm, .appleWatch1S38mm, .appleWatch1S42mm, .appleWatch2S38mm, .appleWatch2S42mm, .appleWatch3S38mm,
             .appleWatch3S42mm, .appleWatch4S40mm, .appleWatch4S44mm, .appleWatch5S40mm, .appleWatch5S44mm,
             .iPadPro3G11Inch, .iPadPro3G12p9Inch:
            // should be, but untested
            return false

        case .iPhone7, .iPhone7Plus, .iPhone8, .iPhone8Plus, .iPhoneX, .iPhoneXS, .iPhoneXSMax, .iPhoneXR, .iPhone11, .iPhone11Pro, .iPhone11ProMax:
            return true
        }
    }

}

private class GeneratorWrapper {

    private let style: VibrationGenerator.NewStyle
    private let notificationGenerator: UINotificationFeedbackGenerator?
    private let impactGenerator: UIImpactFeedbackGenerator?
    private let selectionGenerator: UISelectionFeedbackGenerator?

    internal init(style: VibrationGenerator.NewStyle) {
        self.style = style
        switch style {
        case .error,
             .success,
             .warning:
            self.notificationGenerator = UINotificationFeedbackGenerator()
            self.impactGenerator = nil
            self.selectionGenerator = nil
        case .light:
            self.notificationGenerator = nil
            self.impactGenerator = UIImpactFeedbackGenerator(style: .light)
            self.selectionGenerator = nil
        case .medium:
            self.notificationGenerator = nil
            self.impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            self.selectionGenerator = nil
        case .heavy:
            self.notificationGenerator = nil
            self.impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
            self.selectionGenerator = nil
        case .selection:
            self.notificationGenerator = nil
            self.impactGenerator = nil
            self.selectionGenerator = UISelectionFeedbackGenerator()
        }
    }

    internal func vibrate() {
        switch style {
        case .error: notificationGenerator?.notificationOccurred(.error)
        case .success: notificationGenerator?.notificationOccurred(.success)
        case .warning: notificationGenerator?.notificationOccurred(.warning)
        case .light,
             .medium,
             .heavy: impactGenerator?.impactOccurred()
        case .selection:
            selectionGenerator?.selectionChanged()
        }
    }

    internal func prepare() {
        notificationGenerator?.prepare()
        impactGenerator?.prepare()
        selectionGenerator?.prepare()
    }

}
