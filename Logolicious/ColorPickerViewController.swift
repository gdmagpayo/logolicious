//
//  ColorPickerViewController.swift
//  Logolicious
//
//  Created by Sumit on 02/11/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate: class {
    func colorPickerPicked(picker: ColorPickerViewController, color: UIColor)
}

class ColorPickerViewController: UIViewController {

    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerHeight: NSLayoutConstraint!
    @IBOutlet weak var colorPickerWidth: NSLayoutConstraint!
    weak var delegate: ColorPickerDelegate?
    
    //PADDING CONSTANTS
    let leftPadding: CGFloat = 24
    let rightPadding: CGFloat = 56
    let bottomGap: CGFloat = 110
    let internalPadding: CGFloat = 8
    var colorCountX = 1
    var colorCountY = 1
    
    //ARRAY OF COLORS
    let colorsArray: [(CGFloat, CGFloat, CGFloat)] = [
        (162,31,99),
        (0,171,223),
        (40,177,90),
        (255,173,88),
        (194,26,49),
        (242,39,122),
        (0,118,187),
        (0,102,64),
        (249,233,91),
        (247,55,61),
        (255,255,255),
        (39,59,138),
        (3,183,120),
        (202,225,80),
        (244,86,54),
        (0,0,0),
        (102,47,137),
        (0,170,157),
        (136,197,90),
        (249,144,60)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustColorPickerSizeAndFill()
    }
    
    //FILL UP COLOR VIEW
    func adjustColorPickerSizeAndFill() {
        let screenWidth = UIScreen.main.bounds.width
        let pickerWidth = screenWidth - leftPadding - rightPadding
        let aspectRatio = CGFloat(2*colorCountY + 1)/CGFloat(2*colorCountX + 1)
        let pickerHeight = pickerWidth*aspectRatio
        colorPickerWidth.constant = pickerWidth
        colorPickerHeight.constant = pickerHeight
        view.setNeedsLayout()
        
        let squareSide = (pickerWidth - CGFloat(colorCountX + 1)*internalPadding)/CGFloat(colorCountX)
        fillColors(side: squareSide)
    }
    
    func fillColors(side: CGFloat) {
        var xPos = internalPadding
        var yPos = internalPadding
        
        for row in 0..<colorCountY {
            for column in 0..<colorCountX {
                if let color = colorAt(row: row, column: column) {
                  let button = UIButton(frame: CGRect(x: xPos, y: yPos, width: side, height: side))
                    button.backgroundColor = color
                    button.addTarget(self, action: #selector(colorSelected(button:)), for: .touchUpInside)
                    colorPickerView.addSubview(button)
                    if column == colorCountX - 1 {
                        xPos = internalPadding
                        yPos += side + internalPadding
                    } else {
                        xPos += side + internalPadding
                    }
                }
            }
        }
    }
    
    func colorAt(row: Int, column: Int) -> UIColor? {
        let arrayPos = (colorCountX * row) + column
        if arrayPos >= colorsArray.count {return nil}
        
        let (red, green, blue) = colorsArray[arrayPos]
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
    
    //ACTIONS
    func colorSelected(button: UIButton) {
        delegate?.colorPickerPicked(picker: self, color: button.backgroundColor ?? UIColor.black)
    }
    
    @IBAction func backGroundTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
