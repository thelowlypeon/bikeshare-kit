//
//  BSAvailabilitySyncTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/24/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
import Alamofire
@testable import BikeshareKit

class BSAvailabilitySyncTests: XCTestCase {
    var service: BSService!
    var stationsJson: AnyObject!
    var mockResponse: Response<AnyObject, NSError>!
    
    override func setUp() {
        super.setUp()

        service = BSService(id: 1, data: ["name": "divvy"])

        // mock the resonse from API for stations
        stationsJson = jsonFromFixture("StationsResponse.json")!
        let result = Result<AnyObject, NSError>.Success(stationsJson)
        mockResponse  = Response(request: nil, response: nil, data: nil, result: result)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testStationsSyncUpdatesAvailability() {
        let expectation = expectationWithDescription("Mock response arrived")

        let expectedEffectiveDate = NSDate.fromAPIString("2015-12-22T18:25:07.000Z")!
        let expiredAvailability = BSAvailability(bikes: 10, docks: 23, effectiveDate: expectedEffectiveDate.dateByAddingTimeInterval(-1000))
        let expectedAvailability = BSAvailability(bikes: 11, docks: 22, effectiveDate: expectedEffectiveDate)

        service.stations = [BSStation(id: 1, data: ["name": "Buckingham"])]
        let buckingham = service.stations.first!
        buckingham.availability = expiredAvailability

        service.syncStationsCompletionHandler({(error) in
            expectation.fulfill()
            XCTAssertNil(error)
        })(mockResponse)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertNotNil(buckingham.availability)
            XCTAssertEqual(buckingham.availability!.bikes, expectedAvailability.bikes)
            XCTAssertEqual(buckingham.availability!.docks, expectedAvailability.docks)
            XCTAssertEqual(buckingham.availability!.effectiveDate, expectedAvailability.effectiveDate)
        })
    }

    func testStationsSyncSetsAvailabilityWhenPreviouslyNone() {
        let expectation = expectationWithDescription("Mock response arrived")

        let expectedEffectiveDate = NSDate.fromAPIString("2015-12-22T18:25:07.000Z")!
        let expectedAvailability = BSAvailability(bikes: 11, docks: 22, effectiveDate: expectedEffectiveDate)

        service.stations = [BSStation(id: 1, data: ["name": "Buckingham"])]
        let buckingham = service.stations.first!

        service.syncStationsCompletionHandler({(error) in
            expectation.fulfill()
            XCTAssertNil(error)
        })(mockResponse)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertNotNil(buckingham.availability)
            XCTAssertEqual(buckingham.availability!.bikes, expectedAvailability.bikes)
            XCTAssertEqual(buckingham.availability!.docks, expectedAvailability.docks)
            XCTAssertEqual(buckingham.availability!.effectiveDate, expectedAvailability.effectiveDate)
        })
    }
}
