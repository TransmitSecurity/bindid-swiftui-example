//
//  LoginView.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 7/8/21.
//

import SwiftUI
import XmBindIdSDK

struct ErrorMessage: View {
    
    let error: XmBindIdError
    
    var body: some View {
        Text(error.toString()).foregroundColor(.red)
    }
}

struct LoginView: View {
    
    @EnvironmentObject var bindIdService: BindIdService
    
    var body: some View {
        VStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Image("transmit_logo").resizable().scaledToFit()
            Spacer()
            switch bindIdService.sdkStatus {
            case .unknown:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(x: 4, y: 4, anchor: .center)
            case .ready:
                Button(action: {
                    bindIdService.authenticate()
                }, label: {
                    Text("Biometric Login").foregroundColor(.white)
                }).frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 27 / 255, green: 39 / 255, blue: 70 / 255))
                    .cornerRadius(12)
            case .failed(let error):
                VStack {
                    Text(error.message)
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
            Spacer()
            if let error = bindIdService.authenticationError {
                ErrorMessage(error: error)
            } else if let error = bindIdService.validationError {
                Text(error).foregroundColor(.red)
            }
            Spacer()
        }).padding()    }
}
