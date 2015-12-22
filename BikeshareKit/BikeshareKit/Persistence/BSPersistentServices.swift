//
//  BSPersistentServices.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/22/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

private var kBSManagerServices = "bikeshare_kit__services"
private var kBSManagerFavoriteServiceID = "bikeshare_kit__favorite_service_id"
extension BSManager {

    public func persistServices() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(services)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: kBSManagerServices)
    }

    public func persistFavoriteService() {
        if let service = favoriteService {
            NSUserDefaults.standardUserDefaults().setInteger(service.id, forKey: kBSManagerFavoriteServiceID)
        } else {
            //cannot remove integer for some reason, so set it to invalid ID
            NSUserDefaults.standardUserDefaults().setInteger(-1, forKey: kBSManagerFavoriteServiceID)
        }
    }

    public func restoreServices() {
        if let unarchivedServicesData = NSUserDefaults.standardUserDefaults().objectForKey(kBSManagerServices) as? NSData {
            if let unarchivedServices = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedServicesData) as? Set<BSService> {
                self.services = unarchivedServices
            }
        }
    }

    //caution! do this only after services are restored or otherwise populated
    // calling this with no services in self.services will remove favorite
    public func restoreFavoriteService() {
        let favoriteServiceID = NSUserDefaults.standardUserDefaults().integerForKey(kBSManagerFavoriteServiceID)
        self.favoriteService = BSService(id: favoriteServiceID, data: NSDictionary())
        self.refreshFavoriteService()
    }

}