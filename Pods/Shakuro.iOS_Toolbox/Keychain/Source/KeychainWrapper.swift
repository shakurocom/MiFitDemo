//
// Copyright (c) 2017-2020 Shakuro (https://shakuro.com/)
// Vlad Onipchenko
//

import Foundation

public class KeychainWrapper {

    /// Error for keychain action
    ///
    /// https://www.osstatus.com/
    ///
    /// OSStatus:
    ///     -25308 = errSecInteractionNotAllowed -> check kSecAttrAccessible
    ///     -25300 = errSecItemNotFound -> make sure you have proper provision profile and dev/dist certificate
    ///     -25303 = errSecNoSuchAttr ->            -//-
    public enum Error: Swift.Error {
        case unexpectedKeychainItemData(queryResult: AnyObject?) // most probably can't decode sec value
        case cantEncodeSecValue(underlyingError: Swift.Error)
        case keychainError(osStatus: OSStatus)
    }

    public struct Item<T: Codable> {

        public var serviceName: String { return info.serviceName }
        public var account: String { return info.account }
        public var itemName: String? { return info.itemName }
        public var accessGroup: String? { return info.accessGroup }

        public let info: ItemInfo
        public let secValue: T

        public init(serviceName: String, account: String, itemName: String?, accessGroup: String?, secValue: T) {
            self.info = ItemInfo(serviceName: serviceName,
                                 account: account,
                                 itemName: itemName,
                                 accessGroup: accessGroup)
            self.secValue = secValue
        }

        public init(info: ItemInfo, secValue: T) {
            self.info = info
            self.secValue = secValue
        }

    }

    public struct ItemInfo {

        public let serviceName: String
        public let account: String
        public let itemName: String?
        public let accessGroup: String?

        public init(serviceName: String, account: String, itemName: String?, accessGroup: String?) {
            self.serviceName = serviceName
            self.account = account
            self.itemName = itemName
            self.accessGroup = accessGroup
        }
    }

    // MARK: - Public

    /// - parameter secAttrAccessible: Used only during save of a new item (not later update).
    ///         Default value is `kSecAttrAccessibleAfterFirstUnlock`.
    ///         See it's description for more information.
    ///         https://developer.apple.com/documentation/security/keychain_services/keychain_items/restricting_keychain_item_accessibility
    /// - throws: KeychainWrapper.Error
    public static func saveKeychainItem<T: Encodable>(_ item: KeychainWrapper.Item<T>,
                                                      secAttrAccessible: CFString = kSecAttrAccessibleAfterFirstUnlock) throws {
        let secValueData: Data
        do {
            secValueData = try JSONEncoder().encode(item.secValue)
        } catch let encodeError {
            throw KeychainWrapper.Error.cantEncodeSecValue(underlyingError: encodeError)
        }
        var searchQuery: [String: Any] = makeQuery(serviceName: item.serviceName, account: item.account, accessGroup: item.accessGroup)
        searchQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        var status = SecItemCopyMatching(searchQuery as CFDictionary, nil)

        switch status {
        case errSecItemNotFound:
            var newQuery: [String: Any] = makeQuery(serviceName: item.serviceName, account: item.account, accessGroup: item.accessGroup)
            newQuery[kSecAttrAccessible as String] = secAttrAccessible as String
            newQuery[kSecValueData as String] = secValueData
            if let itemName = item.itemName, let data = itemName.data(using: String.Encoding.utf8) {
                newQuery[kSecAttrGeneric as String] = data
            }
            status = SecItemAdd(newQuery as CFDictionary, nil)
            if status != noErr {
                throw KeychainWrapper.Error.keychainError(osStatus: status)
            }
        case noErr:
            let updateQuery: [String: Any] = makeQuery(serviceName: item.serviceName, account: item.account, accessGroup: item.accessGroup)
            var attributesToUpdate = [String: Any]()
            attributesToUpdate[kSecAttrAccessible as String] = secAttrAccessible as String
            attributesToUpdate[kSecValueData as String] = secValueData
            if let itemName = item.itemName, let data = itemName.data(using: String.Encoding.utf8) {
                attributesToUpdate[kSecAttrGeneric as String] = data
            }
            status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            if status != noErr {
                throw KeychainWrapper.Error.keychainError(osStatus: status)
            }
        default:
            throw KeychainWrapper.Error.keychainError(osStatus: status)
        }
    }

