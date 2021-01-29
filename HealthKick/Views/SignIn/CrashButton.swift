//
//  CrashButton.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/28/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import SwiftUI
import Crashlytics

struct CrashButton: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIButton {
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("Crash", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: some UIView, context: Context) {

    }

    func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
}
