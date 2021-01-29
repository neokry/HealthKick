//
//  UITabBarWrapper.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/14/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//
import SwiftUI
import Foundation
import UIKit

struct UITabBarWrapper: View {
    var controllers: [UIHostingController<TabBarElement>] // 1

    init(_ elements: [TabBarElement]) {
        self.controllers = elements.enumerated().map { // 2
            let hostingController = UIHostingController(rootView: $1)

            hostingController.tabBarItem = UITabBarItem( // 3
                title: $1.tabBarElementItem.title,
                image: UIImage.init(systemName: $1.tabBarElementItem.systemImageName),
                tag: $0 // 4
            )

            return hostingController
        }
    }

    var body: some View {
        EmptyView()
        //UITabBarControllerWrapper(viewControllers: self.controllers) // 5
    }
}

struct UITabBarWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UITabBarWrapper([
            TabBarElement(tabBarElementItem:
                TabBarElementItem(title: "Test 1", systemImageName: "house.fill")) {
                    Text("Test 1 Text")
            }
        ])
    }
}