    /// - throws: KeychainWrapper.Error (-25300 errSecItemNotFound will be skipped)
    public static func removeKeychainItem(serviceName: String, account: String, accessGroup: String? = nil) throws {
        let searchQuery = makeQuery(serviceName: serviceName, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(searchQuery as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainWrapper.Error.keychainError(osStatus: status)
        }
    }

    /// - throws: KeychainWrapper.Error
    public static func keychainItem<T: Decodable>(serviceName: String,
                                                  account: String,
                                                  accessGroup: String? = nil) throws -> KeychainWrapper.Item<T>? {
        var result: KeychainWrapper.Item<T>?
        var searchQuery: [String: Any] = makeQuery(serviceName: serviceName, account: account, accessGroup: accessGroup)
        searchQuery[kSecReturnData as String] = kCFBooleanTrue
        searchQuery[kSecReturnAttributes as String] = kCFBooleanTrue
        searchQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &queryResult)
        switch status {
        case noErr:
            if let existingItem = queryResult as? [String: AnyObject],
                let serviceName = existingItem[kSecAttrService as String] as? String,
                let account = existingItem[kSecAttrAccount as String] as? String,
                let secValueData = existingItem[kSecValueData as String] as? Data,
                let secValue = try? JSONDecoder().decode(T.self, from: secValueData) {
                var itemName: String?
                if let itemNameData = existingItem[kSecAttrGeneric as String] as? Data {
                    itemName = String(data: itemNameData, encoding: String.Encoding.utf8)
                }
                var accessGroup: String?
                if let accessGroupValue = existingItem[kSecAttrAccessGroup as String] as? String {
                    accessGroup = accessGroupValue
                }
                result = KeychainWrapper.Item(serviceName: serviceName,
                                              account: account,
                                              itemName: itemName,
                                              accessGroup: accessGroup,
                                              secValue: secValue)
            } else {
                throw KeychainWrapper.Error.unexpectedKeychainItemData(queryResult: queryResult)
            }

        case errSecItemNotFound:
            result = nil

        default:
            throw KeychainWrapper.Error.keychainError(osStatus: status)
        }
        return result
    }

    /// Fetch items from keychain for given serviceName & accessGroup(optional)
    /// Any invalid items will be skipped.
    ///
    /// - throws: KeychainWrapper.Error
    public static func keychainItems<T: Decodable>(serviceName: String, accessGroup: String? = nil) throws -> [KeychainWrapper.Item<T>] {
        let info = try itemsInfo(serviceName: serviceName, accessGroup: accessGroup)
        let result: [KeychainWrapper.Item<T>] = info.compactMap { (itemInfo) -> KeychainWrapper.Item<T>? in
            return try? keychainItem(serviceName: itemInfo.serviceName, account: itemInfo.account, accessGroup: itemInfo.accessGroup)
        }
        return result
    }

    /// Fetch items info  from keychain for given serviceName & accessGroup(optional)
    /// Any invalid items will be skipped.
    ///
    /// - throws: KeychainWrapper.Error
    public static func itemsInfo(serviceName: String, accessGroup: String? = nil) throws -> [ItemInfo] {
        var searchQueryAdditionalAttributes: [String: Any] = [:]
        searchQueryAdditionalAttributes[kSecMatchLimit as String] = kSecMatchLimitAll
        searchQueryAdditionalAttributes[kSecReturnAttributes as String] = kCFBooleanTrue
        let searchQuery = makeQuery(serviceName: serviceName, accessGroup: accessGroup, additionalAttributes: searchQueryAdditionalAttributes)
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &queryResult)
        guard status == noErr, let items = queryResult as? [[String: AnyObject]] else {
            switch status {
            case errSecItemNotFound:
                return []
            case noErr:
                throw KeychainWrapper.Error.unexpectedKeychainItemData(queryResult: queryResult)
            default:
                throw KeychainWrapper.Error.keychainError(osStatus: status)
            }
        }

        let resultItems: [ItemInfo] = items.compactMap { (item) -> ItemInfo? in
            guard let serviceName = item[kSecAttrService as String] as? String,
                let account = item[kSecAttrAccount as String] as? String else {
                    return nil
            }
            var itemName: String?
            if let itemNameData = item[kSecAttrGeneric as String] as? Data {
                itemName = String(data: itemNameData, encoding: String.Encoding.utf8)
            }
            var accessGroup: String?
            if let accessGroupValue = item[kSecAttrAccessGroup as String] as? String {
                accessGroup = accessGroupValue
            }
            return ItemInfo(serviceName: serviceName,
                            account: account,
                            itemName: itemName,
                            accessGroup: accessGroup)
        }
        return resultItems
    }

    /// - throws: KeychainWrapper.Error
    public static func removeKeychainItems(serviceName: String, accessGroup: String? = nil) throws {
        let searchQuery = makeQuery(serviceName: serviceName, accessGroup: accessGroup)
        let status = SecItemDelete(searchQuery as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainWrapper.Error.keychainError(osStatus: status)
        }
    }

    // MARK: - Private

    private static func makeQuery(serviceName: String,
                                  account: String? = nil,
                                  accessGroup: String? = nil,
                                  additionalAttributes: [String: Any]? = nil) -> [String: Any] {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword as String
        query[kSecAttrService as String] = serviceName
        if let account = account {
            query[kSecAttrAccount as String] = account
        }
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        additionalAttributes?.forEach({ (entry) in
            query[entry.key] = entry.value
        })
        return query
    }

}
