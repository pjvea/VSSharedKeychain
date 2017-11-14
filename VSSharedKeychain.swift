//
//  VSSharedKeychain.swift
//
//  Created by PJ Vea on 8/29/17.
//  Copyright © 2017 Vea Software. All rights reserved.
//

open class VSSharedKeychain: NSObject {
    
    @objc public static var keychainAccessGroupName: String = {
        return ""
    }()
    
    @objc public static var environmentKeyPrefix: String = {
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
    
    @objc public static func findSharedKeychainItem(itemKey: String, serviceName: String) -> String? {
        let key = itemKey + self.environmentKeyPrefix
        
        let queryLoad: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: self.keychainAccessGroupName as AnyObject,
            kSecAttrService as String: serviceName as AnyObject
        ]
        
        var result: AnyObject?
        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if let err = mapResultCode(result: resultCodeLoad) {
            switch err {
            case .itemNotFound:
                break
            default:
                inform("Error parsing keychain result: \(err)")
            }
        }
        
        guard let resultVal = result as? NSData, let keyValue = NSString(data: resultVal as Data, encoding: String.Encoding.utf8.rawValue) as? String else {
            inform("Error parsing keychain result: \(resultCodeLoad)")
            return nil
        }
        return keyValue
    }
    
    @objc public static func addSharedKeychainItem(itemKey: String, itemValue: String, serviceName: String) {
        
        let key = itemKey + self.environmentKeyPrefix
        self.deleteSharedKeychainItem(itemKey: itemKey, serviceName: serviceName)
        
        guard let valueData = itemValue.data(using: String.Encoding.utf8) else {
            inform(KeychainError.invalidInput.localizedDescription)
            return
        }
        
        let queryAdd: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key as AnyObject,
            kSecValueData as String: valueData as AnyObject,
            kSecAttrAccessible as String: kSecAttrAccessibleAlways,
            kSecAttrAccessGroup as String: self.keychainAccessGroupName as AnyObject,
            kSecAttrService as String: serviceName  as AnyObject
        ]
        
        let resultCode = SecItemAdd(queryAdd as CFDictionary, nil)
        
        if let err = mapResultCode(result: resultCode) {
            inform("Error saving to Keychain: \(err)")
        }
    }
    
    @objc public static func deleteSharedKeychainItem(itemKey: String, serviceName: String) {
        let key = itemKey + self.environmentKeyPrefix
        let queryDelete: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key as AnyObject
        ]
        
        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)
        
        if let err = mapResultCode(result: resultCodeDelete) {
            inform("Error deleting to Keychain: \(err)")
        }
    }
    
    private enum KeychainError: Error {
        case invalidInput // If the value cannot be encoded as NSData
        case operationUnimplemented // -4 | errSecUnimplemented
        case invalidParam // -50 | errSecParam
        case memoryAllocationFailure // -108 | errSecAllocate
        case trustResultsUnavailable // -25291 | errSecNotAvailable
        case authFailed // -25293 | errSecAuthFailed
        case duplicateItem // -25299 | errSecDuplicateItem
        case itemNotFound // -25300 | errSecItemNotFound
        case serverInteractionNotAllowed // -25308 | errSecInteractionNotAllowed
        case decodeError // - 26275 | errSecDecode
        case unknown(Int) // Another error code not defined
    }
    
    private static func mapResultCode(result:OSStatus) -> KeychainError? {
        switch result {
        case 0:
            return nil
        case -4:
            return .operationUnimplemented
        case -50:
            return .invalidParam
        case -108:
            return .memoryAllocationFailure
        case -25291:
            return .trustResultsUnavailable
        case -25293:
            return .authFailed
        case -25299:
            return .duplicateItem
        case -25300:
            return .itemNotFound
        case -25308:
            return .serverInteractionNotAllowed
        case -26275:
            return .decodeError
        default:
            return .unknown(result.hashValue)
        }
    }
}
