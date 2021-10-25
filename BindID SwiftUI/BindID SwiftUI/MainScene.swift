//
//  MainScene.swift
//  BindID SwiftUI
//
//  Created by Transmit Security on 7/8/21.
//

import SwiftUI
import XmBindIdSDK

@main
struct MainScene: App {
    
    private let bindIdService = BindIdService()
    
    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(bindIdService)
        }
    }
}
