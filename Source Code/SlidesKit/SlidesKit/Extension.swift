//
//  Extension.swift
//  initialSlidesKit
//
//  Created by Jieyi Hu on 8/26/15.
//  Copyright © 2015 SenseWatch. All rights reserved.
//

import UIKit

internal extension String {
    
    var objcString : NSString {
        get{
            return (self as NSString)
        }
    }
    
    var pathComponents: [String] {
        get{
            return self.objcString.pathComponents
        }
    }
    
    var lastPathComponent: String {
        get{
            return self.objcString.lastPathComponent
        }
    }
    var stringByDeletingLastPathComponent: String {
        get{
            return self.objcString.stringByDeletingLastPathComponent
        }
    }
    func stringByAppendingPathComponent(str: String) -> String {
        return self.objcString.stringByAppendingPathComponent(str)
    }
    
    var pathExtension: String {
        get{
            return self.objcString.pathExtension
        }
    }
    var stringByDeletingPathExtension: String {
        get{
            return self.objcString.stringByDeletingPathExtension
        }
    }
    func stringByAppendingPathExtension(str: String) -> String? {
        return self.objcString.stringByAppendingPathExtension(str)
    }
    
    func stringsByAppendingPaths(paths: [String]) -> [String] {
        return self.objcString.stringsByAppendingPaths(paths)
    }
    
    
    func fileExistWithTypes(types : [String]) -> Int {
        var isDir = ObjCBool(false)
        if NSFileManager.defaultManager().fileExistsAtPath(self, isDirectory: &isDir) {
            //  file exist
            if isDir.boolValue {
                //  is directory
                return 0
            } else {
                //  file exist and it is not a directory
                let ext = self.pathExtension
                if types.map({type in type.uppercaseString}).contains(ext.uppercaseString) {
                    //  has valid type
                    return 1
                } else {
                    //  file exist but wrong type
                    return -2
                }
            }
        } else {
            //  file does not exist
            return -1
        }
    }
    
    func slidesExist() -> Bool {
        return self.fileExistWithTypes(["PDF","PPT","PPTX"]) == 1 ? true : false
    }
    
    func hasSlidesExtension() -> Bool {
        let upper = self.uppercaseString
        return (upper.hasSuffix("PPT")||upper.hasSuffix("PPTX")||upper.hasSuffix("PDF"))
    }
    
    func getImageFromBase64String() -> UIImage? {
        return UIImage(data: NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!)
    }
    
    func dirExist() -> Bool {
        var isDir = ObjCBool(false)
        if NSFileManager.defaultManager().fileExistsAtPath(self, isDirectory: &isDir) {
            if isDir {
                //  dirPath exists, and it is directory
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
}


internal extension UIWebView {
    
    func getNumberOfPages() -> Int {
        let slideClassString = "<div class=\"slide\""
        let html = self.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")
        let count = (html?.componentsSeparatedByString(slideClassString).count)! - 1
        return count
    }
    
    func loadRequest(filePath filePath : String) {
        let url = NSURL(fileURLWithPath: filePath)
        let request = NSURLRequest(URL: url)
        self.loadRequest(request)
    }
    
    func removePageGap() {
        self.stringByEvaluatingJavaScriptFromString("var slides = document.getElementsByClassName('slide');var count = slides.length;for (var i = 1; i < count; i++) {var oldTop = slides[i].style.top;var newTop = parseInt(oldTop) - 5 * i + 'px';slides[i].style.top = newTop;}")
    }
    
    func getScreenshot() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

internal extension UIImage {
    var base64Str : String? {
        get{
            return UIImagePNGRepresentation(self)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        }
    }
    func resize(newSize : CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize,false,0.0)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

internal extension CGPDFDocument {
    
    var numberOfPages : Int {
        let numberOfPages = CGPDFDocumentGetNumberOfPages(self)
        return numberOfPages
    }
    
    func getPageImage(pageNumber : Int) -> UIImage? {
        
        // http://stackoverflow.com/questions/4639781/rendering-a-cgpdfpage-into-a-uiimage
        
        if pageNumber <= self.numberOfPages {
            
            //  Get the page
            let page = CGPDFDocumentGetPage(self, pageNumber)
            
            let pageRect = CGPDFPageGetBoxRect(page, CGPDFBox.MediaBox)
            
            //  Set up box and rect
            
            UIGraphicsBeginImageContext(pageRect.size)
            
            let context = UIGraphicsGetCurrentContext()
            
            //  White Background
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
            CGContextFillRect(context, pageRect)
            CGContextSaveGState(context)
            
            // Next 3 lines makes the rotations so that the page look in the right direction
            CGContextTranslateCTM(context, 0.0, pageRect.size.height)
            CGContextScaleCTM(context, 1.0, -1.0)
            CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(page, CGPDFBox.MediaBox, pageRect, 0, true))
            
            
            CGContextDrawPDFPage(context, page)
            CGContextRestoreGState(context)
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return img
            
        } else {
            return nil
        }
    }
}

internal extension UIView {
    func paddedWithView(view : UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
    }
}

