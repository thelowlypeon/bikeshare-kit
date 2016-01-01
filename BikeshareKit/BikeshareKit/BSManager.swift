//
//  BSManager.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/13/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import Alamofire

internal let API_BASE_URL: String = "http://api.stationtostationapp.com/v1/"
internal let IMAGE_BASE_URL: String = "http://api.stationtostationapp.com/images/"
internal var _manager: BSManager!
public class BSManager: NSObject {

    public dynamic var servicesUpdatedAt: NSDate?
    public dynamic var services = Set<BSService>()
    public dynamic var favoriteService: BSService?

    public static func sharedManager() -> BSManager {
        if _manager == nil {
            //TODO decide if .restore() should happen by default
            _manager = BSManager()
        }
        return _manager
    }

    public func persist() {
        self.persistServices()
        self.persistFavoriteService()
    }

    public func restore() {
        self.restoreServices()
        self.restoreFavoriteService()
    }

    internal convenience init(restore: Bool) {
        self.init()

        if restore {
            self.restore()
        }
    }

    deinit {
        self.persist()
    }
}