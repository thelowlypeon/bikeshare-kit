//
//  BSStationsSyncTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/22/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
import Alamofire
@testable import BikeshareKit

class BSStationsSyncTests: XCTestCase {
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

    func testStationsSyncFetchesStations() {
        let expectedStationsCount = 475

        let expectation = expectationWithDescription("Mock response arrived")
        service.syncStationsCompletionHandler({(error) in
            expectation.fulfill()
            XCTAssertNil(error)
        })(mockResponse)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertEqual(self.service.stations.count, expectedStationsCount)
        })
    }

    func testStationsSyncSetsFields() {
        let expectation = expectationWithDescription("Mock response arrived")
        service.syncStationsCompletionHandler({(error) in
            expectation.fulfill()
        })(mockResponse)

        let buckinghamData = (stationsJson as! [NSDictionary]).first
        let expectedBuckingham = BSStation(id: 1, data: buckinghamData!)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
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
        })
    }
}
