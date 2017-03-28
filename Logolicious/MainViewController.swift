//
//  MainViewController.swift
//  Logolicious
//
//  Created by Sumit on 06/12/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

let skipTutorialKey = "skipTutorialKey"
let imageQualityKey = "imageQualityKey"

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkDefaultsAndProceed()
    }
    
    func checkDefaultsAndProceed() {
        let skip = UserDefaults.standard.bool(forKey: skipTutorialKey)
        if skip {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
            navigationController?.pushViewController(vc, animated: true)

        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroViewController")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
