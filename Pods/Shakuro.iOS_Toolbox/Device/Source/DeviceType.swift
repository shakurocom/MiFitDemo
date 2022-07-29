//
// original was created by Johannes Schickling on 7/20/15
// https://github.com/schickling/Device.swift/blob/master/Device/UIDeviceExtension.swift
// https://gist.github.com/adamawolf/3048717
// https://everymac.com/ultimate-mac-lookup/?search_keywords=iPad6%2C3
//
// Copyright (c) 2017 Shakuro (https://shakuro.com/)
// Sergey Laschuk
//

import Foundation
import UIKit

/// Enum representing the different types of iOS devices available
public enum DeviceType: CaseIterable {

    case iPhone2G

    case iPhone3G
    case iPhone3GS

    case iPhone4
    case iPhone4S

    case iPhone5
    case iPhone5C
    case iPhone5S

    case iPhone6
    case iPhone6Plus

    case iPhone6S
    case iPhone6SPlus

    case iPhoneSE

    case iPhone7
    case iPhone7Plus

    case iPhone8
    case iPhone8Plus

    case iPhoneX

    case iPhoneXS
    case iPhoneXSMax
    case iPhoneXR

    case iPhone11
    case iPhone11Pro
    case iPhone11ProMax

    case iPodTouch1G
    case iPodTouch2G
    case iPodTouch3G
    case iPodTouch4G
    case iPodTouch5G
    case iPodTouch6G
    case iPodTouch7G

    case iPad1G
    case iPad2G
    case iPad3G
    case iPad4G
    case iPad5G
    case iPad6G
    case iPad7G

    case iPadMini1G
    case iPadMini2G
    case iPadMini3G
    case iPadMini4G
    case iPadMini5G

    case iPadAir1G
    case iPadAir2G
    case iPadAir3G

    case iPadPro1G9p7Inch
    case iPadPro1G10p5Inch
    case iPadPro1G12p9Inch

    case iPadPro2G

    case iPadPro3G11Inch
    case iPadPro3G12p9Inch

    case appleWatch38mm
    case appleWatch42mm
    case appleWatch1S38mm
    case appleWatch1S42mm
    case appleWatch2S38mm
    case appleWatch2S42mm
    case appleWatch3S38mm
    case appleWatch3S42mm
    case appleWatch4S40mm
    case appleWatch4S44mm
    case appleWatch5S40mm
    case appleWatch5S44mm

    case simulator
    case notAvailable

}

public extension DeviceType {

    /**
     Returns the current device type
     */
    static var current: DeviceType {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""

        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        return DeviceType(identifier: identifier)
    }

    /**
     Returns the current model.
     For real devices this property will return same result as `current`.
     For Simulator it will return simulated device model.
     This property is supposed to never return `DeviceType.simulator` value - use `current` if you need to detect simulator.
     */
    static var model: DeviceType {
        var deviceType = DeviceType.current
        if deviceType == .simulator {
            deviceType = DeviceType(identifier: String(cString: getenv("SIMULATOR_MODEL_IDENTIFIER")))
        }
        return deviceType
    }

