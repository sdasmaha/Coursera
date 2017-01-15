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
    
    var currentMoustacheImageView = UIImageView()
    var currentMoustacheImageIndex: Int = -1
    var moustacheImageCollection: [UIImage] = []
    
    var currentHatImageView = UIImageView()
    var currentHatImageIndex: Int = -1
    var hatImageCollection: [UIImage] = []
    
    var overlayViews = [UIView]()
    
    @IBOutlet var imagePickerView: UIView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var isRotated = false
    @IBOutlet var mainButton: UIButton!
    @IBOutlet var moustacheButton: UIButton!
    @IBOutlet var glassesButton: UIButton!
    @IBOutlet var hatButton: UIButton!
    
    var featureImage: FeatureImage!
    enum FeatureImage {
        case Moustache
        case Hat
    }
    
    // MARK: Others
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(self.currentMoustacheImageView)
        self.currentMoustacheImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.view.addSubview(self.currentHatImageView)
        self.currentHatImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.fillImageCollection()
        
        self.moustacheButton.alpha = 0
        self.hatButton.alpha = 0
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
        self.moustacheImageCollection.removeAll()
        self.moustacheImageCollection.append(UIImage(named: "moustache01")!)
        self.moustacheImageCollection.append(UIImage(named: "moustache02")!)
        self.moustacheImageCollection.append(UIImage(named: "moustache03")!)
        self.moustacheImageCollection.append(UIImage(named: "cancel")!)
        
        self.hatImageCollection.removeAll()
        self.hatImageCollection.append(UIImage(named: "hat01")!)
        self.hatImageCollection.append(UIImage(named: "hat02")!)
        self.hatImageCollection.append(UIImage(named: "hat03")!)
        self.hatImageCollection.append(UIImage(named: "cancel")!)
    }
    
    func setImageCollection(featureImage: FeatureImage) {
        self.featureImage = featureImage
        
        //Display
        self.imageCollectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.featureImage! {
        case FeatureImage.Moustache:
            return self.moustacheImageCollection.count
        default:
            return self.hatImageCollection.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Images", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        switch self.featureImage! {
        case FeatureImage.Moustache:
            cell.ImagePreview.image = self.moustacheImageCollection[indexPath.row]
            break
        default:
            cell.ImagePreview.image = self.hatImageCollection[indexPath.row]
            break
        }
        
        cell.clipsToBounds = true
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        //Cell Corner Radius
        cell.layer.cornerRadius = 8
        
        return cell
        
    }
    
    //Cell touched action
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch self.featureImage! {
        case FeatureImage.Moustache:
            self.currentMoustacheImageIndex = indexPath.row
        default:
            self.currentHatImageIndex = indexPath.row
        }
        
        UIView.animateWithDuration(0.4, animations: {
            self.imagePickerView.alpha = 0
        }) { (complete) in
            if(complete == true) {
                self.imagePickerView.removeFromSuperview()
            }
        }
    }
    
    // MARK: Button area
    @IBAction func onClickMainButton(sender: UIButton) {
        animateFloatingButtons()
    }
    
    func animateFloatingButtons() {
        if (isRotated) {
            UIView.animateWithDuration(0.5) { () -> Void in
                self.mainButton.transform = CGAffineTransformMakeRotation(0)
            }
            UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
                self.moustacheButton.alpha = 0
                self.hatButton.alpha = 0
                self.isRotated = false
                }, completion: nil)
        } else {
            UIView.animateWithDuration(0.5) { () -> Void in
                self.mainButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 0.25))
            }
            UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
                self.moustacheButton.alpha = 0.5
                self.hatButton.alpha = 0.5
                self.isRotated = true
                }, completion: nil)
        }
    }
    
    @IBAction func onClickMoustacheButton() {
        setImageCollection(FeatureImage.Moustache)
        openImagePickerView()
    }
    
    @IBAction func onClickHatButton() {
        setImageCollection(FeatureImage.Hat)
        openImagePickerView()
    }
    
    func openImagePickerView() {
        self.imagePickerView.center = self.view.center
        self.imagePickerView.alpha = 0
        
        self.view.addSubview(self.imagePickerView)
        self.view.bringSubviewToFront(self.imagePickerView)
        
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
                self.imagePickerView.alpha = 1
            }) { (Bool) in
                self.animateFloatingButtons()
        }
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
//            
//            for (index, point) in points.outerMouth.enumerate() {
//                updateViewForFeature(index, point: point, bgColor: UIColor.yellowColor())
//            }
//        }
        
        self.currentMoustacheImageView.image = nil
        if (self.currentMoustacheImageIndex > -1 && self.currentMoustacheImageIndex < self.moustacheImageCollection.count - 1) {
            self.currentMoustacheImageView.image = self.moustacheImageCollection[self.currentMoustacheImageIndex]
            
            // Tracker for moustache
            moustacheFaceTracker(points)
        }
        
        self.currentHatImageView.image = nil
        if (self.currentHatImageIndex > -1 && self.currentHatImageIndex < self.hatImageCollection.count - 1) {
            self.currentHatImageView.image = self.hatImageCollection[self.currentHatImageIndex]
            
            // Tracker for hats
            hatFaceTracker(points)
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
            let innerMouthCornerDist = sqrt(pow(points.innerMouth[0].x - points.innerMouth[4].x, 2)) * 2.0
            
            let innerMouthCenter = CGPointMake(
                points.outerMouth[3].x,
                (points.innerMouth[0].y + points.innerMouth[4].y) / 2
            )
            
            let angle = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
            
            updateFaceTracker(self.currentMoustacheImageView, points: points, cornerDist: innerMouthCornerDist, center: innerMouthCenter, angle: angle)
            
        } else {
            self.currentMoustacheImageView.hidden = true;
        }
    }
    
    func hatFaceTracker(points: FacePoints?) {
        if let points = points {
            // Compute the hat frame
            let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2)) * 1.5
            
            let eyeToEyeCenter = CGPointMake(
                (points.leftEye[0].x + points.rightEye[5].x) / 2,
                (points.leftEye[0].y + points.rightEye[5].y) / 2
            )
            
            let angle = atan2(
                points.rightEye[5].y - points.leftEye[0].y,
                points.rightEye[5].x - points.leftEye[0].x
            )
            
            updateFaceTracker(self.currentHatImageView, points: points, cornerDist: eyeCornerDist, center: eyeToEyeCenter, angle: angle)
        } else {
            self.currentHatImageView.hidden = true
        }
    }
    
    func updateFaceTracker(imageView: UIImageView, points: FacePoints?, cornerDist: CGFloat, center: CGPoint, angle: CGFloat) {
        let viewWidth = cornerDist
        let viewHeight = (imageView.image!.size.height / imageView.image!.size.width) * viewWidth
            
        imageView.transform = CGAffineTransformIdentity
        imageView.frame = CGRectMake(center.x - viewWidth / 2, center.y - 1.3 * viewHeight, viewWidth, viewHeight)
        imageView.hidden = false
            
        setAnchorPoint(CGPointMake(0.5, 1.0), forView: imageView)
            
        imageView.transform = CGAffineTransformMakeRotation(angle)
    }
}

