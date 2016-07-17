//
//  ViewController.swift
//  FacialTracker
//
//  Created by Antonio Lopes Jr on 16/07/2016.
//  Copyright © 2016 EasyMob. All rights reserved.
//

import UIKit
import FaceTracker

class ViewController: UIViewController, FaceTrackerViewControllerDelegate {

    weak var faceTrackerViewController: FaceTrackerViewController?

    var moustacheView = UIImageView()
    var overlayViews = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(moustacheView)
        moustacheView.image = UIImage(named: "moustache01")
        moustacheView.contentMode = UIViewContentMode.ScaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "faceTrackerEmbed" {
            faceTrackerViewController = segue.destinationViewController as? FaceTrackerViewController;
            faceTrackerViewController?.delegate = self;
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        faceTrackerViewController!.startTracking { () -> Void in
            
        }
    }
    
    func updateViewForFeature(index: Int, point: CGPoint, bgColor: UIColor) {
        
        let frame = CGRectMake(point.x, point.y, 40.0, 6.0)
        
        if index < self.overlayViews.count {
            self.overlayViews[index].frame = frame
            self.overlayViews[index].hidden = false
        } else {
            
            let newView = UILabel(frame: frame)
            newView.text = "\(Int(index))"
            newView.font = UIFont(name: newView.font.fontName, size: 6)
            newView.textColor = UIColor.redColor()
            newView.hidden = false
            
            self.view.addSubview(newView)
            self.overlayViews += [newView]
        }
    }
    
    func faceTrackerDidUpdate(points: FacePoints?) {
        if let points = points {
            
//            for (index, point) in points.nose.enumerate() {
//                self.updateViewForFeature(index, point: point, bgColor: UIColor.yellowColor())
//                
//                print("\(index) -> \(point.x) - \(point.y)")
//            }

            let middleNose = points.nose[3]
            let middleMouth = points.outerMouth[3]
            let leftMouth = points.outerMouth[0]
            let rightMouth = points.outerMouth[6]
            
            let imageWith = (leftMouth.x - rightMouth.x) * 1.2
            let imageHeight = moustacheView.image?.size.height
            
            let yPosition = middleNose.y
            let xPosition = middleMouth.x - imageWith / 2
            
            moustacheView.frame = CGRectMake(xPosition, yPosition, imageWith, imageHeight!)
            moustacheView.hidden = false
            
        } else {
            moustacheView.hidden = true
        }
    }
    
}

