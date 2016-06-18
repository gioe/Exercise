//
//  HINGalleryViewController.swift
//  HingeExercise
//
//  Created by Matt Gioe on 6/13/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit


protocol DeleteImageDelegate {
    func imageWasDeleted(index: Int)
}

private let MaxScrollContentSize = 2

class HINGalleryViewController: UIViewController, UIScrollViewDelegate {
    
    var deleteDelegate = DeleteImageDelegate?()
    var imageViewModel = HINImageViewModel?()
    
    var images = [UIImageView]()
    var arrayCount : Int {
       return imageViewModel!.imagesArray.count
    }
    
    var selectedIndex : Int = 0
    var currentIndex : Int = 0
    var scrollTimer: NSTimer?
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        currentIndex = selectedIndex
        
        //going to implement on scrollview that only spans two windows. rather than initializing the entire image array, we only need enough to create the illusion that they're all there.
        
        for i in (0...MaxScrollContentSize - 1){
            let image = UIImageView(frame: CGRectMake(scrollView.frame.size.width * CGFloat(i), 0, scrollView.frame.width, scrollView.frame.height))
            images.append(image)
            if let imageViewModel = imageViewModel {
                image.image = imageViewModel.imagesArray[selectedIndex + i].grabImage()
                scrollView.addSubview(image)
            }
        }
       
        scrollView.contentSize = CGSizeMake(self.scrollView.frame.width * CGFloat(MaxScrollContentSize), self.scrollView.frame.height)
        
        scrollView.delegate = self
        
        setItemsForNavBar()
        startTimer()
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopTimer()
    }
    
    //MARK - Navbar Methods

    func setItemsForNavBar() {
        
        navigationItem.title = "\(currentIndex + 1)" + "/" + "\(arrayCount)"
        let deleteButton = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(HINGalleryViewController.throwDeletePop))
        self.navigationItem.rightBarButtonItem = deleteButton
        
    }
    
    func updateNavBar(){
       navigationItem.title =  "\(currentIndex + 1)" + "/" + "\(arrayCount)"
    }
    
    //MARK - Timer Convenience Methods

    func startTimer(){
        scrollTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector:
            #selector(HINGalleryViewController.moveToNextPage), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        guard scrollTimer != nil else {
            return
        }
        scrollTimer!.invalidate()
        scrollTimer = nil
    }

    //MARK - AlertViewMethod

    func throwDeletePop(){
        stopTimer()
        
        let alert = UIAlertController.init(title: "Hinge", message: "Are you sure you want to delete this image?" , preferredStyle: .Alert)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .Default, handler: { (action) in
           self.startTimer()
        })
        
        let deleteAction = UIAlertAction.init(title: "Delete", style: .Default) { (action) in
          
            if let deleteDelegate = self.deleteDelegate {
                deleteDelegate.imageWasDeleted(self.currentIndex)
                self.currentIndex -= 1
            }
           
            self.scrollView.scrollRectToVisible(CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, CGRectGetHeight(self.scrollView.frame)), animated: true)
            self.startTimer()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    func moveToNextPage(){
        
        scrollView.scrollRectToVisible(CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, CGRectGetHeight(self.scrollView.frame)), animated: true)
        
    }
    
    func nextIndex() -> Int{
        if currentIndex == arrayCount - 1{
            return 0
        } else{
            return currentIndex + 1
        }
    }
    
    // MARK: ScrollViewDelegate Method

    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        if currentIndex == arrayCount - 1{
            currentIndex = 0
        } else {
            currentIndex += 1
        }
       
        
        if let imageViewModel = self.imageViewModel{
            images[0].image = images[1].image
            scrollView.contentOffset.x = 0
            images[1].image = imageViewModel.imagesArray[nextIndex()].grabImage()
            updateNavBar()
        }
    }

}
