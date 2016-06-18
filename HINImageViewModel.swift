//
//  HINImageViewModel.swift
//  HingeExercise
//
//  Created by Matt Gioe on 6/13/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit

typealias HINImagesCallBack = (Bool, NSError?) -> (Void)

class HINImageViewModel : NSObject {
    let imagesManager = HINImagesManager()
    var imagesArray : [HINImageModel] = []
    
    init (callBack : HINImagesCallBack){
        super.init()
        self.setupImages({ (success, error) -> (Void) in
            callBack(success, error)
        })
    }
    
    func setupImages(compeletion : HINImagesCallBack){
        self.imagesManager.createImagesArray{ (success, error) in
            
            guard error == nil else {
                compeletion(false, error)
                return
            }
            
            self.imagesArray = self.imagesManager.imagesArray
            compeletion(success, nil)
        }
    }
    
    func setupCollectionViewCellSize() -> CGSize {
    
        if DeviceType.IS_IPHONE_5 {
            return CGSizeMake(120, 120)
        }else if DeviceType.IS_IPHONE_6 {
            return CGSizeMake(130, 130)
        } else if DeviceType.IS_IPHONE_6P{
            return CGSizeMake(130, 130)
        } else {
            return CGSizeMake(100, 100)
        }
    }
}
