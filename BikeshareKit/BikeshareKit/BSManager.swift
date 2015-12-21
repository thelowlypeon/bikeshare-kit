//
//  BSManager.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/13/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import Alamofire

private var kBSManagerFavoriteServiceID = "bikeshare_kit__favorite_service_id"
public class BSManager: NSObject {

    internal let baseURL: String = "http://api.stationtostationapp.com/v1/"

    public dynamic var servicesUpdatedAt: NSDate?
    public dynamic var services = Set<BSService>()

    internal var favoriteServiceID: Int? {
        didSet {
            if let id = self.favoriteServiceID {
                let data = NSKeyedArchiver.archivedDataWithRootObject(id)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: kBSManagerFavoriteServiceID)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: kBSManagerFavoriteServiceID)
            }
        }
    }

    public dynamic var favoriteService: BSService? {
        set(service) { self.favoriteServiceID = service?.id }
        get { return self.services.filter{$0.id == self.favoriteServiceID}.first }
    }

    override public init() {
        super.init()

        if let unarchivedData = NSUserDefaults.standardUserDefaults().objectForKey(kBSManagerFavoriteServiceID) as? NSData {
            self.favoriteServiceID = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedData) as? Int
        }
    }
}