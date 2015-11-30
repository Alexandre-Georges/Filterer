//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var originalImage: UIImage? = nil
    var filteredImage: UIImage? = nil
    
    var originImageDisplayed: Bool = false
    var imageProcessor: AGImageProcessor = AGImageProcessor()
    
    var currentFilterName: AGFilterNames? = nil
    var filters: [AGFilterStruct] = [
        AGFilterStruct(filterName: AGFilterNames.BlackAndWhite, iconName: "grey_filter", intensitySlider: 60.0),
        AGFilterStruct(filterName: AGFilterNames.BlackAndWhite, iconName: "black_filter", intensitySlider: 100.0),
        AGFilterStruct(filterName: AGFilterNames.Brightness, iconName: "grey_white_filter", intensitySlider: 30.0),
        AGFilterStruct(filterName: AGFilterNames.Brightness, iconName: "black_white_filter", intensitySlider: 70.0),
        AGFilterStruct(filterName: AGFilterNames.ColourRed, iconName: "light_red_filter", intensitySlider: 25.0),
        AGFilterStruct(filterName: AGFilterNames.ColourRed, iconName: "red_filter", intensitySlider: 50.0),
        AGFilterStruct(filterName: AGFilterNames.ColourRed, iconName: "dark_red_filter", intensitySlider: 75.0),
        AGFilterStruct(filterName: AGFilterNames.ColourGreen, iconName: "light_green_filter", intensitySlider: 25.0),
        AGFilterStruct(filterName: AGFilterNames.ColourGreen, iconName: "green_filter", intensitySlider: 50.0),
        AGFilterStruct(filterName: AGFilterNames.ColourGreen, iconName: "dark_green_filter", intensitySlider: 75.0),
        AGFilterStruct(filterName: AGFilterNames.ColourBlue, iconName: "light_blue_filter", intensitySlider: 25.0),
        AGFilterStruct(filterName: AGFilterNames.ColourBlue, iconName: "blue_filter", intensitySlider: 50.0),
        AGFilterStruct(filterName: AGFilterNames.ColourBlue, iconName: "dark_blue_filter", intensitySlider: 75.0)
    ]
    
    @IBOutlet var primaryImageView: UIImageView!
    @IBOutlet var secondaryImageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var sliderView: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    
    @IBOutlet var filterCollectionView: UICollectionView!
    
    @IBOutlet var intensitySlider: UISlider!
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as! AGIconCell
        cell.imageView.image = UIImage(named: filters[indexPath.item].iconName)!
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let filter: AGFilterStruct = self.filters[indexPath.item]
        self.applyFilter(filter.filterName, intensity: filter.intensitySlider)
        self.intensitySlider.value = filter.intensitySlider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNewImage(UIImage(named: "landscape")!)
        
        self.secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
        self.secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
        self.filterCollectionView.dataSource = self
        self.filterCollectionView.delegate = self
        self.filterCollectionView.backgroundColor = UIColor.clearColor()
        
        self.sliderView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
        self.sliderView.translatesAutoresizingMaskIntoConstraints = false
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("onTapImage:"))
        gestureRecognizer.minimumPressDuration = 0.0
        self.primaryImageView.addGestureRecognizer(gestureRecognizer)
        self.primaryImageView.userInteractionEnabled = true
    }
    
    func onTapImage(gestureRecognizer: UILongPressGestureRecognizer) {
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Began:
            self.showSecondaryImageView()
            break;
            
        case UIGestureRecognizerState.Ended:
            self.showPrimaryImageView()
            break;
            
        default:
            break;
        }
    }

    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", primaryImageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.setNewImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        self.editButton.selected = false
        self.hideView(self.sliderView)
        if (sender.selected) {
            self.hideView(self.secondaryMenu)
            sender.selected = false
        } else {
            self.showView(self.secondaryMenu, height: 70)
            sender.selected = true
        }
    }
    
    func applyFilter(filterName: AGFilterNames, intensity: Float) {
        
        self.imageProcessor.setImage(self.originalImage!)
        self.imageProcessor.addFilter(filterName, intensity: intensity)
        self.imageProcessor.applyFilter()
        self.filteredImage = self.imageProcessor.getImage()
        
        self.primaryImageView.image = self.filteredImage
        
        self.hideView(self.secondaryMenu)
        self.filterButton.selected = false
        
        self.editButton.enabled = true
        self.compareButton.enabled = true
        
        self.currentFilterName = filterName
    }
    
    @IBAction func onIntensitySlider(sender: UISlider) {
        self.applyFilter(self.currentFilterName!, intensity: sender.value)
    }
    
    @IBAction func onEdit(sender: UIButton) {
        if (sender.enabled) {
            self.filterButton.selected = false
            self.hideView(self.secondaryMenu)
            if (sender.selected) {
                self.hideView(self.sliderView)
                sender.selected = false
            } else {
                self.showView(self.sliderView, height: 44.0)
                sender.selected = true
            }
        }
    }
    
    @IBAction func onCompare(sender: UIButton) {
        if (sender.enabled) {
            if (sender.selected) {
                self.showPrimaryImageView()
                sender.selected = false
            } else {
                self.showSecondaryImageView()
                sender.selected = true
            }
        }
    }
    
    func showView(subView: UIView, height: CGFloat) {
        
        self.view.addSubview(subView)
        
        let bottomConstraint = subView.bottomAnchor.constraintEqualToAnchor(self.bottomMenu.topAnchor)
        let leftConstraint = subView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor)
        let rightConstraint = subView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor)
        
        let heightConstraint = subView.heightAnchor.constraintEqualToConstant(height)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        self.view.layoutIfNeeded()
        
        subView.alpha = 0
        UIView.animateWithDuration(0.6) {
            subView.alpha = 1.0
        }
    }

    func hideView(view: UIView) {
        UIView.animateWithDuration(0.6, animations: {
            view.alpha = 0
            }) { completed in
                if completed == true {
                    view.removeFromSuperview()
                }
        }
    }
    
    func showPrimaryImageView() {
        UIView.animateWithDuration(0.4) {
            self.primaryImageView.alpha = 1
        }
        self.originImageDisplayed = false
    }
    func showSecondaryImageView() {
        UIView.animateWithDuration(0.4) {
            self.primaryImageView.alpha = 0
        }
        self.originImageDisplayed = true
    }
    func setNewImage(image: UIImage) {
        self.originalImage = image
        self.filteredImage = image
        
        self.primaryImageView.image = self.originalImage
        self.secondaryImageView.image = self.filteredImage
        self.originImageDisplayed = true
        
        self.compareButton.selected = false
        self.compareButton.enabled = false
        self.filterButton.selected = false
        self.editButton.selected = false
        self.editButton.enabled = false
        self.hideView(self.secondaryMenu)
        self.hideView(self.sliderView)
    }

}

