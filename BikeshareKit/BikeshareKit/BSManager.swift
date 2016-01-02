//
//  BSManager.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/13/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import Alamofire

internal let API_BASE_URL: String = "https://api.stationtostationapp.com/v1/"
internal let IMAGE_BASE_URL: String = "https://api.stationtostationapp.com/images/"
internal var _manager: BSManager!
internal var _token: String!

public class BSManager: NSObject {

    public dynamic var servicesUpdatedAt: NSDate?
    public dynamic var services = Set<BSService>()
    public dynamic var favoriteService: BSService?

    public static func configure(config: [String: AnyObject]) {
        if let token = config["token"] as? String {
            _token = token
        }
    }

    public static func sharedManager() -> BSManager {
        if _manager == nil {
            _manager = BSManager(token: _token)
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

    public init(token: String) {
        _token = token
    }

    deinit {
        self.persist()
    }
}
