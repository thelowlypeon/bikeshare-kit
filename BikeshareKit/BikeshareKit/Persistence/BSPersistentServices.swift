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
        let data = NSKeyedArchiver.archivedData(withRootObject: services)
        UserDefaults.standard.set(data, forKey: kBSManagerServices)
    }

    public func persistFavoriteService() {
        if let service = favoriteService {
            UserDefaults.standard.set(service.id, forKey: kBSManagerFavoriteServiceID)
        } else {
            //cannot remove integer for some reason, so set it to invalid ID
            UserDefaults.standard.set(-1, forKey: kBSManagerFavoriteServiceID)
        }
    }

    public func restoreServices() {
        if let unarchivedServicesData = UserDefaults.standard.object(forKey: kBSManagerServices) as? Data {
            if let unarchivedServices = NSKeyedUnarchiver.unarchiveObject(with: unarchivedServicesData) as? Set<BSService> {
                self.services = unarchivedServices
            }
        }
    }

    //caution! do this only after services are restored or otherwise populated
    // calling this with no services in self.services will remove favorite
    public func restoreFavoriteService() {
        let favoriteServiceID = UserDefaults.standard.integer(forKey: kBSManagerFavoriteServiceID)
        // do not call refreshFavoriteService because that will yield a different service instance
        self.favoriteService = self.services.filter{$0.id == favoriteServiceID}.first
    }

}
