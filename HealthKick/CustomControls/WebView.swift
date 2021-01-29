//
//  WebView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/28/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Foundation
import WebKit

struct WebView: UIViewRepresentable {
    var urlString: String

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.urlString) else {
            return WKWebView()
        }

        let request = URLRequest(url: url)
        let webView = WKWebView()
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {

    }

}
