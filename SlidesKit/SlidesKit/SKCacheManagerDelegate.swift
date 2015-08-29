//
//  SKCacheManagerDelegate.swift
//  embeddedSK
//
//  Created by Jieyi Hu on 8/29/15.
//  Copyright © 2015 fullstackpug. All rights reserved.
//

import UIKit

public protocol SKCacheManagerDelegate {
    func retrieveDidFinish(cacheManager : SKCacheManager, infos : [SKInfo])
}
