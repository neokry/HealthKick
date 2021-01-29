//
//  LoadingView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 7/2/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @State private var size: CGFloat = 0
    var text: String

    var body: some View {
        Rectangle()
            .fill(Color.green)
            .frame(width: size, height: 5.0)
            .onAppear(perform: {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                    if self.size == 300 {
                        self.size = 0
                    } else {
                        self.size = 300
                    }
                }
            })
    }
}
