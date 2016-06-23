//
//  BSStationsSyncTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/22/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSStationsSyncTests: XCTestCase {
    var service: BSService!
    var stationsJson: AnyObject!

    override func setUp() {
        super.setUp()

        service = BSService(id: 1, data: ["name": "divvy"])

        // mock the resonse from API for stations
        stationsJson = jsonFromFixture("StationsResponse.json")!
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testStationsSyncFetchesAllStations() {
        let expectedStationsCount = 475
        BSManager.configure([.IncludeInactiveStations: true])

        let error = service.handleSuccessResponse(stationsJson)

        XCTAssertNil(error)
        XCTAssertEqual(self.service.stations.count, expectedStationsCount)
    }

    func testStationsSyncFetchesActiveStations() {
        let expectedStationsCount = 474
        BSManager.configure([.IncludeInactiveStations: false])

        service.handleSuccessResponse(stationsJson)

        XCTAssertEqual(self.service.stations.count, expectedStationsCount)
    }

    func testStationsSyncSetsFields() {
        service.handleSuccessResponse(stationsJson)

        let buckinghamData = (stationsJson as! [NSDictionary]).first
        let expectedBuckingham = BSStation(id: 1, data: buckinghamData!)

        XCTAssertNotNil(self.service.stationsUpdatedAt)
        for station in self.service.stations {
            XCTAssertNotEqual(station.id, -1)
            XCTAssertNotNil(station.name)
            XCTAssertNotNil(station.location)
            XCTAssertNotEqual(station.totalDocks, 0)
        }

        if let buckingham = (self.service.stations.filter{$0 == expectedBuckingham}).first {
            XCTAssertEqual(buckingham.name, expectedBuckingham.name)
            XCTAssertEqual(buckingham.active, expectedBuckingham.active)
            XCTAssertEqual(buckingham.location!.coordinate.latitude,
                expectedBuckingham.location!.coordinate.latitude)
            XCTAssertEqual(buckingham.location!.coordinate.longitude,
                expectedBuckingham.location!.coordinate.longitude)
            XCTAssertEqual(buckingham.totalDocks, expectedBuckingham.totalDocks)
        } else {
            XCTFail("Buckingham Fountain station not found")
        }
    }
}