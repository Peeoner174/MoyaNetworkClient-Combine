//
//  Dictionary+KeyPath.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//


import Foundation

/// This protocol is used as workaround over dict key as object conforming to StringProtocol
public protocol StringProtocol {

    /// This creates a StingProtocol conformed object
    ///
    /// - Parameter s: A string value that is assigned to self
    init(string input: String)
}

extension String: StringProtocol {

    /// The given String value is assigned to self
    ///
    /// - Parameter s: The new String Value
    public init(string input: String) {
        self = input
    }
}

// MARK: DictionaryKeyPath struct
/**
 This acts as the string key that is given to the subscript action of Dictionary extension.
 ### Usage Example: ###
 ````
 sample["test.value"]
 ````
 */
public struct DictionaryKeyPath {

    /// This acts as the storage for the actual given key
    var keyPathString: String

    /// The keypath as string value that is '.' separated
    ///
    /// - Parameter stringKey: The '.' separated keys as keypath
    init(_ stringKey: String) {
        keyPathString = stringKey
    }

    /// The keypath as array of string values
    ///
    /// - Parameter keys: The array of string containing individual keys
    fileprivate init(_ keys: [String]) {
        keyPathString = keys.joined(separator: ".")
    }

    /// To check if the keypath is empty
    fileprivate var isEmpty: Bool {
        return keyPathString.isEmpty
    }
}

// MARK: - DictionaryKeyPath extension with secondary functions
public extension DictionaryKeyPath {

    /**
     This method extracts the first key and creates a keypath object out of it,
     the rest is used to created another keypath object with keys joined with '.'
     #### Sample input and output ####
     ````
     input1 : "test1.test2.test3"
     output : (DictionaryKeyPath("test1"), DictionaryKeyPath("test2.test3"))
     ````
     - Returns: A tuple containing two keypath objects
     */
    fileprivate func extract() -> (DictionaryKeyPath, DictionaryKeyPath) {
        var keys = self.keyPathString.components(separatedBy: ".")
        return (DictionaryKeyPath(keys.removeFirst()), DictionaryKeyPath(keys))
    }
}

// MARK: - Conforming to ExpressibleByStringLiteral
extension DictionaryKeyPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

// MARK: - Extension contains overloaded subscript method
extension Dictionary where Key: StringProtocol {

    /**
     - Parameter keyPath: A Keypath object which conforms to ExpressibleByStringLiteral
     #### sample Usage ####
     ````
     // to set a variable
     dict[keyPath: "test.value"] = "Omega"
     // to read the value the following
     // subscript can be used
     dict[keyPath: "test.value"] // Omega
     ````
     - Returns: The Some(object) stored in the dictionary for the given keypath
     */
    public subscript(keyPath keyPath: DictionaryKeyPath) -> Any? {

        get {
            let (key, restKey) = keyPath.extract()
            guard !key.isEmpty else {
                return nil
            }

            if let value = self[Key(string: key.keyPathString)] {
                if restKey.isEmpty {
                    return value
                } else if let valueDict = value as? [Key: Value] {
                    return valueDict[keyPath: restKey]
                }
            }

            return nil
        }

        set {

            let (key, restKey) = keyPath.extract()

            guard !key.isEmpty else {
                return
            }

            if let value = self[Key(string: key.keyPathString)] {
                if restKey.isEmpty {
                    self[Key(string: key.keyPathString)] =  newValue as? Value
                } else if var valDict  = value as? [Key: Any] {
                    valDict[keyPath: restKey] = newValue
                    self[Key(string: key.keyPathString)] = valDict as? Value
                }
            }
        }
    }
}

// MARK: - Convenience subscript methods to prevent type conversions
extension Dictionary where Key: StringProtocol {

    /// The subscript can be used if we want to return the value as string
    ///
    /// - Parameter keyPath: The keypath pointing to the string resource within the dict
    public subscript(string keyPath: DictionaryKeyPath) -> String? {
        get { return self[keyPath: keyPath] as? String }
        set { self[keyPath: keyPath] = newValue }
    }

    /// The subscript can be used if we want to return the value as boolean
    ///
    /// - Parameter keyPath: The keypath pointing to the string resource within the dict
    public subscript(bool keyPath: DictionaryKeyPath) -> Bool? {
        get { return (self[keyPath: keyPath] as? Bool) ?? nil }
        set { self[keyPath: keyPath] = newValue }
    }

    /// The subscript can be used if we want to return the value as Int
    ///
    /// - Parameter keyPath: The keypath pointing to the string resource within the dict
    public subscript(int keyPath: DictionaryKeyPath) -> Int? {
        get { return (self[keyPath: keyPath] as? Int) }
        set { self[keyPath: keyPath] = newValue }
    }

    /// The subscript can be used if we want to return the value as Double
    ///
    /// - Parameter keyPath: The keypath pointing to the string resource within the dict
    public subscript(double keyPath: DictionaryKeyPath) -> Double? {
        get { return (self[keyPath: keyPath] as? Double) }
        set { self[keyPath: keyPath] = newValue }
    }

    /// The subscript can be used if we want to return the value as a dict of type [Key: Any]
    ///
    /// - Parameter keyPath: The keypath pointing to the dict resource within the nested dict
    public subscript(dict keyPath: DictionaryKeyPath) -> [Key: Any]? {
        get { return self[keyPath: keyPath] as? [Key: Any] }
        set { self[keyPath: keyPath] = newValue }
    }

    /// The subscript can be used if we want to return the value as Any
    ///
    /// - Parameter keyPath: The keypath pointing to the dict resource within the nested dict
    public subscript(object keyPath: DictionaryKeyPath) -> Any? {
        get { return self[keyPath: keyPath] }
        set { self[keyPath: keyPath] = newValue }
    }

    /**
     The subscript can be used if we want to return the value as an array [Any].
     The reason for the type being [Any] is due to lack of generic support in subscripts
     #### USAGE NOTE ####
     ````
     var dict: [String: Any] = ["test": ["value": [1]]]
     // This is still valid and wont break since the array is of type [Any]
     dict[array: "test.value"]?.append("2")
     ````
     - Parameter keyPath: The keypath pointing to the array resource of type [Any] within the dict
     */
    public subscript(array keyPath: DictionaryKeyPath) -> [Any]? {
        get { return self[keyPath: keyPath] as? [Any] }
        set { self[keyPath: keyPath] = newValue }
    }
}
