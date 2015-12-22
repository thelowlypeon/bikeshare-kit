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
    public func syncServices(callback: ((NSError?) -> Void)?) {
        Alamofire.request(.GET, "\(self.baseURL)services")
            .responseJSON(completionHandler: self.syncServicesCompletionHandler(callback))
    }

    internal func syncServicesCompletionHandler(callback: ((NSError?) -> Void)?) -> (Response<AnyObject, NSError> -> Void) {
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
            let servicesToRemove = self.services.subtract(retrievedServices)
            self.services.unionInPlace(retrievedServices)
            self.services.subtractInPlace(servicesToRemove)
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
        self.favoriteService = self.services.filter{$0 == self.favoriteService}.first
    }

}