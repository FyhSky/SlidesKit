//
//  SKCache.swift
//  initialSlidesKit
//
//  Created by Jieyi Hu on 8/28/15.
//  Copyright © 2015 SenseWatch. All rights reserved.
//

import UIKit

internal class SKCache: NSObject {
    private var _dirPath : String!
    internal var dirPath : String {
        get{
            return _dirPath
        }
    }
    private var cachePath : String {
        get{
            return _dirPath.stringByAppendingPathComponent("cache")
        }
    }
    private var dirCache = [String : [String : AnyObject]]()
    internal init(dirPath : String){
        super.init()
        self._dirPath = dirPath
        load()
    }
    
    private func load() {
        do{
            let jsonStr = try String(contentsOfFile: cachePath, encoding: NSUTF8StringEncoding)
            let jsonData = jsonStr.dataUsingEncoding(NSUTF8StringEncoding)
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments)
            dirCache = jsonObject as! [String : [String : AnyObject]]
        } catch let error as NSError {
            print(error)
        }
    }
    
    internal func store() {
        do{
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dirCache, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
            try jsonStr?.writeToFile(cachePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print(error)
        }
    }
    
    internal func cacheOut(fileName : String) -> (numberOfPage : Int, thumbnail : UIImage)? {
        if let result = dirCache[fileName] {
            let numberOfPage = result["numberOfPages"] as! Int
            let thumbnail = ((result["thumbnail"] as! String).getImageFromBase64String())!
            return (numberOfPage, thumbnail)
        }
        else {
            return nil
        }
    }
    
    internal func cacheIn(info : SKInfo) {
        let fileName = info.fileName
        dirCache[fileName] = [String : AnyObject]()
        dirCache[fileName]!["numberOfPages"] = info.numberOfPages
        dirCache[fileName]!["thumbnail"] = info.thumbnail.base64Str
    }
}
