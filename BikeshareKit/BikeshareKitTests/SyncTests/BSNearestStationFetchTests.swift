//
//  BSNearestStationFetchTests.swift
//  BikeshareKitTests
//
//  Created by Peter Compernolle on 10/17/18.
//  Copyright © 2018 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSNearestStationFetchTests: XCTestCase {
    var manager: BSManager!
    var mockData: Data!

    override func setUp() {
        super.setUp()

        manager = BSManager()

        // mock the resonse from API for stations

        if let fixture = jsonFromFixture("StationsResponse.json") as? NSArray {
            do {
                mockData = try JSONSerialization.data(withJSONObject: fixture)
            } catch {}
        }
    }

    func testNearestStationReturnsServices() {
        let (stations, error) = manager!.handleNearestStationsSuccessResponse(mockData)

        XCTAssertNil(error)
        XCTAssertNotNil(stations)
        XCTAssert(stations!.count > 0)
        XCTAssertNotNil(stations![0].availability)
    }
}
