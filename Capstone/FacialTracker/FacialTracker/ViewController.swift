//
//  ViewController.swift
//  FacialTracker
//
//  Created by Antonio Lopes Jr on 16/07/2016.
//  Copyright © 2016 EasyMob. All rights reserved.
//

import UIKit
import FaceTracker

class ViewController: UIViewController, UICollectionViewDataSource, FaceTrackerViewControllerDelegate {

    // MARK: Local Variables
    weak var faceTrackerViewController: FaceTrackerViewController?
    var currentImageView = UIImageView()
    var currentImageIndex: Int = -1
    var overlayViews = [UIView]()
    var imageCollection: [UIImage] = []
    
    @IBOutlet var imagePickerView: UIView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    // MARK: Others
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(currentImageView)
        currentImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.fillImageCollection()
        openImagePickerView()
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
    
    // MARK: CollectionView
    
    func fillImageCollection() {
        self.imageCollection.append(UIImage(named: "moustache01")!)
        self.imageCollection.append(UIImage(named: "moustache02")!)
        self.imageCollection.append(UIImage(named: "moustache03")!)
        self.imageCollection.append(UIImage(named: "hat01")!)
        self.imageCollection.append(UIImage(named: "hat02")!)
        self.imageCollection.append(UIImage(named: "hat03")!)
        
        //Display
        self.imageCollectionView.reloadData()
    }
    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return self.imageCollection.count
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Images", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        cell.ImagePreview.image = self.imageCollection[indexPath.row]
        
        cell.clipsToBounds = true
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        //Cell Corner Radius
        cell.layer.cornerRadius = 8
        
        return cell
        
    }
    
    //Cell touched action
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentImageIndex = indexPath.row
        
        UIView.animateWithDuration(0.4, animations: {
            self.imagePickerView.alpha = 0
        }) { (complete) in
            if(complete == true) {
                self.imagePickerView.removeFromSuperview()
            }
        }
    }

    // MARK: Button area
    @IBAction func onClickImageSelector(sender: AnyObject) {
        openImagePickerView()
    }
    
    func openImagePickerView() {
        self.imagePickerView.center = self.view.center
        self.imagePickerView.alpha = 0
        
        self.view.addSubview(self.imagePickerView)
        self.view.bringSubviewToFront(self.imagePickerView)
        
        UIView.animateWithDuration(0.4, animations: {
            self.imagePickerView.alpha = 1
        })
    }
    
    // MARK: Face Tracker
    
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
        
//        if let points = points {
//            
//            for (index, point) in points.innerMouth.enumerate() {
//                updateViewForFeature(index, point: point, bgColor: UIColor.redColor())
//            }
//        }
        
        if self.currentImageIndex > -1  {
            self.currentImageView.image = self.imageCollection[self.currentImageIndex]
            
            // Tracker for hats
            if self.currentImageIndex > 2 {
                hatFaceTracker(points)
            // Tracker for moustache
            } else {
                moustacheFaceTracker(points)
            }
        }
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    func moustacheFaceTracker(points: FacePoints?) {
        
        if let points = points {
            // Compute the frame
            let innerMouthCornerDist = sqrt(pow(points.innerMouth[0].x - points.innerMouth[4].x, 2))
            let innerMouthCenter = CGPointMake((points.innerMouth[0].x + points.innerMouth[4].x) / 2, (points.innerMouth[0].y + points.innerMouth[4].y) / 2)
            
            let angle = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
            
            updateFaceTracker(points, cornerDist: innerMouthCornerDist, center: innerMouthCenter, angle: angle)
            
        } else {
            currentImageView.hidden = true
        }
    }
    
    func hatFaceTracker(points: FacePoints?) {
        if let points = points {
            // Compute the hat frame
            let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
            let eyeToEyeCenter = CGPointMake((points.leftEye[0].x + points.rightEye[5].x) / 2, (points.leftEye[0].y + points.rightEye[5].y) / 2)
            
            let angle = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
            
            updateFaceTracker(points, cornerDist: eyeCornerDist, center: eyeToEyeCenter, angle: angle)
        } else {
            currentImageView.hidden = true
        }
    }
    
    func updateFaceTracker(points: FacePoints?, cornerDist: CGFloat, center: CGPoint, angle: CGFloat) {
        let viewWidth = 2.0 * cornerDist
        let viewHeight = (currentImageView.image!.size.height / currentImageView.image!.size.width) * viewWidth
            
        currentImageView.transform = CGAffineTransformIdentity
        currentImageView.frame = CGRectMake(center.x - viewWidth / 2, center.y - 1.3 * viewHeight, viewWidth, viewHeight)
        currentImageView.hidden = false
            
        setAnchorPoint(CGPointMake(0.5, 1.0), forView: currentImageView)
            
        currentImageView.transform = CGAffineTransformMakeRotation(angle)
    }
}

