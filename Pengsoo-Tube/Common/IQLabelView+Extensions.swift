//
//  IQLabelView+Extensions.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 14/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import IQLabelView

extension IQLabelView {
    func setIcons() {
        if let closeView = subviews[1] as? UIImageView {
            closeView.image = UIImage(systemName: "xmark.circle.fill")
            closeView.backgroundColor = .clear
            closeView.tintColor = .white
        }
        
        if let rotateView = subviews[2] as? UIImageView {
            rotateView.image = UIImage(systemName: "arrow.left.and.right.circle.fill")
            rotateView.backgroundColor = .clear
            rotateView.tintColor = .white
        }
    }
    
    func setupTextField() {
        if let textField = subviews.first as? UITextField {
            textField.text = " "
            textField.tintColor = .systemYellow
            textField.autocorrectionType = .no
            textField.textAlignment = .center
        }
    }
    
    func setAttributedText(foregroundColor: UIColor, strokeColor: UIColor) {
        if let textField = subviews.first as? UITextField {
            var text = textField.text ?? ""
            if text.count == 0 {
                text = " "
            }
            
            textColor = foregroundColor
            textField.attributedText = NSAttributedString(string: text,
                                                          attributes: [NSAttributedString.Key.foregroundColor:foregroundColor,
                                                                       NSAttributedString.Key.strokeColor:strokeColor,
                                                                       NSAttributedString.Key.strokeWidth:-4,
                                                                       NSAttributedString.Key.font:UIFont(name: "HelveticaNeue-CondensedBlack", size: textField.font!.pointSize)!])
        }
    }
    
    func setTextBackground(backgroundColor: UIColor) {
        if let textField = subviews.first as? UITextField {
            textField.backgroundColor = backgroundColor
        }
    }
}

extension IQLabelView: UITextFieldDelegate {
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        if textField.text!.count > 1 && textField.text!.hasPrefix(" ") {
            textField.text = String(textField.text!.dropFirst())
        }
        
        delegate.labelViewDidEndEditing?(self)
        
        let oldTextFrame = textField.frame
        textField.sizeToFit()
        let newTextFrame = textField.frame
        textField.frame = oldTextFrame
        
        var bounds = self.bounds
        bounds.size.width = newTextFrame.width+24
        
        textField.adjustsFontSize(toFill: bounds)
        self.bounds = bounds
        
        return true
    }
}
