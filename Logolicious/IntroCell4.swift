//
//  IntroCell4.swift
//  Logolicious
//
//  Created by Sumit on 06/12/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

class IntroCell4: UICollectionViewCell {

    var okAction: ( () -> () )?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func okTapped(_ sender: AnyObject) {
        okAction?()
    }    
}
