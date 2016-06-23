//
//  BSAvailabilitySyncTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/24/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSAvailabilitySyncTests: XCTestCase {
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

    func testStationsSyncUpdatesAvailability() {
        let expectedEffectiveDate = NSDate.fromAPIString("2015-12-22T18:25:07.000Z")!
        let expiredAvailability = BSAvailability(bikes: 10, docks: 23, effectiveDate: expectedEffectiveDate.dateByAddingTimeInterval(-1000))
        let expectedAvailability = BSAvailability(bikes: 11, docks: 22, effectiveDate: expectedEffectiveDate)

        service.stations = [BSStation(id: 1, data: ["name": "Buckingham"])]
        let buckingham = service.stations.first!
        buckingham.availability = expiredAvailability

        service.handleSuccessResponse(stationsJson)

        XCTAssertNotNil(buckingham.availability)
        XCTAssertEqual(buckingham.availability!.bikes, expectedAvailability.bikes)
        XCTAssertEqual(buckingham.availability!.docks, expectedAvailability.docks)
        XCTAssertEqual(buckingham.availability!.effectiveDate, expectedAvailability.effectiveDate)
    }

    func testStationsSyncSetsAvailabilityWhenPreviouslyNone() {
        let expectedEffectiveDate = NSDate.fromAPIString("2015-12-22T18:25:07.000Z")!
        let expectedAvailability = BSAvailability(bikes: 11, docks: 22, effectiveDate: expectedEffectiveDate)

        service.stations = [BSStation(id: 1, data: ["name": "Buckingham"])]
        let buckingham = service.stations.first!

        service.handleSuccessResponse(stationsJson)

        XCTAssertNotNil(buckingham.availability)
        XCTAssertEqual(buckingham.availability!.bikes, expectedAvailability.bikes)
        XCTAssertEqual(buckingham.availability!.docks, expectedAvailability.docks)
        XCTAssertEqual(buckingham.availability!.effectiveDate, expectedAvailability.effectiveDate)
    }
}
