//
//  ViewController.swift
//  Logolicious
//
//  Created by Sumit on 22/10/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var editingView: UIView!
    @IBOutlet weak var mainBgParent: UIView!
    @IBOutlet weak var mainBgImageView: UIImageView!
    @IBOutlet weak var slider: ASValueTrackingSlider!
    
    //Constraints
    @IBOutlet weak var mainBgWidth: NSLayoutConstraint!
    @IBOutlet weak var mainBgHeight: NSLayoutConstraint!
    
    //Local Vars
    var imageSelectModeMain = true
    var viewSelectedForEditing: UIView? {
        didSet {
            slider.value = Float(viewSelectedForEditing?.alpha ?? 1)
        }
    }
    var currentTopViewTransform =  CGAffineTransform()
    var currentTranslationForPan = CGPoint.zero
    var currentTopViewSize = CGSize()
    var currentLabelFontSize:CGFloat = 18 //Only for label
    
    //Text Constants and vars
    let defaultTextWidth = 80
    let defaultTextHeight = 30
    
    //Stack to maintain z-positions
    var overlaysStack = [UIView]()
    
    var templateField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        configureSlider()
        resizeMainBgView()
        addGesturesToEditingView()
        showLibraryActionSheet()
    }
    
    func configureSlider() {
        slider.maximumValue = 1
        slider.minimumValue = 0
        slider.value = 1
        slider.setMaxFractionDigitsDisplayed(0)
        slider.popUpViewCornerRadius = 4.0
        slider.popUpViewColor = UIColor(hue: 0.55, saturation: 0.8, brightness: 0.9, alpha: 1.0)
        
        self.slider.textColor = UIColor(hue: 0.55, saturation: 1.0, brightness: 0.5, alpha: 1.0)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        slider.numberFormatter = formatter
        self.slider.font = UIFont(name: "Cornerstone", size: 26)
    }
    
    //MARK:- Actions
    
    @IBAction func logoTapped(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        if let topView = viewSelectedForEditing {
            topView.alpha = CGFloat(sender.value)
        }
    }
    
    //SIDE VIEW
    @IBAction func selectImageTapped(_ sender: AnyObject) {
        showLibraryActionSheet()
    }
    
    @IBAction func saveAsTemplateTapped(_ sender: AnyObject) {
        guard mainBgImageView.image != nil, overlaysStack.count > 0 else {
            showNoContent(text: "No Template to Save")
            
            return
        }
        showTemplateAlert()
    }
    
    @IBAction func myTemplatesTapped(_ sender: AnyObject) {
        let vc = MyTemplatesViewController()
        vc.templatesMode = .Template
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func prefabTapped(_ sender: AnyObject) {
        let vc = MyTemplatesViewController()
        vc.templatesMode = .Prefab
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func myLogosTapped(_ sender: AnyObject) {
        let vc = MyTemplatesViewController()
        vc.templatesMode = .Logo
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func shareTapped(_ sender: AnyObject) {
        guard let _ = mainBgImageView.image, overlaysStack.count > 0 else {
            showNoContent(text: "Nothing To Share! Add Logo or Text")
            return
        }
        saveImageToDevice(share: true)
    }
    
    @IBAction func saveToDeviceTapped(_ sender: AnyObject) {
        guard let _ = mainBgImageView.image, overlaysStack.count > 0 else {
            showNoContent(text: "Nothing To Share! Add Logo or Text")
            return
        }
        saveImageToDevice(share: false)
    }
    
    //BOTTOM VIEW
    
    @IBAction func loadLogoTapped(_ sender: AnyObject) {
        if checkMainImage() {
            imageSelectModeMain = false
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addTextTapped(_ sender: AnyObject) {
        if checkMainImage() {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ABC") as! TextViewController
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func colorPickerTapped(_ sender: AnyObject) {
        let colorPickerVC = ColorPickerViewController()
        colorPickerVC.delegate = self
        colorPickerVC.modalPresentationStyle = .overCurrentContext
        colorPickerVC.colorCountX = 5
        colorPickerVC.colorCountY = 4
        present(colorPickerVC, animated: true, completion: nil)
    }
    
    @IBAction func deleteTapped(_ sender: AnyObject) {
        if let topView = viewSelectedForEditing {
            topView.removeFromSuperview()
        }
    }
    
    @IBAction func zeroRotationTapped(_ sender: AnyObject) {
        if let topView = viewSelectedForEditing {
            if let label = topView as? OverlayLabel {
                label.transform = CGAffineTransform.identity.scaledBy(x: label.scale, y: label.scale)
            }
            if let label = topView as? OverlayImageView {
                label.transform = CGAffineTransform.identity.scaledBy(x: label.scale, y: label.scale)
            }
        }
    }
    
    @IBAction func ninetyRotationTapped(_ sender: AnyObject) {
        if let topView = viewSelectedForEditing {
            topView.transform = topView.transform.rotated(by: CGFloat(M_PI_2))
        }
    }
}

extension ViewController: TextPlacingDelegate, ColorPickerDelegate {
    func textControllerReturned(text: String, font: UIFont) {
        dismiss(animated: false, completion: nil)
        let labelFrame = CGRect(x: 0, y: 0, width: defaultTextWidth, height: defaultTextHeight)
        let label = OverlayLabel(frame: labelFrame)
        label.text = text
        label.center = mainBgImageView.center
        label.font = font
        var grownBounds = label.bounds
        grownBounds.size = label.findSizeThatFits()
        label.bounds = grownBounds
        mainBgParent.addSubview(label)
        mainBgParent.bringSubview(toFront: label)
        overlaysStack.append(label)
        viewSelectedForEditing = label
    }
    
    func colorPickerPicked(picker: ColorPickerViewController, color: UIColor) {
        if let topView = viewSelectedForEditing as? OverlayLabel {
            topView.changeColor(color: color)
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- Image Selection, Positioning methods
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK:- UIImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if imageSelectModeMain {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CropViewController") as! CropViewController
                vc.okayAction = updateMainBgImage
                vc.image = pickedImage
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                
                let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
                let imageName = imageURL.lastPathComponent
                addImageAsLayer(pickedImage: pickedImage, imageUrl: imageName)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func updateMainBgImage(pickedImage: UIImage) {
        dismiss(animated: true, completion: nil)
        mainBgImageView.image = pickedImage
        for overlay in overlaysStack {
            overlay.removeFromSuperview()
        }
        overlaysStack.removeAll()
        resizeMainBgView()
    }
    
    //MARK:- Resizing Main BG View
    
    func resizeMainBgView() {
        view.layoutIfNeeded()
        if let mainImage = mainBgImageView.image {
            let imageWidth = mainImage.size.width
            let imageHeight = mainImage.size.height
            let maxHeight = editingView.bounds.height
            let maxWidth = editingView.bounds.width
            let yFitRatio = imageHeight/maxHeight
            let xFitRatio = imageWidth/maxWidth
            
            if xFitRatio > yFitRatio {
                mainBgWidth.constant = editingView.bounds.width
                mainBgHeight.constant = imageHeight / xFitRatio
            } else {
                mainBgHeight.constant = editingView.frame.size.height
                mainBgWidth.constant = imageWidth / yFitRatio
            }
            view.setNeedsLayout()
        } else {
            mainBgWidth.constant = editingView.frame.size.width
            mainBgHeight.constant = editingView.frame.size.height
            view.setNeedsLayout()
        }
    }
    
    func addTemplateImageAsLayer(image: UIImage, frame: CGRect, transform: CGAffineTransform, alpha: CGFloat) {
        let topImageView = OverlayImageView(image: image)
        topImageView.imageUrlPath = nil
        
        var bounds = topImageView.bounds
        bounds.size.width = frame.width
        bounds.size.height = frame.height
        topImageView.bounds = bounds
        
        topImageView.alpha = alpha
        
        var center = topImageView.center
        center.x = frame.origin.x
        center.y = frame.origin.y
        topImageView.center = center
        
        topImageView.contentMode = .scaleAspectFit
        mainBgParent.addSubview(topImageView)
        mainBgParent.bringSubview(toFront: topImageView)
        viewSelectedForEditing = topImageView
        overlaysStack.append(topImageView)
    }
    
    func addTemplateLabel(text: String, font: UIFont, frame: CGRect, transform: CGAffineTransform, alpha: CGFloat, color: UIColor)  {
        let topLabel = OverlayLabel()
        
        var bounds = topLabel.bounds
        bounds.size.width = frame.width
        bounds.size.height = frame.height
        topLabel.bounds = bounds
        
        topLabel.font = font
        topLabel.textColor = color
        topLabel.text = text
        topLabel.alpha = alpha
        
        var center = topLabel.center
        center.x = frame.origin.x
        center.y = frame.origin.y
        topLabel.center = center
        
        mainBgParent.addSubview(topLabel)
        mainBgParent.bringSubview(toFront: topLabel)
        viewSelectedForEditing = topLabel
        overlaysStack.append(topLabel)
    }
    
    func addImageAsLayer(pickedImage: UIImage, imageUrl: String?) { //Add image as a loaded logo
        let topImageView = OverlayImageView(image: pickedImage)
        topImageView.imageUrlPath = imageUrl
        topImageView.contentMode = .scaleAspectFit
        mainBgParent.addSubview(topImageView)
        mainBgParent.bringSubview(toFront: topImageView)
        let maxWidth = mainBgWidth.constant/2
        let maxHeight = mainBgHeight.constant/2
        let imageWidth = pickedImage.size.width
        let imageHeight = pickedImage.size.height
        let yFitRatio = imageHeight/maxHeight
        let xFitRatio = imageWidth/maxWidth
        
        if xFitRatio > yFitRatio {
            var frame = CGRect(x: 0, y: 0, width: maxWidth, height: 0)
            frame.size.height = imageHeight / xFitRatio
            topImageView.frame = frame
        } else {
            var frame = CGRect(x: 0, y: 0, width: 0, height: maxHeight)
            frame.size.width = imageWidth / yFitRatio
            topImageView.frame = frame
        }
        
        topImageView.center = mainBgImageView.center
        viewSelectedForEditing = topImageView
        overlaysStack.append(topImageView)
    }
}

//MARK:- Handling Gestures
extension ViewController: UIGestureRecognizerDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let location = touches.first?.location(in: editingView) {
            selectTopView(location: location)
        }
    }
    
    func selectTopView(location: CGPoint) {
        var foundView: UIView?
        var foundIndex = -1
        for i in 0..<(overlaysStack.count) {
            let subview = overlaysStack[i]
            let localLocation = editingView.convert(location, to: subview)
            if subview.bounds.contains(localLocation) {
                viewSelectedForEditing = subview
                foundIndex = i
                foundView = subview
                break
            }
        }
        if (foundView != nil) && foundIndex >= 0 {
            overlaysStack.remove(at: foundIndex)
            overlaysStack.insert(foundView!, at: 0)
            mainBgParent.bringSubview(toFront: foundView!)
        }
    }
    
    func highlightTopView(on: Bool) {
        if let topView = viewSelectedForEditing {
            if let top = topView as? OverlayView {
                top.toggleEditing(editing: on)
            }
        }
    }
    
    func addGesturesToEditingView() {
        editingView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(gesture:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        
        pinchGesture.delegate = self
        rotateGesture.delegate = self
        panGesture.delegate = self
        
        editingView.addGestureRecognizer(pinchGesture)
        editingView.addGestureRecognizer(rotateGesture)
        editingView.addGestureRecognizer(panGesture)
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer || gestureRecognizer is UIRotationGestureRecognizer {
            if let topView = viewSelectedForEditing {
                currentTopViewTransform = topView.transform
                currentTopViewSize = topView.bounds.size
                if let topLabel = topView as? OverlayLabel {
                    currentLabelFontSize = topLabel.font.pointSize
                }
            }
        }
        return true
    }
    
    func handlePinch(gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        if let topView = viewSelectedForEditing {
            if let topLabel = topView as? OverlayLabel {
                let pointSize = (gesture.velocity > 0.0 ? 1.0 : -1.0) + currentLabelFontSize
                topLabel.font = UIFont(name: topLabel.font.fontName, size: pointSize)
                let oldCenter = topLabel.center
                var grownBounds = topLabel.bounds
                grownBounds.size = topLabel.findSizeThatFits()
                topLabel.bounds = grownBounds
                topLabel.center = oldCenter
                currentLabelFontSize = pointSize
            } else {
                topView.transform = currentTopViewTransform.scaledBy(x: scale, y: scale)
                if let label = topView as? OverlayLabel {
                    label.scale = scale
                }
                if let label = topView as? OverlayImageView {
                    label.scale = scale
                }
            }
        }
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            currentTranslationForPan = gesture.translation(in: editingView)
            highlightTopView(on: true)
        } else if gesture.state == .ended {
            highlightTopView(on: false)
        }
        if let topView = viewSelectedForEditing {
            let trans = gesture.translation(in: editingView)
            var center = topView.center
            center.x += (trans.x - currentTranslationForPan.x)
            center.y += (trans.y - currentTranslationForPan.y)
            currentTranslationForPan = trans
            topView.center = center
        }
    }
    
    func handleRotate(gesture: UIRotationGestureRecognizer) {
        if let topView = viewSelectedForEditing {
            topView.transform = currentTopViewTransform.rotated(by: gesture.rotation)
        }
    }
}

//MARK: IMAGE SAVING METHODS
extension ViewController {
    
    func saveImageToDevice(share: Bool) {
        guard let mainImage = mainBgImageView.image, overlaysStack.count > 0 else {
            showNoContent(text: "Nothing To Share! Add Logo or Text")
            return
        }
        saveUsedLogos()
        /* Capture the screen shoot at native resolution */
        UIGraphicsBeginImageContextWithOptions(mainBgParent.bounds.size, mainBgParent.isOpaque, 0.0);
        if let context = UIGraphicsGetCurrentContext() {
            mainBgParent.layer.render(in: context);
            let screenshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            var quality: CGFloat = 1.0
            let high = UserDefaults.standard.bool(forKey: imageQualityKey)
            quality =  high ? 1.0 : 0.6
            
            /* Render the screen shot at custom resolution */
            let cropRect = CGRect(x: 0 ,y: 0 ,width: mainImage.size.width ,height: mainImage.size.height);
            UIGraphicsBeginImageContextWithOptions(cropRect.size, mainBgParent.isOpaque, quality);
            screenshot?.draw(in: cropRect)
            if let customScreenShot = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext();
                
                if share {
                    let activity = UIActivityViewController(activityItems: [customScreenShot], applicationActivities: nil)
                    present(activity, animated: true, completion: nil)
                } else {
                /* Save to the photo album */
                    UIImageWriteToSavedPhotosAlbum(customScreenShot, nil, nil, nil);
                }
            } else {
                UIGraphicsEndImageContext();
            }
        } else {
            UIGraphicsEndImageContext();
        }
    }
    
    func saveUsedLogos() {
        for view in overlaysStack {
            if let image = view as? OverlayImageView {
                if let uimage = image.image, let path = image.imageUrlPath {
                    let logo = NSEntityDescription.insertNewObject(forEntityName: "Logo", into: appDelegate.persistentContainer.viewContext)
                    let finalPath = ViewController.getAppDirectory().appendingPathComponent(path)
                    logo.setValue(path, forKey: "imageUrl")
                    let data = UIImageJPEGRepresentation(uimage, 1)
                    do {
                        try data?.write(to: finalPath)
                    } catch {
                        let nserror = error as NSError
                        print(nserror.description)
                    }
                 appDelegate.saveContext()
                }
            }
        }
    }
    
    func saveImageAsTemplate(name: String) {
        guard let mainImage = mainBgImageView.image else {
            showNoContent(text: "Could not save Template")
            return
        }
        
        mainBgImageView.image = nil
        mainBgImageView.backgroundColor = UIColor.white
        /* Capture the screen shoot at native resolution */
        UIGraphicsBeginImageContextWithOptions(mainBgParent.bounds.size, mainBgParent.isOpaque, 0.0);
        if let context = UIGraphicsGetCurrentContext() {
            mainBgParent.layer.render(in: context);
            let screenshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            /* Render the screen shot at custom resolution */
            let cropRect = CGRect(x: 0 ,y: 0 ,width: 60 ,height: 60);
            UIGraphicsBeginImageContextWithOptions(cropRect.size, mainBgParent.isOpaque, 1.0);
            screenshot?.draw(in: cropRect)
            if let customScreenShot = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext();
                let documentDirectory = ViewController.getAppDirectory()
                let dateFileString = "\(NSDate()).JPG"
                let localPath = documentDirectory.appendingPathComponent(dateFileString)
                if let template =
                    NSEntityDescription.insertNewObject(forEntityName: "Template", into: appDelegate.persistentContainer.viewContext) as? Template {
                    template.setValue(name, forKey: "name")
                    template.setValue(dateFileString, forKey: "thumbUrl")
                    generateLayersForCoreData(template: template)
                }
                let imageData = UIImageJPEGRepresentation(customScreenShot, 1)
                do {
                    try imageData?.write(to: localPath)
                } catch {
                    print("Error saving thumbnail")
                }
            } else {
                UIGraphicsEndImageContext();
            }
        } else {
            UIGraphicsEndImageContext();
        }
        mainBgImageView.image = mainImage
        mainBgImageView.backgroundColor = UIColor.clear
    }
    
    class func getAppDirectory() -> URL {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let folderPath = URL(fileURLWithPath: documentDirectory).appendingPathComponent("Logolicious")
        if !(FileManager.default.fileExists(atPath: folderPath.absoluteString)) {
            do{
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("ERROR WITH DIR: \(error.localizedDescription)")
            }
        }
        
        return folderPath
    }
    
    func generateLayersForCoreData(template: Template) {
        
        if overlaysStack.count == 0 {
            return
        }
        
        var set = NSSet()
        for view in overlaysStack {
            let layer = NSEntityDescription.insertNewObject(forEntityName: "Layer", into: appDelegate.persistentContainer.viewContext)
            layer.setValue(view.center.x, forKey: "xPos")
            layer.setValue(view.center.y, forKey: "yPos")
            layer.setValue(view.bounds.width, forKey: "width")
            layer.setValue(view.bounds.height, forKey: "height")
            
            layer.setValue(view.transform.a, forKey: "transA")
            layer.setValue(view.transform.b, forKey: "transB")
            layer.setValue(view.transform.c, forKey: "transC")
            layer.setValue(view.transform.d, forKey: "transD")
            layer.setValue(view.transform.tx, forKey: "transX")
            layer.setValue(view.transform.ty, forKey: "transY")
            
            layer.setValue(view.alpha, forKey: "alpha")

            if let label = view as? OverlayLabel {
                layer.setValue(label.text ?? "Text", forKey: "text")
                layer.setValue(false, forKey: "isImage")
                layer.setValue(label.font.fontName, forKey: "fontName")
                layer.setValue(label.font.pointSize, forKey: "fontSize")
                layer.setValue(label.textColor.hexString(), forKey: "color")
            }
            
            if let image = view as? OverlayImageView {
                layer.setValue(true, forKey: "isImage")
                
                if let uimage = image.image, let path = image.imageUrlPath {
                    let finalPath = ViewController.getAppDirectory().appendingPathComponent(path)
                    layer.setValue(path, forKey: "imageUrl")
                    let data = UIImageJPEGRepresentation(uimage, 1)
                    do {
                        try data?.write(to: finalPath)
                    } catch {
                        let nserror = error as NSError
                        print(nserror.description)
                    }
                }
            }
            
            set = set.adding(layer) as NSSet
        }
        template.setValue(set, forKey: "layers")
        appDelegate.saveContext()
    }
    
    
    
    func configurationTextField(textField: UITextField!)
    {
        textField.placeholder = "Template Name"
        templateField = textField
    }
    
    func handleCancel(alertView: UIAlertAction!)
    {
        print("Cancelled !!")
    }
    
    func showTemplateAlert()  {
        let alert = UIAlertController(title: "Save as Template", message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
            self.saveImageAsTemplate(name: self.templateField?.text ?? "")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: ALERTS
    func checkMainImage() -> Bool{
        if mainBgImageView.image == nil {
            let alert = UIAlertController(title: "Select Image", message: "Select main image first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    func showNoContent(text: String){
        let alert = UIAlertController(title: text, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLibraryActionSheet() {
        let alert = UIAlertController(title: "SELECT IMAGE", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: showCamera))
        alert.addAction(UIAlertAction(title: "Select Photo", style: .default, handler: showGallery))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancel))

        self.present(alert, animated: true, completion: nil)
    }
    
    func showGallery(alertView: UIAlertAction!) {
        imageSelectModeMain = true
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showCamera(alertView: UIAlertAction!) {
        imageSelectModeMain = true
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: MyTemplateSelectionDelegate {
    
    func templateControllerSelected(logo: Logo) {
        dismiss(animated: true, completion: nil)
        guard checkMainImage() else {
            return
        }
        if let path = logo.imageUrl {
            let url = ViewController.getAppDirectory().appendingPathComponent(path)
            do {
                let imageData = try Data(contentsOf: url)
                if let image = UIImage(data: imageData as Data) {
                    addImageAsLayer(pickedImage: image, imageUrl: nil)
                }
            } catch {
                print("Error in imagedata")
            }
        }
    }
    
    func templateControllerSelected(image: UIImage) {
        dismiss(animated: true, completion: nil)
        guard checkMainImage() else {
            return
        }
        addImageAsLayer(pickedImage: image, imageUrl: nil)
    }
    
    func templateControllerSelected(template: Template) {
        dismiss(animated: true, completion: nil)
        guard checkMainImage() else {
            return
        }
        if let layerSet = template.layers {
            for layer in layerSet.allObjects {
                if let overlay = layer as? Layer {
                    
                    var transform = CGAffineTransform()
                    transform.a = CGFloat(overlay.transA)
                    transform.b = CGFloat(overlay.transB)
                    transform.c = CGFloat(overlay.transC)
                    transform.d = CGFloat(overlay.transD)
                    transform.tx = CGFloat(overlay.transX)
                    transform.ty = CGFloat(overlay.transY)

                    let frame = CGRect(x: CGFloat(overlay.xPos), y: CGFloat(overlay.yPos), width: CGFloat(overlay.width), height: CGFloat(overlay.height))
                    
                    if overlay.isImage {
                        if let path = overlay.imageUrl {
                            let url = ViewController.getAppDirectory().appendingPathComponent(path)
                            do {
                                let imageData = try Data(contentsOf: url)
                                if let image = UIImage(data: imageData as Data) {
                                    addTemplateImageAsLayer(image: image, frame: frame, transform: transform, alpha: CGFloat(overlay.alpha))
                                }
                            } catch {
                                print("Error in imagedata")
                            }
                        }
                    } else {
                        if let text = overlay.text, let color = overlay.color, let fontName = overlay.fontName {
                             let font = UIFont(name: fontName, size: CGFloat(overlay.fontSize)) ?? UIFont.systemFont(ofSize: 18)
                            addTemplateLabel(text: text, font:
 font, frame: frame, transform: transform, alpha: CGFloat(overlay.alpha), color: UIColor(color))
                        }
                    }
                }
            }
        }
        
    }
}
