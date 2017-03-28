//
//  OverlayImageView.swift
//  Logolicious
//
//  Created by Sumit on 27/10/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

protocol OverlayView: class {
    func toggleEditing(editing: Bool)
}

class OverlayImageView: UIImageView, OverlayView {
    var scale: CGFloat = 1

    private var overlay = UIView()
    var imageUrlPath: String?
    
    override init(image: UIImage?) {
        super.init(image: image)
        clipsToBounds = true
        addOverlay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addOverlay() {
        overlay.frame = bounds
        overlay.alpha = 0.4
        overlay.backgroundColor = UIColor.clear
        addSubview(overlay)
        bringSubview(toFront: overlay)
    }
    
    func toggleEditing(editing: Bool) {
        overlay.backgroundColor = editing ? UIColor.green : UIColor.clear
    }
}
