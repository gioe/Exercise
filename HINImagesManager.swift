//
//  HINImagesManager.swift
//  HingeExercise
//
//  Created by Matt Gioe on 6/13/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

private let ImageEndpoint = "https://hinge-homework.s3.amazonaws.com/client/services/homework.json"

class HINImagesManager : NSObject {
    
    var imagesArray : [HINImageModel] = []
    
    func createImagesArray(completion : (Bool, NSError?) -> Void) {
        fetchImages { (responseObject) in
            if responseObject is NSArray {
                self.imagesArray = self.parseJsonWithJson(responseObject)
                completion(true, nil)
            } else {
                completion(true, responseObject as? NSError)
            }
        }
    }
    
    func fetchImages(completion: (AnyObject) -> Void) {
        Alamofire.request(.GET, ImageEndpoint, parameters: nil)
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    completion(value as! NSArray)
                case .Failure(let value):
                    completion(value)
                }
        }
    }
    
    func parseJsonWithJson(responseObject : AnyObject) -> [HINImageModel] {
        
        let jsonArray = responseObject
        
        var finalArray = [HINImageModel]()
        
        jsonArray.enumerateObjectsUsingBlock { (image, idx, stop) in
            
            let dictionary = image as! NSDictionary
            
            if let imageUrl = dictionary["imageURL"]{
                let image = HINImageModel.init(name: dictionary["imageName"] as! String, imageUrl: imageUrl as! String, description: dictionary["imageDescription"] as! String)
                finalArray.append(image as HINImageModel)
            }
        }
        
        return finalArray
    }
    
    
}