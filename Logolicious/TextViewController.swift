//
//  TextViewController.swift
//  Logolicious
//
//  Created by Sumit on 27/10/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

protocol TextPlacingDelegate: class {
    func textControllerReturned(text: String, font: UIFont)
}

class TextViewController: UIViewController, UITextFieldDelegate {
    let fontNames = [
        "Ansley Display-Light",
        "Ansley Display-Outline",
        "Ansley Display-Regular",
        "Cornerstone",
        "Display",
        "Hamurz Free Version",
        "Idolwild",
        "Lulo Clean 1",
        "Manteka",
        "Mosk Semi-Bold 600",
        "Mosk Thin 100",
        "Mosk Ultra-Bold 900",
        "Nexa Bold",
        "Nexa Light",
        "Oswald-Bold",
        "Oswald-ExtraLight",
        "Oswald-Regular",
        "Sign-handwriting",
        "Variane Script"
    ]
    
    @IBOutlet weak var addTextView: UIView!
    @IBOutlet weak var fontSelectView: UIView!
    @IBOutlet weak var fontsTableView: UITableView!
    var selectedFont = UIFont.systemFont(ofSize: 18)
    @IBOutlet weak var previewLabel: UILabel!
    weak var delegate: TextPlacingDelegate?
    @IBOutlet weak var mainTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        addTextView.layer.cornerRadius = 5
        fontSelectView.layer.cornerRadius = 5
    }
    
    //MARK:- Actions
    @IBAction func selectFontTapped(_ sender: AnyObject) {
        addTextView.isHidden = true
        fontSelectView.isHidden = false
    }
    
    @IBAction func placeTextTapped(_ sender: AnyObject) {
        delegate?.textControllerReturned(text: mainTextField.text ?? "", font: selectedFont)
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OKTapped(_ sender: AnyObject) {
    }
    
    //TEXT FIELD
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let rangeS = textField.text?.range(from: range) {
            previewLabel.text = textField.text?.replacingCharacters(in: rangeS, with: string)
        }
        return true
    }
}

extension TextViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "BasicCell")
        cell.backgroundColor = UIColor.clear
        if let font = UIFont(name: fontNames[indexPath.row], size: 18) {
            cell.textLabel?.text = fontNames[indexPath.row]
            cell.textLabel?.font = font
        } else {
            cell.textLabel?.text = "System Font"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let font = UIFont(name: fontNames[indexPath.row], size: 18) {
            selectedFont = font
            previewLabel.font = font
            addTextView.isHidden = false
            fontSelectView.isHidden = true
        }
    }
}