    /**
     Returns the display name of the device type
     */
    var displayName: String {
        switch self {
        case .iPhone2G: return "iPhone 2G"
        case .iPhone3G: return "iPhone 3G"
        case .iPhone3GS: return "iPhone 3GS"
        case .iPhone4: return "iPhone 4"
        case .iPhone4S: return "iPhone 4S"
        case .iPhone5: return "iPhone 5"
        case .iPhone5C: return "iPhone 5C"
        case .iPhone5S: return "iPhone 5S"
        case .iPhone6Plus: return "iPhone 6 Plus"
        case .iPhone6: return "iPhone 6"
        case .iPhone6S: return "iPhone 6S"
        case .iPhone6SPlus: return "iPhone 6S Plus"
        case .iPhoneSE: return "iPhone SE"
        case .iPhone7: return "iPhone 7"
        case .iPhone7Plus: return "iPhone 7 Plus"
        case .iPhone8: return "iPhone 8"
        case .iPhone8Plus: return "iPhone 8 Plus"
        case .iPhoneX: return "iPhone X"
        case .iPhoneXS: return "iPhone XS"
        case .iPhoneXSMax: return "iPhone XS Max"
        case .iPhoneXR: return "iPhone XR"
        case .iPhone11: return "iPhone 11"
        case .iPhone11Pro: return "iPhone 11 Pro"
        case .iPhone11ProMax: return "iPhone 11 Pro Max"
        case .iPodTouch1G: return "iPod Touch 1G"
        case .iPodTouch2G: return "iPod Touch 2G"
        case .iPodTouch3G: return "iPod Touch 3G"
        case .iPodTouch4G: return "iPod Touch 4G"
        case .iPodTouch5G: return "iPod Touch 5G"
        case .iPodTouch6G: return "iPod Touch 6G"
        case .iPodTouch7G: return "iPod Touch 7G"
        case .iPad1G: return "iPad 1G"
        case .iPad2G: return "iPad 2G"
        case .iPad3G: return "iPad 3G"
        case .iPad4G: return "iPad 4G"
        case .iPad5G: return "iPad 5G"
        case .iPad6G: return "iPad 6G"
        case .iPad7G: return "iPad 7G"
        case .iPadMini1G: return "iPad Mini"
        case .iPadMini2G: return "iPad Mini 2 Retina"
        case .iPadMini3G: return "iPad Mini 3"
        case .iPadMini4G: return "iPad Mini 4"
        case .iPadMini5G: return "iPad Mini 5"
        case .iPadAir1G: return "iPad Air"
        case .iPadAir2G: return "iPad Air 2"
        case .iPadAir3G: return "iPad Air 3"
        case .iPadPro1G9p7Inch: return "iPad Pro 9.7 inch"
        case .iPadPro1G10p5Inch: return "iPad Pro 10.5 inch"
        case .iPadPro1G12p9Inch: return "iPad Pro 12.9 inch"
        case .iPadPro2G: return "iPad Pro 2G"
        case .iPadPro3G11Inch: return "iPad Pro 3G 11 inch"
        case .iPadPro3G12p9Inch: return "iPad Pro 3G 12.9 inch"
        case .appleWatch38mm: return "Apple Watch 38mm case"
        case .appleWatch42mm: return "Apple Watch 42mm case"
        case .appleWatch1S38mm: return "Apple Watch Series 1 38mm case"
        case .appleWatch1S42mm: return "Apple Watch Series 1 42mm case"
        case .appleWatch2S38mm: return "Apple Watch Series 2 38mm case"
        case .appleWatch2S42mm: return "Apple Watch Series 2 42mm case"
        case .appleWatch3S38mm: return "Apple Watch Series 3 38mm case"
        case .appleWatch3S42mm: return "Apple Watch Series 3 42mm case"
        case .appleWatch4S40mm: return "Apple Watch Series 4 40mm case"
        case .appleWatch4S44mm: return "Apple Watch Series 4 44mm case"
        case .appleWatch5S40mm: return "Apple Watch Series 5 40mm case"
        case .appleWatch5S44mm: return "Apple Watch Series 5 44mm case"
        case .simulator: return "Simulator"
        case .notAvailable: return "Not Available"
        }
    }

