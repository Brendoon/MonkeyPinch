//
//  ViewController.swift
//  MonkeyPinch
//
//  Created by Brendoon Ryos on 17/04/17.
//  Copyright © 2017 Brendoon Ryos. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var player: AVAudioPlayer?
    
    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
    @IBOutlet var bananaPan: UIPanGestureRecognizer!
    
    func playSound() -> AVAudioPlayer {
        let url = Bundle.main.url(forResource: "CollectBanana", withExtension: "wav")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player!.prepareToPlay()
            
        } catch let error {
            print(error.localizedDescription)
        }
        return player!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let filteredSubviews = self.view.subviews.filter { (x) -> Bool in
            x.isKind(of: UIImageView.self)
        }
        // 2
        for view in filteredSubviews  {
            // 3
            let recognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(recognizer:)))
            // 4
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
            
            //TODO: Add a custom gesture recognizer too
            recognizer.require(toFail: monkeyPan)
            recognizer.require(toFail: bananaPan)
        }
        
        player = playSound()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
       self.player?.play()
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        if recognizer.state == UIGestureRecognizerState.ended {
            // 1
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // 5
            UIView.animate(withDuration: Double(slideFactor * 2),
                                       delay: 0,
                                       // 6
                options: UIViewAnimationOptions.curveEaseOut,
                animations: {recognizer.view!.center = finalPoint },
                completion: nil)
        }
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

