//
//  Dictionary+RawValue.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 10/18/21.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == String {
        get {
            return self[index.rawValue as! Key]
        }

        set {
            self[index.rawValue as! Key] = newValue
        }
    }
}
