VSSharedKeychain
============


VSSharedKeychain is a simple Swift class that finds, adds and removes items from a shared Keychain.


Installation
============


Add `VSSharedKeychain.swift` to your project.


Usage
=====

Set the variable `keychainAccessGroupName` to your shared Keychain group name.

```
VSSharedKeychain.keychainAccessGroupName = "THIS_IS_YOUR_SHARED_KEYCHAIN_GROUP_NAME"
```

Use the class method `findSharedKeychainItem` to find and return a String value for a key.

```
let value = VSSharedKeychain.findSharedKeychainItem(itemKey: "username", serviceName: "serviceName")
```

Use the class method `addSharedKeychainItem` to add a value for a key.

```
VSSharedKeychain.addSharedKeychainItem(itemKey: "username", itemValue: "value", serviceName: "serviceName")
```

Use the class method `deleteSharedKeychainItem` to delete a value for a key.

```
VSSharedKeychain.deleteSharedKeychainItem(itemKey: "username", serviceName: "serviceName")
```
