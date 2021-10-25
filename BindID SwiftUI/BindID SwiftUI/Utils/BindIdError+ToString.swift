//
//  BindIdError+ToString.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 7/12/21.
//

import Foundation
import XmBindIdSDK

extension XmBindIdError {
    func toString() -> String {
        switch code {
        case .userCanceled: return "The user has canceled the authentication."
        case .internetConnection: return "Authentication failed. Please check your internet connection and try again."
        case .sdkNotInitialized: return "Authentication failed. The BindID SDK is not initialized."
        default: return message ?? ""
        }
    }
}
