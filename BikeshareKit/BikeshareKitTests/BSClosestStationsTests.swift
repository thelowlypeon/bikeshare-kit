//
//  BSClosestStationsTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 2/15/16.
//  Copyright © 2016 Out of Something, LLC. All rights reserved.
//

import XCTest
import CoreLocation
@testable import BikeshareKit

class BSClosestStationsTests: XCTestCase {
    var service: BSService!
    var belmontAndLSD: CLLocation!

    override func setUp() {
        super.setUp()

        service = divvyFixture()
        belmontAndLSD = CLLocation(latitude: 41.9408, longitude: -87.6392)
    }

    func testClosestStationIsClosest() {
        let expectedStationId = 312
        let station = service.closestStation(toLocation: belmontAndLSD)
        XCTAssertNotNil(station?.id)
        XCTAssertEqual(station?.id, expectedStationId)
    }

    func testClosestStationsReturnsArrayOfSizeLimit() {
        let limit = 10
        let stations = service.closestStations(toLocation: belmontAndLSD, limit: limit)
        XCTAssertEqual(stations.count, limit)
    }

    func testClosestStationsReturnsArrayOfMaximumSize() {
        let limit = service.stations.count + 1
        let stations = service.closestStations(toLocation: belmontAndLSD, limit: limit)
        XCTAssertEqual(stations.count, service.stations.count)
    }

    func testClostestStationsAreOrdered() {
        var previousDistance: CLLocationDistance = -1
        let stations = service.closestStations(toLocation: belmontAndLSD, limit: service.stations.count)
        for station in stations {
            if let stationLocation = station.location {
                let distance = belmontAndLSD.distanceFromLocation(stationLocation)
                XCTAssert(previousDistance <= distance)
                previousDistance = distance
            }
        }
    }

    func testStationsWithNilLocationAreAtEnd() {
        let stationWithEmptyLocation = service.stations.first!
        stationWithEmptyLocation.location = nil

        let stations = service.closestStations(toLocation: belmontAndLSD, limit: service.stations.count)
        XCTAssertEqual(stations.last!.id, stationWithEmptyLocation.id)
    }
}
