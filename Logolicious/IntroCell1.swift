//
//  IntroCell1.swift
//  Logolicious
//
//  Created by Sumit on 06/12/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

class IntroCell1: UICollectionViewCell {

    @IBOutlet weak var askmeButton: UIButton!
    
    var okAction: (() -> ())?
    var askmeAction: ((Bool) -> ())?
    var skipAction: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func askmeTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        askmeAction?(sender.isSelected)
    }
    
    @IBAction func okayTapped(_ sender: AnyObject) {
        okAction?()
    }
    
    @IBAction func skipTapped(_ sender: AnyObject) {
        skipAction?()
    }
}
