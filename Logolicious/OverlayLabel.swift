//
//  OverlayLabel.swift
//  Logolicious
//
//  Created by Sumit on 27/10/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

class OverlayLabel: UILabel, OverlayView {
    private var overlay = UILabel()
    
    var scale: CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shadowColor = UIColor.black
        shadowOffset = CGSize(width: 1, height: 1)
        font = UIFont.systemFont(ofSize: 18)
        textColor = UIColor.white
        overlay.textColor = UIColor.green
        overlay.alpha = 0.9
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleEditing(editing: Bool) {
        if editing {
            overlay.frame = bounds
            overlay.text = text
            overlay.font = font
            addSubview(overlay)
            bringSubview(toFront: overlay)
        } else {
            overlay.removeFromSuperview()
        }
    }
    
    func changeColor(color: UIColor) {
        textColor = color
    }
    
    func findSizeThatFits() -> CGSize {
        let width = text?.widthWithConstrainedHeight(height: font.pointSize/1.5, font: font) ?? 10
        return CGSize(width: width + 20, height: font.pointSize + 10)
    }
}

extension String {
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
    
        func range(from nsRange: NSRange) -> Range<String.Index>? {
            guard
                let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
                let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
                let from = String.Index(from16, within: self),
                let to = String.Index(to16, within: self)
                else { return nil }
            return from ..< to
        }
}
