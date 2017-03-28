//
//  SettingsViewController.swift
//  Logolicious
//
//  Created by Sumit on 21/12/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var aboutView: UIScrollView!
    @IBOutlet weak var settingView: UIView!
    
    @IBOutlet weak var settingIntroButton: UIButton!
    @IBOutlet weak var highQuality: UIButton!
    @IBOutlet weak var lowQuality: UIButton!
    @IBOutlet weak var aboutIntroButton: UIButton!
    
    @IBOutlet weak var settingsSegmentButton: UIButton!
    
    @IBOutlet weak var aboutSegmentButton: UIButton!
    
    @IBAction func aboutSegmentTapped(_ sender: AnyObject) {
        aboutSegmentButton.backgroundColor = UIColor.lightGray
        settingsSegmentButton.backgroundColor = UIColor.darkGray
        settingView.isHidden = true
        aboutView.isHidden = false
    }
    
    @IBAction func settingsSegmentTapped(_ sender: AnyObject) {
        aboutSegmentButton.backgroundColor = UIColor.darkGray
        settingsSegmentButton.backgroundColor = UIColor.lightGray
        settingView.isHidden = false
        aboutView.isHidden = true
    }
    
    @IBAction func settingsIntroTapped(_ sender: UIButton) {
        UserDefaults.standard.set(sender.isSelected, forKey: skipTutorialKey)
        sender.isSelected = !sender.isSelected
        settingIntroButton.isSelected = sender.isSelected
    }
    
    @IBAction func highQualityTapped(_ sender: UIButton) {
        sender.isSelected = true
        UserDefaults.standard.set(true, forKey: imageQualityKey)
        lowQuality.isSelected = false
    }
    
    @IBAction func lowQualityTapped(_ sender: UIButton) {
        sender.isSelected = true
        UserDefaults.standard.set(false, forKey: imageQualityKey)
        highQuality.isSelected = false
    }
    
    @IBAction func aboutIntroTapped(_ sender: UIButton) {
        UserDefaults.standard.set(sender.isSelected, forKey: skipTutorialKey)
        sender.isSelected = !sender.isSelected
        settingIntroButton.isSelected = sender.isSelected
    }
    
    @IBAction func bgTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutSegmentButton.backgroundColor = UIColor.lightGray
        settingsSegmentButton.backgroundColor = UIColor.darkGray
        settingView.isHidden = true
        aboutView.isHidden = false
        let skip = UserDefaults.standard.bool(forKey: skipTutorialKey)
        let high = UserDefaults.standard.bool(forKey: imageQualityKey)
        
        aboutIntroButton.isSelected = !skip
        settingIntroButton.isSelected = !skip
        
        highQuality.isSelected = high
        lowQuality.isSelected = !high
    }
}
