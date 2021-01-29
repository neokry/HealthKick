//
//  CheckBoxList.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/26/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct CheckBoxList<T: RawRepresentable, CaseIterable, Hashable>: View {
    @Binding var list: [T]

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Text("Diet")
                ForEach(list, id: \.self) { diet in
                    Button( action: {
                        if self.filter.selectedDiets.contains(diet) {
                            self.filter.selectedDiets.remove(object: diet)
                        } else {
                            self.filter.selectedDiets.append(diet)
                        }

                    }) {
                        HStack {
                            Image(systemName: (list.contains(diet as! T)) ? "checkmark.square" : "square")
                            Text(diet.rawValue)
                        }
                    }
                }
            }
        }
    }
}
