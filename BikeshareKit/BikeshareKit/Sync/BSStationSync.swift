//
//  BSStationSync.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/22/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

extension BSService {

    public func syncStations(_ callback: ((Error?) -> Void)? = nil) {
        print("Syncing stations in \(self)")
        BSRouter.stations(self).request(self.syncStationsCompletionHandler(callback))
    }

    internal func syncStationsCompletionHandler(_ callback: ((Error?) -> Void)? = nil) -> ((Data?, URLResponse?, Error?) -> Void) {
        return {[weak self](data, response, error) in
            guard let `self` = self else { return }

            if error != nil {
                callback?(error)
            } else if let failure = BSRouter.validateResponse(data, response: response) {
                callback?(failure)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    callback?(self.handleSuccessResponse(json as AnyObject?))
                } catch {
                    callback?(BSErrorType.InvalidResponse)
                }
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
    internal func handleSuccessResponse(_ JSON: Any?) -> NSError? {
        if let json = (JSON as? NSArray) as? [NSDictionary] {

            let retrievedStations = Set(json.map{
                    BSStation(data: $0)
                }.filter{
                    $0 != nil
                }.map{
                    $0!
                }.filter{
                    $0.active || _includeInactiveStations
                }
            )
            print("initial count: \(self.stations.count), retrieved \(retrievedStations.count)")

            //determine new stations, add at the end
            let stationsToAdd = retrievedStations.subtracting(self.stations)
            print("found \(stationsToAdd.count) stations to add")

            //remove old
            let stationsToRemove = self.stations.subtracting(retrievedStations)
            self.stations.subtract(stationsToRemove)
            print("just removed outdated stations. current count: \(self.stations.count)")

            //update existing
            let stationsToUpdate = retrievedStations.intersection(self.stations)
            print("updating \(stationsToUpdate.count) stations")
            for rhs in stationsToUpdate {
                let index = self.stations.index(of: rhs)!
                self.stations[index].replace(withStation: rhs)
            }

            //add new
            print("adding \(stationsToAdd.count) stations")
            self.stations.formUnion(stationsToAdd)

            stationsUpdatedAt = Date()
            return nil

        } else {
            return BSErrorType.InvalidResponse
        }
    }

}
