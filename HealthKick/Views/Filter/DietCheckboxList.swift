//
//  DietCheckboxList.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/26/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct DietCheckboxList: View {
    @Binding var selectedDiet: diet?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Diets")
            ForEach(diet.allCases, id: \.self) { diet in
                 Button( action: {
                    if self.selectedDiet == diet {
                        self.selectedDiet = nil
                    } else {
                        self.selectedDiet = diet
                    }
                 }) {
                     HStack {
                        Image(systemName: (self.selectedDiet == diet) ? "checkmark.square" : "square")
                         Text(diet.rawValue)
                     }
                 }
             }
        }
    }
}
