//
//  GeometryGetter.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/18/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct GeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            Group { () -> AnyView in
                DispatchQueue.main.async {
                    self.rect = geometry.frame(in: .global)
                }

                return AnyView(Color.clear)
            }
        }
    }
}
