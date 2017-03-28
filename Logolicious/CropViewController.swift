//
//  CropViewController.swift
//  Logolicious
//
//  Created by Sumit on 21/12/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

class CropViewController: UIViewController {

    @IBOutlet weak var imageOriginal: UIImageView!
    var currentTranslationForPan = CGPoint.zero

    @IBOutlet weak var imageTop: UIImageView!
    @IBOutlet weak var topMask: UIView! {
        didSet {
            topMask.layer.borderColor = UIColor.white.cgColor
            topMask.layer.borderWidth = 1
        }
    }
    
    var quadrant = 0
    var okayAction: ( (UIImage) -> () )?
    
    
    @IBOutlet weak var editingView: UIView!
    
    @IBOutlet weak var four3Button: UIButton! {
        didSet {
            four3Button.layer.borderColor = UIColor.white.cgColor
            four3Button.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var one1Button: UIButton! {
        didSet {
            one1Button.layer.borderColor = UIColor.white.cgColor
            one1Button.layer.borderWidth = 1
        }
    }

    @IBOutlet weak var sixteenButton: UIButton! {
        didSet {
            sixteenButton.layer.borderColor = UIColor.white.cgColor
            sixteenButton.layer.borderWidth = 1
        }
    }

    
    var image: UIImage!
    
    @IBAction func oneTapped(_ sender: AnyObject) {
        var width = imageOriginal.bounds.size.width  - 20
        if imageOriginal.bounds.size.width > imageOriginal.bounds.size.height {
            width = imageOriginal.bounds.size.height  - 20
        }
        var fr = topMask.bounds
        fr.size.width = width
        fr.size.height = width
        topMask.bounds = fr
        let cent = imageOriginal.convert(CGPoint(x: imageOriginal.bounds.width/2, y: imageOriginal.bounds.height/2), to: topMask)
        imageTop.center = cent
    }
    
    @IBAction func sixteenTapped(_ sender: UIButton) {
        var width = imageOriginal.bounds.size.width  - 20
        var height = width * 9/16
        
        if imageOriginal.bounds.size.width > imageOriginal.bounds.size.height {
            let maxHeight = imageOriginal.bounds.size.height - 20
            let maxWidth = imageOriginal.bounds.size.width - 20

            height = maxHeight
            width = maxHeight * 16/9
            if width > maxWidth {
                let downScale = width/maxWidth
                width = maxWidth
                height = height/downScale
            }
        }
        
        var fr = topMask.bounds
        fr.size.width = width
        fr.size.height = height
        topMask.bounds = fr
        let cent = imageOriginal.convert(CGPoint(x: imageOriginal.bounds.width/2, y: imageOriginal.bounds.height/2), to: topMask)
        imageTop.center = cent
    }
    
    @IBAction func four3Tapped(_ sender: UIButton) {
        var width = imageOriginal.bounds.size.width  - 20
        var height = width * 3/4
        
        if imageOriginal.bounds.size.width > imageOriginal.bounds.size.height {
            let maxHeight = imageOriginal.bounds.size.height - 20
            let maxWidth = imageOriginal.bounds.size.width - 20
            
            height = maxHeight
            width = maxHeight * 4/3
            if width > maxWidth {
                let downScale = width/maxWidth
                width = maxWidth
                height = height/downScale
            }
        }
        
        var fr = topMask.bounds
        fr.size.width = width
        fr.size.height = height
        topMask.bounds = fr
        let cent = imageOriginal.convert(CGPoint(x: imageOriginal.bounds.width/2, y: imageOriginal.bounds.height/2), to: topMask)
        imageTop.center = cent
    }
    
    
    @IBAction func ninetyTapped(_ sender: UIButton) {
        imageOriginal.transform = imageOriginal.transform.rotated(by: CGFloat(M_PI_2))
        topMask.transform = topMask.transform.rotated(by: CGFloat(M_PI_2))
        quadrant = (quadrant + 1)%4
    }
    
    
    @IBAction func okTapped(_ sender: AnyObject) {
        sendImage()
    }
    
    @IBAction func noCropTapped(_ sender: AnyObject) {
        sendImage()
    }
    
    func sendImage() {
        topMask.layer.borderWidth = 0
        UIGraphicsBeginImageContextWithOptions(topMask.bounds.size, topMask.isOpaque, 0.0);
        if let context = UIGraphicsGetCurrentContext() {
            topMask.layer.render(in: context);
            let screenshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if let shot = screenshot {
                okayAction?(shot)
            }
        } else {
            UIGraphicsEndImageContext();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageOriginal.image = image
        imageTop.image = image
        view.layoutIfNeeded()
        sizeUpViews()
        addGesturesToEditingView()
        view.setNeedsLayout()
    }
    
    func sizeUpViews() {
        let maxWidth = view.bounds.width
        let maxHeight = view.bounds.height
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        if imageWidth > imageHeight {
            let ratio = imageWidth/maxWidth
            width = maxWidth
            height = imageHeight/ratio
        } else {
            let ratio = imageHeight/maxHeight
            height = maxHeight
            width = imageWidth/ratio
        }
        
        imageOriginal.center = editingView.center
        var bound = imageOriginal.bounds
        bound.size.width = width
        bound.size.height = height
        imageOriginal.bounds = bound
        
        topMask.center = imageOriginal.center
        topMask.bounds = imageOriginal.bounds
        imageTop.frame = CGRect(x: 0, y: 0, width: topMask.bounds.width, height: topMask.bounds.height)
    }
}

extension CropViewController: UIGestureRecognizerDelegate {
    
    func addGesturesToEditingView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        
        panGesture.delegate = self
        imageOriginal.isUserInteractionEnabled = true
        imageOriginal.addGestureRecognizer(panGesture)
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            currentTranslationForPan = gesture.translation(in: imageOriginal)
            return
        }
        let trans = gesture.translation(in: imageOriginal)
        var center = topMask.center
        
        let xTrans = (trans.x - currentTranslationForPan.x)
        let yTrans = (trans.y - currentTranslationForPan.y)
        
        if quadrant == 0 {
            center.x += xTrans
            center.y += yTrans
        }

        if quadrant == 1 {
            center.x += -yTrans
            center.y += xTrans
        }
        
        if quadrant == 2 {
            center.x += -xTrans
            center.y += -yTrans
        }
        
        if quadrant == 3 {
            center.x += yTrans
            center.y += -xTrans
        }
        
        
        let cent = imageOriginal.convert(CGPoint(x: imageOriginal.bounds.width/2, y: imageOriginal.bounds.height/2), to: topMask)
        currentTranslationForPan = trans
        imageTop.center = cent
        topMask.center = center
    }
}
