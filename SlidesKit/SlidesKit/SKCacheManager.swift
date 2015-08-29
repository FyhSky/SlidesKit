//
//  SKCacheManager.swift
//  initialSlidesKit
//
//  Created by Jieyi Hu on 8/28/15.
//  Copyright © 2015 SenseWatch. All rights reserved.
//

import UIKit

public class SKCacheManager: NSObject, UIWebViewDelegate {

    private var _dirPath : String = ""
    public var dirPath: String {
        get{
            return _dirPath
        }
    }
    private var dirCache : SKCache!
    private var waitlist = [SKInfo]()
    private var resultList = [SKInfo]()
    private var firstOnList : SKInfo {
        get{
            return waitlist[0]
        }
    }
    
    private var webView = UIWebView(frame: SKStandard.thumbnailFrame)
    public var delegate : SKCacheManagerDelegate?
    
    public init?(dirPath : String){
        super.init()
        webView.delegate = self
        if dirPath.dirExist() {
            _dirPath = dirPath
            dirCache = SKCache(dirPath: dirPath)
        } else {
            print("SKCache Error: Cannot retrieve cache with invalid dirPath = \(dirPath)")
            return nil
        }
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        //  set cache info
        firstOnList.setNumberOfPageAndThumbnail(webView.getNumberOfPages(), thumbnail: webView.getScreenshot())
        moveToResultList()
    }
    
    public func retrieve() {
        scanDir()
        runList()
    }
    
    
    private func scanDir() {
        //  iterate thru dirPath
        let dirPathEnum = NSFileManager.defaultManager().enumeratorAtPath(dirPath)
        while let element = dirPathEnum?.nextObject() as? String {
            if element.hasSlidesExtension() {
                if let fileCache = dirCache.cacheOut(element) {
                    let info = SKInfo(dirPath: dirPath, fileName: element)
                    info.setNumberOfPageAndThumbnail(fileCache.numberOfPage, thumbnail: fileCache.thumbnail)
                    resultList.append(info)
                } else {
                    waitlist.append(SKInfo(dirPath: dirPath, fileName: element))
                }
            }
        }
    }
    
    private func runList() {
        if waitlist.count > 0 {
            if firstOnList.type == "PDF" {
                if let pdf = CGPDFDocumentCreateWithURL(NSURL(fileURLWithPath: firstOnList.filePath)) {
                    //  set cache info
                    firstOnList.setNumberOfPageAndThumbnail(pdf.numberOfPages, thumbnail: pdf.getPageImage(1)!.resize(SKStandard.thumbnailSize))
                    moveToResultList()
                } else {
                    /*  Do nothing  */
                }
            } else {
                webView.loadRequest(filePath: firstOnList.filePath)
            }
        } else {
            //  store cache
            dirCache.store()
            //  fire complete callback
            delegate?.retrieveDidFinish(self, infos: resultList)
        }
    }
    
    private func moveToResultList() {
        dirCache.cacheIn(firstOnList)
        resultList.append(firstOnList)
        waitlist.removeFirst()
        runList()
    }
}
