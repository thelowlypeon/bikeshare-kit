//
//  BSLocationServices.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 2/15/16.
//  Copyright © 2016 Out of Something, LLC. All rights reserved.
//

import Foundation
import CoreLocation

extension BSService {

    //return the n closest stations to a location
    // note: - does NOT guarantee an array of n stations
    //       - this is O(nlogn), so if you only need one station, use closestStation:toLocation
    public func closestStations(toLocation location: CLLocation, limit: Int = 3) -> [BSStation] {
        return Array(self.stations.sort({(a, b) -> Bool in
            return location.distanceToStation(a, isLessThan: b)
        }).prefix(limit))
    }

    //return closest station to a given location, if stations exist for this service
    // if you only need one station, use this method instead of closestStations:toLocation:limit!
    // this is O(n), whereas that sorts the whole array (O(nlogn))
    public func closestStation(toLocation location: CLLocation) -> BSStation? {
        var shortestDistance: CLLocationDistance?
        var closestStation: BSStation?
        for station in self.stations {
            if let distance = station.location?.distanceFromLocation(location) {
                if shortestDistance == nil || distance < shortestDistance! {
                    shortestDistance = distance
                    closestStation = station
                }
            }
        }
        return closestStation
    }

}

extension CLLocation {
    public func distanceToStation(lhs: BSStation, isLessThan rhs: BSStation) -> Bool {
        if lhs.location != nil && rhs.location != nil {
            return self.distanceFromLocation(lhs.location!) < self.distanceFromLocation(rhs.location!)
        }
        return lhs.location != nil
    }
}