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

        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.synchronize()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    fileprivate let STATION_KEY = "bikesharekit_tests__station_key"
    func testStationsAreArchivedWithServie() {
        let buckingham = BSStation(id: 1, data: ["name": "buckingham"])
        buckingham.availability = BSAvailability(bikes: 1, docks: 11, effectiveDate: Date())

        let data = NSKeyedArchiver.archivedData(withRootObject: buckingham)
        UserDefaults.standard.set(data, forKey: STATION_KEY)

        if let unarchivedStationData = UserDefaults.standard.object(forKey: STATION_KEY) as? Data {
            if let unarchivedStation = NSKeyedUnarchiver.unarchiveObject(with: unarchivedStationData) as? BSStation {
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
