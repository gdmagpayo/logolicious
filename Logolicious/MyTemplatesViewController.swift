//
//  MyTemplatesViewController.swift
//  Logolicious
//
//  Created by Sumit on 15/11/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit
import CoreData

protocol MyTemplateSelectionDelegate: class {
    func templateControllerSelected(template: Template)
    func templateControllerSelected(logo: Logo)
    func templateControllerSelected(image: UIImage)
}

enum TemplateVCMode: Int {
    case Template, Logo, Prefab
}


class MyTemplatesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: MyTemplateSelectionDelegate?
    
    var templates = [Template]()
    var logos = [Logo]()
    var prefabs = [UIImage]()
    var templatesMode = TemplateVCMode.Template

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if templatesMode == .Template {
            fetchTemplates()
        } else {
            if templatesMode == .Prefab {
                prefabs =  [UIImage(named: "prefab-AllRightsReserved-Black")!,
                            UIImage(named: "prefab-AllRightsReserved-white")!,
                            UIImage(named: "prefab-logo-©-black")!,
                            UIImage(named: "prefab-logo-©-white")!,
                            UIImage(named: "prefab-logo-®-black")!,
                            UIImage(named: "prefab-logo-®-white")!]
                collectionView.reloadData()
            } else {
                fetchLogos()
            }
        }
    }
    
    @IBAction func dismissTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func registerCell() {
        let cellNib = UINib(nibName: String(describing: MyTemplatesCell.self), bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: String(describing: MyTemplatesCell.self))
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templatesMode == .Template ? templates.count : (templatesMode == .Prefab ? prefabs.count : logos.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyTemplatesCell.self), for: indexPath) as! MyTemplatesCell
        
        if templatesMode == .Template {
            cell.configure(template: templates[indexPath.row])
        } else {
            if templatesMode == .Prefab {
                cell.configure(image: prefabs[indexPath.row])
            } else {
                cell.configure(logo: logos[indexPath.row])
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MyTemplatesCell
        if templatesMode == .Template {
            if let template = cell.template {
                delegate?.templateControllerSelected(template: template)
            }
        } else {
            if templatesMode == .Prefab {
                let image = prefabs[indexPath.row]
                delegate?.templateControllerSelected(image: image)
            } else {
                if let logo = cell.logo {
                    delegate?.templateControllerSelected(logo: logo)
                }
            }
        }
    }
    
    //Core Data
    func fetchTemplates() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Template")
        do {
            let result = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
            templates.removeAll()
            for managedObject in result {
                if let template = managedObject as? Template {
                    templates.append(template)
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        collectionView.reloadData()
    }
    
    func fetchLogos() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Logo")
        do {
            let result = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
            logos.removeAll()
            for managedObject in result {
                if let logo = managedObject as? Logo {
                    logos.append(logo)
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        collectionView.reloadData()
    }

}
