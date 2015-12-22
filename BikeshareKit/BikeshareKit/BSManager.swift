//
//  BSManager.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/13/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import Alamofire

private var kBSManagerFavoriteService = "bikeshare_kit__favorite_service"
public class BSManager: NSObject {

    internal let baseURL: String = "http://api.stationtostationapp.com/v1/"

    public dynamic var servicesUpdatedAt: NSDate?
    public dynamic var services = Set<BSService>()

    public dynamic var favoriteService: BSService? {
        didSet {
            if let service = favoriteService {
                let data = NSKeyedArchiver.archivedDataWithRootObject(service)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: kBSManagerFavoriteService)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kBSManagerFavoriteService)
            }
        }
    }

    override public init() {
        super.init()

        if let unarchivedData = NSUserDefaults.standardUserDefaults().objectForKey(kBSManagerFavoriteService) as? NSData {
            self.favoriteService = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedData) as? BSService
        }
    }
}