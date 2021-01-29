//
//  FilterView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/26/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var filter: Filter

    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .top) {
                    DietCheckboxList(selectedDiet: $filter.selectedDiet)
                        .padding()
                    AllergyCheckboxList(selectedAllergies: $filter.selectedAllergies)
                        .padding()

                }

                Spacer()
            }
            .navigationBarTitle(Text("Dietary Prefrences"))
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(filter: Filter())
    }
}
