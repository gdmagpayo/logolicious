//
//  MyTemplatesCell.swift
//  Logolicious
//
//  Created by Sumit on 15/11/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

class MyTemplatesCell: UICollectionViewCell {

    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    var template: Template?
    var logo: Logo?
    var image: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(template: Template) {
        self.template = template
        mainLabel.text = template.name
        
        if let path = template.thumbUrl {
            let url = ViewController.getAppDirectory().appendingPathComponent(path)
            do {
                let imageData = try Data(contentsOf: url)
                mainImage.image = UIImage(data: imageData as Data)
            } catch {
                print("Error in imagedata")
            }
        }
    }
    
    func configure(logo: Logo) {
        self.logo = logo
        mainLabel.text = ""
        
        if let path = logo.imageUrl {
            let url = ViewController.getAppDirectory().appendingPathComponent(path)
            do {
                let imageData = try Data(contentsOf: url)
                mainImage.image = UIImage(data: imageData as Data)
            } catch {
                mainImage.image = nil
                print("Error in imagedata")
            }
        }
    }
    
    func configure(image: UIImage) {
        mainLabel.text = ""
        self.image = image
        mainImage.image = image
    }
}
