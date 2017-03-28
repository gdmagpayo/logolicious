//
//  IntroViewController.swift
//  Logolicious
//
//  Created by Sumit on 06/12/16.
//  Copyright © 2016 Logolicious. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
    }
    
    func registerCells() {
        let nib1 = UINib(nibName: "IntroCell1", bundle: nil)
        collectionView.register(nib1, forCellWithReuseIdentifier: "IntroCell1")
        
        let nib2 = UINib(nibName: "IntroCell2", bundle: nil)
        collectionView.register(nib2, forCellWithReuseIdentifier: "IntroCell2")
        
        let nib3 = UINib(nibName: "IntroCell3", bundle: nil)
        collectionView.register(nib3, forCellWithReuseIdentifier: "IntroCell3")

        let nib4 = UINib(nibName: "IntroCell4", bundle: nil)
        collectionView.register(nib4, forCellWithReuseIdentifier: "IntroCell4")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        view.layoutIfNeeded()
        return view.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            return cell1(indexPath: indexPath)
            
        case 1:
            return cell2(indexPath: indexPath)
            
        case 2:
            return cell3(indexPath: indexPath)
            
        case 3:
            return cell4(indexPath: indexPath)
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func cell1(indexPath: IndexPath) -> IntroCell1 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroCell1", for: indexPath) as! IntroCell1
        let nextCell = IndexPath(item: 1, section: 0)
        cell.okAction = {
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: nextCell, at: .centeredHorizontally, animated: true)
            }
        }
        cell.skipAction = {
            DispatchQueue.main.async {
                self.showImageViewController()
            }
        }
        cell.askmeAction = {(ask) in
            UserDefaults.standard.set(ask, forKey: skipTutorialKey)
        }
        
        return cell
    }
    
    func cell2(indexPath: IndexPath) -> IntroCell2 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroCell2", for: indexPath) as! IntroCell2
        let nextCell = IndexPath(item: 2, section: 0)
        cell.nextAction = {
            DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: nextCell, at: .centeredHorizontally, animated: true)
            }
        }
      
        return cell
    }
    
    func cell3(indexPath: IndexPath) -> IntroCell3 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroCell3", for: indexPath) as! IntroCell3
        let nextCell = IndexPath(item: 3, section: 0)
        cell.nextAction = {
            DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: nextCell, at: .centeredHorizontally, animated: true)
            }
        }
        
        return cell
    }
    
    func cell4(indexPath: IndexPath) -> IntroCell4 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroCell4", for: indexPath) as! IntroCell4
        cell.okAction = {
            DispatchQueue.main.async {
                self.showImageViewController()
            }
        }
        
        return cell
    }
    
    func showImageViewController() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}
