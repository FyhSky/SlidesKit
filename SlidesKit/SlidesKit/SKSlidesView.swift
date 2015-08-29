//
//  SKSlidesView.swift
//  initialSlidesKit
//
//  Created by Jieyi Hu on 8/28/15.
//  Copyright © 2015 SenseWatch. All rights reserved.
//

import UIKit

internal enum SKSlidesContentType{
    case PPT
    case PDF
}

public class SKSlidesView: UIView {

    private var viewsFrame : CGRect {
        get{
            return CGRectMake(0, 0, frame.width, frame.height)
        }
    }
    private var baseView : SKBaseSlidesView!
    private var coverView : UIView!
    private var contentType : SKSlidesContentType = .PDF {
        didSet{
            if oldValue != contentType {
                if contentType == .PDF {
                    self.baseView = SKPDFSlidesView(frame: frame)
                } else {
                    self.baseView = SKPPTSlidesView(frame: frame)
                }
                self.addSubview(baseView.view)
                bringSubviewToFront(coverView)
            }
        }
    }
    
    public var delegate : SKSlidesViewDelegate?

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func load(filePath : String) {
        
        //  for the first time
        if baseView == nil {
            baseView = SKPDFSlidesView(frame: viewsFrame)
            addSubview(baseView.view)
        }
        if coverView == nil {
            coverView = UIView(frame: viewsFrame)
            addSubview(coverView)
        }
        
        if filePath.slidesExist() {
            if filePath.uppercaseString.hasSuffix("PDF") {
                contentType = .PDF
            } else {
                contentType = .PPT
            }
            baseView.load(filePath, slidesDidLoad: slidesDidLoad)
        } else {
            print("SKSlidesViewController Error: Cannot load slides with invalid filePath = \(filePath)")
        }
    }
    
    private func slidesDidLoad() {
        delegate?.slidesDidLoad(self)
    }
    
    public func nextPage(){
        baseView.gotoPage(baseView.currentPage + 1)
    }
    public func prevPage(){
        baseView.gotoPage(baseView.currentPage - 1)
    }
    public func firstPage(){
        baseView.gotoPage(1)
    }
    public func finalPage(){
        baseView.gotoPage(baseView.numberOfPages)
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
