//
//  UserView.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 7/9/21.
//

import SwiftUI

struct UserView: View {
    
    @EnvironmentObject var bindIdService: BindIdService

    var body: some View {
        NavigationView {
            Group {
                if let idToken = bindIdService.tokenResponse?.idToken,
                   let tokenData = try? JWTDecoder().decodePayload(idToken) {
                    PassportView(tokenData: tokenData)
                } else {
                    Text("No user info")
                }
            }.navigationBarTitle("User Passport").toolbar {
                Button("Done") {
                    bindIdService.logout()
                }
            }
        }
    }
}
