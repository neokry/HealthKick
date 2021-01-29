//
//  AllergyCheckboxList.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/26/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct AllergyCheckboxList: View {
    @Binding var selectedAllergies: [allergies]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Allergies")
            ForEach(allergies.allCases, id: \.self) { allergy in
                Button( action: {
                    if self.selectedAllergies.contains(allergy) {
                        self.selectedAllergies.remove(object: allergy)
                    } else {
                        self.selectedAllergies.append(allergy)
                    }

                }) {
                    HStack {
                        Image(systemName: (self.selectedAllergies.contains(allergy)) ? "checkmark.square" : "square")
                        Text(allergy.rawValue)
                    }
                }
            }
        }
    }
}
