//
//  BSServiceSync.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/19/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension BSManager {
    public func syncServices(callback: ((NSError?) -> Void)? = nil, progress: ((Int64, Int64, Int64) -> Void)? = nil) {
        print("syncing services...")
        request(.GET, "\(API_BASE_URL)services")
            .progress(progress)
            .responseJSON(completionHandler: self.syncServicesCompletionHandler(callback))
    }

    internal func syncServicesCompletionHandler(callback: ((NSError?) -> Void)? = nil) -> (Response<AnyObject, NSError> -> Void) {
        print("received response from syncing")
        return {[weak self](response) -> Void in
            switch response.result {
            case .Success(let JSON):
                callback?(self?.handleSuccessResponse(JSON))
                break
            case .Failure(let error):
                callback?(error)
                break
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
                print("updating \(self.services[index].name) with \(rhs.name)")
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
            return NSError(domain: "com.outofsomething",
                           code: -1,
                           userInfo: [NSLocalizedDescriptionKey: "Invalid response: \(JSON)"])
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