//
//  GoogleSIgnIn.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/28/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInView: UIViewRepresentable {

    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.colorScheme = .light
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        return button
    }

    func updateUIView(_ uiView: GIDSignInButton, context: Context) {

    }
}
