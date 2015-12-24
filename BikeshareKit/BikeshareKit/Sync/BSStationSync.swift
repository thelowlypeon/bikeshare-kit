//
//  BSStationSync.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/22/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension BSService {
    internal var stationsSyncPath: String {
        get { return "\(API_BASE_URL)services/\(self.name!)/stations" }
    }
    public func syncStations(callback: ((NSError?) -> Void)?) {
        print("syncing stations for \(self.name!) at \(stationsSyncPath)")
        Alamofire.request(.GET, stationsSyncPath)
            .responseJSON(completionHandler: self.syncStationsCompletionHandler(callback))
    }

    internal func syncStationsCompletionHandler(callback: ((NSError?) -> Void)?) -> (Response<AnyObject, NSError> -> Void) {
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
            let retrievedStations = Set(json.map{BSStation(data: $0)}.filter{$0 != nil}.map{$0!})
            let stationsToRemove = self.stations.subtract(retrievedStations)
            self.stations.unionInPlace(retrievedStations)
            self.stations.subtractInPlace(stationsToRemove)

            stationsUpdatedAt = NSDate()
            return nil

        } else {
            return NSError(domain: "com.outofsomething",
                           code: -1,
                           userInfo: [NSLocalizedDescriptionKey: "Invalid response: \(JSON)"])
        }
    }

}