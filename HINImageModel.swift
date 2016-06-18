//
//  ImageModel.swift
//  HingeExercise
//
//  Created by Matt Gioe on 6/13/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import Alamofire

class HINImageModel : NSObject {
    var name : String
    var imageURL : String
    var descriptionString : String
    let imageCache = AutoPurgingImageCache()
    var image : UIImage? {
        return grabImage()
    }
    
    init (name: String, imageUrl: String, description : String ) {
       
        self.name = name
        self.imageURL = imageUrl
        self.descriptionString = description
    }
    
    func grabImage() -> UIImage?{
        guard returnCachedImage(name) != nil else {
            downloadImage(imageURL, imageName: name, completion: { (image) in
            })
            return UIImage.init(named: "Default")
        }
        return returnCachedImage(name)
    }
    
    func downloadImage(urlString: String, imageName : String, completion: (UIImage -> Void)) -> (Request) {
        return Alamofire.request(.GET, urlString).responseImage { (response) -> Void in
            guard let image = response.result.value else {
                let defaultImage = UIImage.init(named: "Default")
                completion(defaultImage!)
                return
            }
            completion(image)
            self.imageCache.addImage(image, withIdentifier: imageName)
        }
    }
    
    func returnCachedImage(name: String) -> UIImage? {
        return imageCache.imageWithIdentifier(name)
    }
}