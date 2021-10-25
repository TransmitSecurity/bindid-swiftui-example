//
//  AppView.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 7/9/21.
//

import SwiftUI

struct AppView: View {
    
    @EnvironmentObject var bindIdService: BindIdService

    var body: some View {
        if bindIdService.tokenResponse == nil {
            LoginView().environmentObject(bindIdService)
        } else {
            UserView().environmentObject(bindIdService)
        }
    }
}

