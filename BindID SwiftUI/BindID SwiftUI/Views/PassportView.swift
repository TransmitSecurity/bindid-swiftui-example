//
//  PassportView.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 7/13/21.
//

import SwiftUI

fileprivate struct PassportField: Identifiable {
    var id: String {
        get {
            "\(title)+\(subTitle)"
        }
    }
    let title: String
    let subTitle: String
}

fileprivate struct PassportFieldView: View {

    let field: PassportField

    var body: some View {
        VStack(alignment: .leading) {
            Text(field.title).bold()
            Text(field.subTitle)
        }
    }
}

struct PassportView: View {
    
    private var passport: [PassportField] = []
    private let notSet = "Not Set"
    private let noInfo = "No Info"

    init(tokenData: [String: Any]) {
        let networkInfo = tokenData[TokenKey.bindIDNetworkInfo] as? [String: Any]
        let bindIDInfo = tokenData[TokenKey.bindIDInfo] as? [String: Any]
        
        passport.append(PassportField(title: "User ID",
                                      subTitle: (tokenData[TokenKey.sub] as? String) ?? ""))
        
        passport.append(PassportField(title: "User Alias",
                                      subTitle: (tokenData[TokenKey.bindIDAlias] as? String) ?? notSet))
        
        passport.append(PassportField(title: "Email",
                                      subTitle: (tokenData[TokenKey.email] as? String) ?? notSet))
        
        passport.append(PassportField(title: "User Registered",
                                      subTitle: (networkInfo?[TokenKey.userRegistrationTime] as? String) ?? noInfo))
        
        passport.append(PassportField(title: "User First Seen",
                                      subTitle: PassportView.formatTimestamp(bindIDInfo?[TokenKey.firstLogin] as? Double)))
        
        passport.append(PassportField(title: "User First Confirmed",
                                      subTitle: PassportView.formatTimestamp(bindIDInfo?[TokenKey.firstConfirmedLogin] as? Double)))
        
        passport.append(PassportField(title: "User Last Seen",
                                      subTitle: PassportView.formatTimestamp(bindIDInfo?[TokenKey.lastLogin] as? Double)))
        
        passport.append(PassportField(title: "User Last Seen by Network",
                                      subTitle: (networkInfo?[TokenKey.userLastSeen] as? String) ?? noInfo))
        
        passport.append(PassportField(title: "Total Providers that Confirmed User",
                                      subTitle: ("\((networkInfo?[TokenKey.confirmedCappCount] as? Int) ?? 0)")))
        
        passport.append(PassportField(title: "Authenticating Device Registered",
                                      subTitle: PassportView.formatTimestamp(bindIDInfo?[TokenKey.lastLoginFromAuthenticatedDevice] as? Double)))
        
        passport.append(PassportField(title: "Authenticating Device Confirmed",
                                      subTitle: ((tokenData["acr"] as? String ?? "")
                                                    .split(separator: " ", maxSplits: Int.max, omittingEmptySubsequences: true)
                                                    .contains(Substring(TokenKey.bindIDAppBoundCred.rawValue))
                                                    ? "Yes" : "No")))
        
        passport.append(PassportField(title: "Authenticating Device Last Seen",
                                      subTitle: PassportView.formatTimestamp(bindIDInfo?[TokenKey.lastLoginFromAuthenticatedDevice] as? Double)))
        
        passport.append(PassportField(title: "Authenticating Device Last Seen by Network",
                                      subTitle: (networkInfo?[TokenKey.authenticatedDeviceLastSeen] as? String) ?? noInfo))
        
        passport.append(PassportField(title: "Total Known Devices",
                                      subTitle: ("\((networkInfo?[TokenKey.deviceCount] as? Int) ?? 0)")))
    }
    
    var body: some View {
        List(passport) {
            PassportFieldView(field: $0)
        }
    }
    
    private static func formatTimestamp(_ timestamp: Double?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d, yyyy"
        guard let date = timestamp?.date else { return "Never" }
        return dateFormatter.string(from: date)
    }
}
