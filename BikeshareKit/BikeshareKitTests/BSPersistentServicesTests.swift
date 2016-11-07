//
//  BSPreferencesTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/21/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSPersistentServicesTests: XCTestCase {
    var manager: BSManager!
    
    override func setUp() {
        super.setUp()

        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.synchronize()

        self.manager = BSManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testFavoriteServiceIsSaved() {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])
        manager.services = [divvy, citi]
        manager.favoriteService = divvy
        manager.persist()

        let newManager = BSManager(restore: true)
        XCTAssertNotNil(newManager.favoriteService)
        XCTAssertEqual(newManager.favoriteService, manager.favoriteService)
    }

    func testFavoriteServiceIsNilIfUpdateRemovesIt() {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])
        manager.services = [divvy, citi]
        manager.favoriteService = divvy

        manager.services = [citi]
        manager.refreshFavoriteService()

        XCTAssertNil(manager.favoriteService)
    }

    func testFavoriteServiceIsRemoved() {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])
        manager.services = [divvy, citi]
        manager.favoriteService = divvy
        manager.persist()

        let newManager = BSManager(restore: true)
        XCTAssertNotNil(newManager.favoriteService)
        newManager.favoriteService = nil
        newManager.persist()
        XCTAssertNil(newManager.favoriteService)
        let newestManager = BSManager()
        XCTAssertNil(newestManager.favoriteService)
    }

    func testStationsAreArchivedWithService() {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let buckingham = BSStation(id: 1, data: ["name": "buckingham"])
        buckingham.availability = BSAvailability(bikes: 1, docks: 11, effectiveDate: Date())
        divvy.stations = [buckingham]
        manager.services = [divvy]
        manager.favoriteService = divvy
        manager.persist()

        let newManager = BSManager(restore: true)
        let favoriteService = newManager.favoriteService
        XCTAssertNotNil(favoriteService)
        XCTAssertEqual(favoriteService?.stations.count, 1)
        let station = favoriteService?.stations.first
        XCTAssertNotNil(station)
        XCTAssertEqual(station?.name, buckingham.name)
        let availability = station?.availability
        XCTAssertNotNil(availability)
        XCTAssertEqual(availability?.bikes, 1)
        XCTAssertEqual(availability?.docks, 11)
    }
}
