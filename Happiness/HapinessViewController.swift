//
//  ViewController.swift
//  Happiness
//
//  Created by iKing on 13.05.15.
//  Copyright (c) 2015 iKing. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController, FaceViewDataSource {
    
    
    var happiness: Int = 75 {    // from 0 to 100
        didSet {
            happiness = min(max(happiness, 0), 100)
//            println((defaults.valueForKey("HappinessViewControllerHappiness")))
            defaults.set(happiness, forKey: "HappinessViewControllerHappiness")
            updateUI()
        }
    }
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.dataSource = self
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: Selector(("scale:"))))
            faceView.addGestureRecognizer(UIRotationGestureRecognizer(target: faceView, action: Selector("rotate:")))
//            happiness = Int(defaults.valueForKey("HappinessViewControllerHappiness")? as? NSNumber ?? 75)
        }
    }
    
    let defaults = UserDefaults.standard
    
    fileprivate struct Constants {
        static let HappinessGestureScale: CGFloat = 4
        static let HappinessKeyForUserDefaults = "HappinessViewControllerHappiness"
    }
    
    @IBAction func changeHappiness(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended:
            fallthrough
        case .changed:
            let translation = gesture.translation(in: faceView)
            let happinessChanged = -Int(translation.y / Constants.HappinessGestureScale)
            if happinessChanged != 0 {
                happiness += happinessChanged
                gesture.setTranslation(CGPoint.zero, in: faceView)
            }
        default:
            break
        }
    }
    
    fileprivate func updateUI() {
        faceView.setNeedsDisplay()
    }
    
    func smilinessForFaceView(_ sender: FaceView) -> Double? {
        
        return Double(happiness - 50) / 50
    }
    
    override func viewDidLoad() {
        happiness = Int(defaults.value(forKey: "HappinessViewControllerHappiness") as? NSNumber ?? 75)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        defaults.set(happiness, forKey: "HappinessViewControllerHappiness")
    }
}

