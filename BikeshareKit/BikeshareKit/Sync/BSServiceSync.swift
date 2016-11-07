//
//  BSServiceSync.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/19/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

extension BSManager {

    public func syncServices(_ callback: ((Error?) -> Void)? = nil) {
        print("Syncing services...")
        BSRouter.services.request(self.syncServicesCompletionHandler(callback))
    }

    internal func syncServicesCompletionHandler(_ callback: ((Error?) -> Void)? = nil) -> ((Data?, URLResponse?, Error?) -> Void) {
        return {[weak self](data, response, error) in
            guard let `self` = self else { return }

            if error != nil {
                callback?(error)
            } else if let failure = BSRouter.validateResponse(data, response: response) {
                callback?(failure)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    callback?(self.handleSuccessResponse(json as AnyObject?))
                } catch {
                    callback?(BSErrorType.InvalidResponse)
                }
            }
        }
    }


    internal func handleSuccessResponse(_ JSON: Any?) -> Error? {
        if let json = (JSON as? NSArray) as? [NSDictionary] {
            let retrievedServices = Set(json.map{BSService(data: $0)}.filter{$0 != nil}.map{$0!})
            print("initial count: \(self.services.count), retrieved \(retrievedServices.count)")

            //determine new services, add at the end
            let servicesToAdd = retrievedServices.subtracting(self.services)
            print("found \(servicesToAdd.count) services to add")

            //remove old
            let servicesToRemove = self.services.subtracting(retrievedServices)
            self.services.subtract(servicesToRemove)
            print("just removed outdated services. current count: \(self.services.count)")

            //update existing
            let servicesToUpdate = retrievedServices.intersection(self.services)
            print("updating \(servicesToUpdate.count) services")
            for rhs in servicesToUpdate {
                let index = self.services.index(of: rhs)!
                self.services[index].replace(withService: rhs)
            }

            //add new
            print("adding \(servicesToAdd.count) services")
            self.services.formUnion(servicesToAdd)

            print("final count: \(self.services.count)")
            self.refreshFavoriteService()

            servicesUpdatedAt = Date()
            return nil

        } else {
            return BSErrorType.InvalidResponse
        }
    }

    internal func refreshFavoriteService() {
        if self.favoriteService != nil {
            if let index = self.services.index(of: self.favoriteService!) {
                self.favoriteService!.replace(withService: self.services[index])
            } else {
                self.favoriteService = nil
            }
        }
    }

}