    var identifiers: [String] {
        switch self {
        case .notAvailable: return []
        case .simulator: return ["i386", "x86_64"]

        case .iPhone2G: return ["iPhone1,1"]
        case .iPhone3G: return ["iPhone1,2"]
        case .iPhone3GS: return ["iPhone2,1"]
        case .iPhone4: return ["iPhone3,1", "iPhone3,2", "iPhone3,3"]
        case .iPhone4S: return ["iPhone4,1"]
        case .iPhone5: return ["iPhone5,1", "iPhone5,2"]
        case .iPhone5C: return ["iPhone5,3", "iPhone5,4"]
        case .iPhone5S: return ["iPhone6,1", "iPhone6,2"]
        case .iPhone6: return ["iPhone7,2"]
        case .iPhone6Plus: return ["iPhone7,1"]
        case .iPhone6S: return ["iPhone8,1"]
        case .iPhone6SPlus: return ["iPhone8,2"]
        case .iPhoneSE: return ["iPhone8,4"]
        case .iPhone7: return ["iPhone9,1", "iPhone9,3"]
        case .iPhone7Plus: return ["iPhone9,2", "iPhone9,4"]
        case .iPhone8: return ["iPhone10,1", "iPhone10,4"]
        case .iPhone8Plus: return ["iPhone10,2", "iPhone10,5"]
        case .iPhoneX: return ["iPhone10,3", "iPhone10,6"]
        case .iPhoneXS: return ["iPhone11,2"]
        case .iPhoneXSMax: return ["iPhone11,4", "iPhone11,6"]
        case .iPhoneXR: return ["iPhone11,8"]
        case .iPhone11: return ["iPhone12,1"]
        case .iPhone11Pro: return ["iPhone12,3"]
        case .iPhone11ProMax: return ["iPhone12,5"]

        case .iPodTouch1G: return ["iPod1,1"]
        case .iPodTouch2G: return ["iPod2,1"]
        case .iPodTouch3G: return ["iPod3,1"]
        case .iPodTouch4G: return ["iPod4,1"]
        case .iPodTouch5G: return ["iPod5,1"]
        case .iPodTouch6G: return ["iPod7,1"]
        case .iPodTouch7G: return ["iPod9,1"]

        case .iPad1G: return ["iPad1,1", "iPad1,2"]
        case .iPad2G: return ["iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4"]
        case .iPad3G: return ["iPad3,1", "iPad3,2", "iPad3,3"]
        case .iPad4G: return ["iPad3,4", "iPad3,5", "iPad3,6"]
        case .iPad5G: return ["iPad6,11", "iPad6,12"]
        case .iPad6G: return ["iPad7,5", "iPad7,6"]
        case .iPad7G: return ["iPad7,11", "iPad7,12"]
        case .iPadMini1G: return ["iPad2,5", "iPad2,6", "iPad2,7"]
        case .iPadMini2G: return ["iPad4,4", "iPad4,5", "iPad4,6"]
        case .iPadMini3G: return ["iPad4,7", "iPad4,8", "iPad4,9"]
        case .iPadMini4G: return ["iPad5,1", "iPad5,2"]
        case .iPadMini5G: return ["iPad11,1", "iPad11,2"]
        case .iPadAir1G: return ["iPad4,1", "iPad4,2", "iPad4,3"]
        case .iPadAir2G: return ["iPad5,3", "iPad5,4"]
        case .iPadAir3G: return ["iPad11,3", "iPad11,4"]
        case .iPadPro1G9p7Inch: return ["iPad6,3", "iPad6,4"]
        case .iPadPro1G10p5Inch: return ["iPad7,3", "iPad7,4"]
        case .iPadPro1G12p9Inch: return ["iPad6,7", "iPad6,8"]
        case .iPadPro2G: return ["iPad7,1", "iPad7,2"]
        case .iPadPro3G11Inch: return ["iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4"]
        case .iPadPro3G12p9Inch: return ["iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8"]

        case .appleWatch38mm: return ["Watch1,1"]
        case .appleWatch42mm: return ["Watch1,2"]
        case .appleWatch1S38mm: return ["Watch2,6"]
        case .appleWatch1S42mm: return ["Watch2,7"]
        case .appleWatch2S38mm: return ["Watch2,3"]
        case .appleWatch2S42mm: return ["Watch2,4"]
        case .appleWatch3S38mm: return ["Watch3,1", "Watch3,3"]
        case .appleWatch3S42mm: return ["Watch3,2", "Watch3,4"]
        case .appleWatch4S40mm: return ["Watch4,1", "Watch4,3"]
        case .appleWatch4S44mm: return ["Watch4,2", "Watch4,4"]
        case .appleWatch5S40mm: return ["Watch5,1", "Watch5,3"]
        case .appleWatch5S44mm: return ["Watch5,2", "Watch5,4"]
        }
    }

    /** Creates a device type
     - parameter identifier: The identifier of the device
     - returns: The device type based on the provided identifier
     */
    private init(identifier: String) {
        var value: DeviceType?
        for device in DeviceType.allCases {
            for deviceId in device.identifiers where identifier == deviceId {
                value = device
                break
            }
        }
        if let realValue = value {
            self = realValue
        } else {
            self = .notAvailable
        }
    }

}
