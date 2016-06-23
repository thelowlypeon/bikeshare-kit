//
//  BSServiceSync.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/19/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

extension BSManager {

    public func syncServices(callback: ((NSError?) -> Void)? = nil) {
        print("Syncing services...")
        BSRouter.Services.request(self.syncServicesCompletionHandler(callback))
    }

    internal func syncServicesCompletionHandler(callback: ((NSError?) -> Void)? = nil) -> ((NSData?, NSURLResponse?, NSError?) -> Void) {
        return {[weak self](data, response, error) in
            guard let `self` = self else { return }

            if error != nil {
                callback?(error)
            } else if let failure = BSRouter.validateResponse(data, response: response) {
                callback?(failure)
            } else {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    callback?(self.handleSuccessResponse(json))
                } catch {
                    callback?(BSErrorType.InvalidResponse)
                }
            }
        }
    }


    internal func handleSuccessResponse(JSON: AnyObject?) -> NSError? {
        if let json = (JSON as? NSArray) as? [NSDictionary] {
            let retrievedServices = Set(json.map{BSService(data: $0)}.filter{$0 != nil}.map{$0!})
            print("initial count: \(self.services.count), retrieved \(retrievedServices.count)")

            //determine new services, add at the end
            let servicesToAdd = retrievedServices.subtract(self.services)
            print("found \(servicesToAdd.count) services to add")

            //remove old
            let servicesToRemove = self.services.subtract(retrievedServices)
            self.services.subtractInPlace(servicesToRemove)
            print("just removed outdated services. current count: \(self.services.count)")

            //update existing
            let servicesToUpdate = retrievedServices.intersect(self.services)
            print("updating \(servicesToUpdate.count) services")
            for rhs in servicesToUpdate {
                let index = self.services.indexOf(rhs)!
                self.services[index].replace(withService: rhs)
            }

            //add new
            print("adding \(servicesToAdd.count) services")
            self.services.unionInPlace(servicesToAdd)

            print("final count: \(self.services.count)")
            self.refreshFavoriteService()

            servicesUpdatedAt = NSDate()
            return nil

        } else {
            return BSErrorType.InvalidResponse
        }
    }

    internal func refreshFavoriteService() {
        if self.favoriteService != nil {
            if let index = self.services.indexOf(self.favoriteService!) {
                self.favoriteService!.replace(withService: self.services[index])
            } else {
                self.favoriteService = nil
            }
        }
    }

}