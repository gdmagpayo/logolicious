//
//  IntroCell2.swift
//  Logolicious
//
//  Created by Sumit on 06/12/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

class IntroCell2: UICollectionViewCell {

    var nextAction: ( () -> () )?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func nextTapped(_ sender: AnyObject) {
        nextAction?()
    }
}
