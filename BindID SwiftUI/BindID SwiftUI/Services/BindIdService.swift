//
//  BindIdService.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 7/9/21.
//

import Foundation
import XmBindIdSDK

public enum TokenKey: String {
    case bindIDNetworkInfo = "bindid_network_info"
    case bindIDInfo = "bindid_info"
    case sub = "sub"
    case bindIDAlias = "bindid_alias"
    case email = "email"
    case userRegistrationTime = "user_registration_time"
    case firstLogin = "capp_first_login"
    case firstConfirmedLogin = "capp_first_confirmed_login"
    case lastLogin = "capp_last_login"
    case userLastSeen = "user_last_seen"
    case confirmedCappCount = "confirmed_capp_count"
    case lastLoginFromAuthenticatedDevice = "capp_last_login_from_authenticating_device"
    case bindIDAppBoundCred = "ts.bindid.app_bound_cred"
    case authenticatedDeviceLastSeen = "authenticating_device_last_seen"
    case deviceCount = "device_count"
}

class BindIdService: ObservableObject {
    
    public enum SdkStatus {
        case unknown
        case ready
        case failed(XmBindIdError)
    }
    
    let sdk = XmBindIdSdk.shared
    private let jwtValidator = JWTValidator()
    
    @Published var sdkStatus = SdkStatus.unknown
    @Published var authenticationError: XmBindIdError?
    @Published var validationError: String?
    @Published var tokenResponse: XmBindIdExchangeTokenResponse?

    init() {
        
        let config = XmBindIdConfig(serverEnvironment: XmBindIdServerEnvironment(environmentMode: Environment.mode),
                                    clientId: Environment.bindIDClientID)

        XmBindIdSdk.shared.initialize(config: config) { [weak self] (_, error) in
            if let e = error {
                NSLog("Failed to initialize SDK: \(e.debugDescription)")
                self?.sdkStatus = .failed(e)
                // To troubleshoot errors, check out the docs: https://developer.bindid.io/docs/api/ios/XmBindIdErrorCode
            } else {
                NSLog("BindID SDK initialized successfully")
                self?.sdkStatus = .ready
            }
        }
    }
    
    func authenticate() {
        clear()
        let request = XmBindIdAuthenticationRequest(redirectUri: Environment.bindIDRedirectURI)
        request.usePkce = true // This enables using a PKCE flow (RFC-7636) to securely obtain the ID and access token through the client.
        request.scope = [.openId, .networkInfo, .email] // openId is the default configuration, you can also add .email, .networkInfo, .phone
        sdk.authenticate(bindIdRequestParams: request) { [weak self] (response, error) in
            if let error = error {
                self?.authenticationError = error
            } else if let requestResponse = response {
                self?.exchange(response: requestResponse)
            }
        }
    }
    
    func logout() {
        clear()
    }
    
    private func clear() {
        authenticationError = nil
        validationError = nil
        tokenResponse = nil
    }
    
    /**
     Exchange the authentication response for the ID and access token using a PKCE token exchange
     */
    private func exchange(response: XmBindIdResponse) {
        sdk.exchangeToken(exchangeRequest: XmBindIdExchangeTokenRequest(codeResponse: response)) { [weak self] (tokenResponse, error) in
            if let error = error {
                self?.authenticationError = error
            } else {
                self?.jwtValidator.validate(tokenResponse!.idToken) { [weak self] result in
                    switch result {
                    case .success:
                        self?.tokenResponse = tokenResponse
                    case .error(let message):
                        self?.validationError = message
                    }
                }
            }
        }
    }
}
