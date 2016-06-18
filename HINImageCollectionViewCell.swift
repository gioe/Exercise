//
//  HINImageCollectionViewCell.swift
//  HingeExercise
//
//  Created by Matt Gioe on 6/13/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class HINImageCollectionViewCell: UICollectionViewCell {
    var image = HINImageModel?()

    @IBOutlet weak var thumbNailImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
   
    func configureImageForCellWithImage(image: HINImageModel) {

        guard image.returnCachedImage(image.name) != nil else {
            
            startActivityIndicator()
    
            thumbNailImage.image = UIImage.init(named: "Default")
            image.downloadImage(image.imageURL, imageName: image.name, completion: { (downloadedImage) in
                self.thumbNailImage.image = downloadedImage
                self.stopActivityIndicator()
            })

            return
        }
            thumbNailImage.image = image.returnCachedImage(image.name)
    
    }
    
    func startActivityIndicator(){
        if let activityIndicator = activityIndicator{
            activityIndicator.startAnimating()
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    func stopActivityIndicator(){
        if let activityIndicator = self.activityIndicator{
            activityIndicator.stopAnimating()
        }
    }

}
