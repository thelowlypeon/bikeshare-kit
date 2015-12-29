//
//  BSPersistentStationsTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/29/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSPersistentStationsTests: XCTestCase {

    override func setUp() {
        super.setUp()

        NSUserDefaults.resetStandardUserDefaults()
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    private let STATION_KEY = "bikesharekit_tests__station_key"
    func testStationsAreArchivedWithServie() {
        let buckingham = BSStation(id: 1, data: ["name": "buckingham"])
        buckingham.availability = BSAvailability(bikes: 1, docks: 11, effectiveDate: NSDate())

        let data = NSKeyedArchiver.archivedDataWithRootObject(buckingham)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: STATION_KEY)

        if let unarchivedStationData = NSUserDefaults.standardUserDefaults().objectForKey(STATION_KEY) as? NSData {
            if let unarchivedStation = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedStationData) as? BSStation {
                XCTAssertEqual(unarchivedStation.name, buckingham.name)
                XCTAssertNotNil(unarchivedStation.availability)
                XCTAssertEqual(unarchivedStation.availability?.bikes, 1)
                XCTAssertEqual(unarchivedStation.availability?.docks, 11)
            } else {
                XCTFail("failed to cast unarchived data as BSStation")
            }
        } else {
            XCTFail("failed to unarchive station data at \(STATION_KEY)")
        }
    }
}