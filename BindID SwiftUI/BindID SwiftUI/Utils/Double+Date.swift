//
//  Double+Date.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 7/16/21.
//

import Foundation

extension Double {
    var date: Date? {
        return Date(timeIntervalSince1970: self)
    }
}
