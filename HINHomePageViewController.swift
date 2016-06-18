//
//  HINHomePageViewController.swift
//  HingeExercise
//
//  Created by Matt Gioe on 6/13/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import Foundation
import UIKit
import MNReachabilitySwift


private let ImageCollectionViewCellIdentifier = "ImageCell"
private let GallerySegueIdentifier = "pushGalleryView"

class HINHomePageViewController: UICollectionViewController, DeleteImageDelegate  {
    var imageViewModel : HINImageViewModel?
    let largeActivityIndicator : UIActivityIndicatorView? = UIActivityIndicatorView()
    
    @IBOutlet var imagesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        collectionView!.backgroundColor = UIColor.blackColor()
        showActivityIndicator()
        setUpNetworkObserver()
        registerDelegates()
        imageViewModel = HINImageViewModel.init { (success, error) -> (Void) in
            if success{
                self.imagesCollectionView.reloadData()
            } else{
                self.imageViewModel = nil
            }
        }
    }
    
    func setUpNetworkObserver (){
        MNReachability.sharedInstance.startNotifier() //start test
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HINHomePageViewController.networkChanged(_:)), name: kRealReachabilityChangedNotification, object: nil)
    }
    
    func networkChanged(notification:NSNotification) {
        let reachability:MNReachability = notification.object as! MNReachability
        let status:ReachabilityStatus = reachability.currentReachabilityStatus()
        
        switch status {
        case .ReachStatusNotReachable:
            throwNetworkBlocker()
        default:
            handleNextworkReconnect()
            break
        }
    }
    
    func handleNextworkReconnect(){
        guard imageViewModel != nil else {
            self.imageViewModel = HINImageViewModel.init { (success, error) -> (Void) in
                if success{
                    self.stopLargeIndicatorView()
                    self.imagesCollectionView.reloadData()
                } else{
                    self.imageViewModel = nil
                }
            }
            return
        }

        imagesCollectionView.reloadData()

    }
    
    //MARK : Indicator View Methods
    
    func showActivityIndicator(){
        largeActivityIndicator!.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        largeActivityIndicator!.center = self.view.center
        largeActivityIndicator!.hidesWhenStopped = true
        largeActivityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.view.addSubview(largeActivityIndicator!)
        largeActivityIndicator!.startAnimating()
    }
    
    func stopLargeIndicatorView(){
        if let inidicator = largeActivityIndicator{
            inidicator.removeFromSuperview()
        }
    }
    
    func registerDelegates(){
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
    }
    
    func throwNetworkBlocker(){
        let alert = UIAlertController.init(title: "Hinge", message: "It looks like you aren't connected to the internet. Feel free to continue to use the app and we'll automatically refresh your data once the connection has returned." , preferredStyle: .Alert)
        let dismissAction = UIAlertAction.init(title: "OK!", style: .Cancel, handler: { (action) in
            self.handleNextworkReconnect()
        })
    
        alert.addAction(dismissAction)
        
        self.presentViewController(alert, animated: true, completion: nil)

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? HINImageCollectionViewCell,
            indexPath = imagesCollectionView?.indexPathForCell(cell),
            destinationVC = segue.destinationViewController as? HINGalleryViewController {
            destinationVC.imageViewModel = imageViewModel
            destinationVC.deleteDelegate = self
            destinationVC.selectedIndex = indexPath.row
        }
    }
    
    
    // MARK: CollectionViewDelegate Methods

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let imageViewModel = imageViewModel {
            return imageViewModel.imagesArray.count
        } else {
            return 0
        }
    }
   
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
       return 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! HINImageCollectionViewCell
        if let imageViewModel = imageViewModel {
            cell.configureImageForCellWithImage(imageViewModel.imagesArray[indexPath.row])
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let imageViewModel = imageViewModel {
            return imageViewModel.setupCollectionViewCellSize()
        } else {
            return CGSizeMake(0, 0)
        }
    }
    

    // MARK: DeleteDelegate Method
    
    func imageWasDeleted(index : Int){
        if let imageViewModel = imageViewModel{
            imageViewModel.imagesArray.removeAtIndex(index)
            imagesCollectionView.reloadData()
        }
    }
}