import UIKit
import FaceTracker

class ViewController: UIViewController, FaceTrackerViewControllerDelegate {
    var hatView = UIImageView()
    var faceTrackerViewController: FaceTrackerViewController?
    var pointViews = [UIView]()
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var faceTrackerContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.insertSubview(hatView, aboveSubview: faceTrackerContainerView)
        hatView.image = UIImage(named: "hat")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        faceTrackerViewController!.startTracking { () -> Void in
            @IBOutlet weak var ImageCollectionView: UICollectionView!
            @IBOutlet var imagePickerView: UIView!
            @IBOutlet var SelectGraphicView: UIView!
            @IBOutlet var imagePickerView: UIView!
            @IBOutlet var SelectImageView: UIView!
            @IBOutlet var ImagePickerView: UIView!
            @IBOutlet var imagePickerView: UIView!
            @IBOutlet var imagePickerView: UIView!
            @IBOutlet var imagePickerView: UIView!
            self.activityIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "embedFaceTrackerViewController") {
            faceTrackerViewController = segue.destinationViewController as? FaceTrackerViewController
            faceTrackerViewController!.delegate = self
        }
    }
    
    @IBAction func optionsButtonPressed(sender: UIButton) {
        let alert = UIAlertController()
        alert.popoverPresentationController?.sourceView = optionsButton
        
        alert.addAction(UIAlertAction(title: "Swap Camera", style: .Default, handler: { (action) -> Void in
            self.faceTrackerViewController!.swapCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        @IBOutlet weak var onClickImageSelector: UIButton!
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
    
    func faceTrackerDidUpdate(points: FacePoints?) {
        if let points = points {
            // Allocate some views for the points if needed
            if (pointViews.count == 0) {
                let numPoints = points.getTotalNumberOFPoints()
                for _ in 0...numPoints {
                    let view = UIView()
                    view.backgroundColor = UIColor.greenColor()
                    self.view.addSubview(view)
                    
                    pointViews.append(view)
                }
            }

            
            // Set frame for each point view
            points.enumeratePoints({ (point, index) -> Void in
                let pointView = self.pointViews[index]
                @IBAction func onClickPlusButton(sender: UIButton) {
                }
                let pointSize: CGFloat = 4
                
                pointView.hidden = false
                pointView.frame = CGRectIntegral(CGRectMake(point.x - pointSize / 2, point.y - pointSize / 2, pointSize, pointSize))
            })
            
            // Compute the hat frame
            let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
            let eyeToEyeCenter = CGPointMake((points.leftEye[0].x + points.rightEye[5].x) / 2, (points.leftEye[0].y + points.rightEye[5].y) / 2)
            
            let hatWidth = 2.0 * eyeCornerDist
            let hatHeight = (hatView.image!.size.height / hatView.image!.size.width) * hatWidth
            
            hatView.transform = CGAffineTransformIdentity
            
            hatView.frame = CGRectMake(eyeToEyeCenter.x - hatWidth / 2, eyeToEyeCenter.y - 1.3 * hatHeight, hatWidth, hatHeight)
            hatView.hidden = false
            
            setAnchorPoint(CGPointMake(0.5, 1.0), forView: hatView)
            
            let angle = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
            hatView.transform = CGAffineTransformMakeRotation(angle)
        }
        else {
            hatView.hidden = true
            
            for view in pointViews {
                view.hidden = true
            }
        }
    }
}

