//
//  VSSharedKeychain.swift
//
//  Created by PJ Vea on 8/29/17.
//  Copyright © 2017 Vea Software. All rights reserved.
//

class VSSharedKeychain: NSObject {
    
    static var keychainAccessGroupName: String = {
        return ""
    }()
    
    static var environmentKeyPrefix: String = {
        #if DEBUG
            return "-DEBUG"
        #elseif BETA
            return "-BETA"
        #elseif ALPHA
            return "-ALPHA"
        #else
            return "-RELEASE"
        #endif
    }()
    
    @objc static func findSharedKeychainItem(itemKey: String) -> String? {
        let key = itemKey + self.environmentKeyPrefix
        let queryLoad: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: self.keychainAccessGroupName as AnyObject
        ]
        
        var result: AnyObject?
        
        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if resultCodeLoad == noErr {
            if let result = result as? Data, let keyValue = NSString(data: result, encoding: String.Encoding.utf8.rawValue) as String? {
                return keyValue
            }
        }
        return nil
    }
    
    @objc static func addSharedKeychainItem(itemKey: String, itemValue: String) {
        let key = itemKey + self.environmentKeyPrefix
        if self.findSharedKeychainItem(itemKey: itemKey) != nil {
            self.deleteSharedKeychainItem(itemKey: itemKey)
        }
        
        guard let valueData = itemValue.data(using: String.Encoding.utf8) else {
            print("Error saving String to Keychain.")
            return
        }
        
        let queryAdd: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key as AnyObject,
            kSecValueData as String: valueData as AnyObject,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecAttrAccessGroup as String: self.keychainAccessGroupName as AnyObject
        ]
        
        let resultCode = SecItemAdd(queryAdd as CFDictionary, nil)
        
        if resultCode != noErr {
            print("Error saving to Keychain: \(resultCode)")
        }
    }
    
    @objc static func deleteSharedKeychainItem(itemKey: String) {
        let key = itemKey + self.environmentKeyPrefix
        let queryDelete: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key as AnyObject,
            kSecAttrAccessGroup as String: self.keychainAccessGroupName as AnyObject
        ]
        
        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)
        
        if resultCodeDelete != noErr {
            print("Error deleting from Keychain: \(resultCodeDelete)")
        }
    }
}
