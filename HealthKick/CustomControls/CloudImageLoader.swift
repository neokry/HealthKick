//
//  CloudImage.swift
//  HealthKick
//
//  Created by Patrick Genevich on 7/9/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import FirebaseStorage

class CloudImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var loaded = false
    private var id: String

    init(id: String) {
        self.id = id
    }

    func load(completion: @escaping (UIImage?) -> Void) {

        let ref = Storage.storage().reference()
        let recipeImageRef = ref.child("images/\(id).jpg")

        recipeImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error getting image from cloud storage \(error.localizedDescription)")
            } else {
                if let UIImg = UIImage(data: data!) {
                    completion(UIImg)
                }
            }
        }
    }
}
