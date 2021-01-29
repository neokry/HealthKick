//
//  TextView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 7/27/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        
        let textField = UITextView()
        textField.delegate = context.coordinator
        textField.isEditable = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.textColor = .lightGray
        return textField
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        
        var parent: TextView
        
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView)
        {
            if (textView.text == "Paste or type your ingredient list here and we'll create a recipe from them. \n \n Add one ingredient per line" && textView.textColor == .lightGray)
            {
                textView.text = ""
                textView.textColor = .black
            }
            textView.becomeFirstResponder() //Optional
        }

        func textViewDidEndEditing(_ textView: UITextView)
        {
            if (textView.text == "")
            {
                textView.text = "Paste or type your ingredient list here and we'll create a recipe from them. \n \n Add one ingredient per line"
                textView.textColor = .lightGray
            }
            textView.resignFirstResponder()
        }
    }
}
