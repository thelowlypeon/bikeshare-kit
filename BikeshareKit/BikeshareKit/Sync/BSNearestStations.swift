//
//  BSNearestStations.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 10/17/18.
//  Copyright © 2018 Out of Something, LLC. All rights reserved.
//

import Foundation
import CoreLocation

public typealias BSNearestStationRequestCallback = ([BSStation]?, Error?) -> Void

extension BSManager {

    public func stationsNearest(_ coordinate: CLLocationCoordinate2D, limit: Int, _ callback: @escaping BSNearestStationRequestCallback) {
        BSRouter.nearbyStations(coordinate, limit).request(self.fetchNearestStationsCompletionHandler(callback))
    }

    internal func fetchNearestStationsCompletionHandler(_ callback: @escaping BSNearestStationRequestCallback) -> ((Data?, URLResponse?, Error?) -> Void) {
        return {(data, response, error) in
            if error != nil {
                callback(nil, error)
            } else if let failure = BSRouter.validateResponse(data, response: response) {
                callback(nil, failure)
            } else {
                let (stations, error) = self.handleNearestStationsSuccessResponse(data!)
                callback(stations, error)
            }
        }
    }

    internal func handleNearestStationsSuccessResponse(_ data: Data) -> ([BSStation]?, Error?) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let json = (json as? NSArray) as? [NSDictionary] {
                let retrievedStations = json.map {
                    BSStation(data: $0)
                }.filter { ($0?.active ?? false) || _includeInactiveStations }.map { $0! }

                return (retrievedStations, nil)
            }
        } catch {}
        return (nil, BSErrorType.InvalidResponse)
    }
}
