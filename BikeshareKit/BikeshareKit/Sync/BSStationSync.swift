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

    /*
     * Note: This is quite a bit slower than the previous implementation:
     *   let retrievedStations = Set(json.map{BSStation(data: $0)}.filter{$0 != nil}.map{$0!})
     *   let stationsToRemove = self.stations.subtract(retrievedStations)
     *   self.stations.unionInPlace(retrievedStations)
     *   self.stations.subtractInPlace(stationsToRemove)
     * This is because the previous implementation replaced instances if isEqual returned true,
     * which caused KVO to fire unwanted notifications.
     *
     * TODO: determine if this causes significant performance issues
     *       Complexity: O(n)
     */
    internal func handleSuccessResponse(JSON: AnyObject?) -> NSError? {
        if let json = (JSON as? NSArray) as? [NSDictionary] {

            let retrievedStations = Set(json.map{BSStation(data: $0)}.filter{$0 != nil}.map{$0!})
            print("initial count: \(self.stations.count), retrieved \(retrievedStations.count)")

            //determine new stations, add at the end
            let stationsToAdd = retrievedStations.subtract(self.stations)
            print("found \(stationsToAdd.count) stations to add")

            //remove old
            let stationsToRemove = self.stations.subtract(retrievedStations)
            self.stations.subtractInPlace(stationsToRemove)
            print("just removed outdated stations. current count: \(self.stations.count)")

            //update existing
            let stationsToUpdate = retrievedStations.intersect(self.stations)
            print("updating \(stationsToUpdate.count) stations")
            for rhs in stationsToUpdate {
                let index = self.stations.indexOf(rhs)!
                print("updating \(self.stations[index].name) with \(rhs.name)")
                self.stations[index].replace(withStation: rhs)
            }

            //add new
            print("adding \(stationsToAdd.count) stations")
            self.stations.unionInPlace(stationsToAdd)

            stationsUpdatedAt = NSDate()
            return nil

        } else {
            return NSError(domain: "com.outofsomething",
                           code: -1,
                           userInfo: [NSLocalizedDescriptionKey: "Invalid response: \(JSON)"])
        }
    }

}