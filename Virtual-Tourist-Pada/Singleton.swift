//
//  PhotosSingleton.swift
//  Virtual-Tourist-Pada
//
//  Created by Brenna Pada on 10/2/22.
//

import Foundation

// from my On the Map project submission feedback and with help from https://knowledge.udacity.com/questions/900468
class PhotosSingleton: NSObject {
    
    var photos = [Photo]()
    
    class func sharedInstance() -> PhotosSingleton {
        struct Singleton {
            static var sharedInstance = PhotosSingleton()
        }
        return Singleton.sharedInstance
    }
}

class APISingleton: NSObject {
    
    var APIPhotoVar = [APIPhoto]()
    
    class func sharedInstance() -> APISingleton {
        struct Singleton {
            static var sharedInstance = APISingleton()
        }
        return Singleton.sharedInstance
    }
}

class PinSingleton: NSObject {
    
    var pins = [Pin]()
    
    class func sharedInstance() -> PinSingleton {
        struct Singleton {
            static var sharedInstance = PinSingleton()
        }
        return Singleton.sharedInstance
    }
}

