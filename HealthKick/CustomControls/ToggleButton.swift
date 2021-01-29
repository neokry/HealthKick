//
//  ToggleButton.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/26/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

protocol FilterItem: ExpressibleByStringLiteral, Equatable {
    var rawString: String?

    init() {
        rawString = nil
    }

    init(stringLiteral value: String) {
        rawString = value
    }
    init(extendedGraphemeClusterLiteral value: String) {
        rawString = value
    }
    init(unicodeScalarLiteral value: String) {
        rawString = value
    }
}

struct ToggleButton<T: FilterItem>: View {
    @Binding var list: [T]
    var item: T

    var body: some View {
        Button( action: {
            if self.list.contains(self.item) {
                self.list.remove(object: self.item)
            } else {
                self.list.append(self.item)
            }

        }) {
            HStack {
                Image(systemName: (self.list.contains(item)) ? "checkmark.square" : "square")
                Text(item.rawValue)
            }
        }
    }
}
