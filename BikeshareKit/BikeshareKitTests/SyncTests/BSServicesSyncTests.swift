//
//  BikeshareKitTests.swift
//  BikeshareKitTests
//
//  Created by Peter Compernolle on 12/13/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSServicesSyncTests: XCTestCase {
    var manager: BSManager!
    var mockJSON: NSArray!

    override func setUp() {
        super.setUp()

        manager = BSManager()

        // mock the resonse from API for services
        mockJSON = jsonFromFixture("ServicesResponse.json") as! NSArray
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testServicesSyncFetchesServices() {
        let expectedServicesCount = 5
        let error = manager.handleSuccessResponse(mockJSON)

        XCTAssertNil(error)
        XCTAssertEqual(self.manager.services.count, expectedServicesCount)
    }

    func testServicesSyncSetsFields() {
        manager.handleSuccessResponse(mockJSON)

        XCTAssertNotNil(self.manager.servicesUpdatedAt)
        for service in self.manager.services {
            XCTAssertNotEqual(service.id, -1)
            XCTAssertNotNil(service.url)
            XCTAssertNotNil(service.city)
            XCTAssertNotNil(service.lastUpdatedFromService)
        }
    }

    func testServicesSyncUpdatesExistingService() {
        let divvy = BSService(id: 1, data: ["name": "divvy", "city": "The Windy City"])
        manager.services = [divvy]

        manager.handleSuccessResponse(mockJSON)

        XCTAssertTrue(self.manager.services.contains(divvy))
        for service in self.manager.services {
            if service.id == 1 {
                XCTAssertEqual(service.city, "Chicago")
                break
            }
        }
    }

    func testServicesSyncRemovesOutdatedServices() {
        let outdatedService = BSService(id: 19, data: ["city": "Lamesville"])
        manager.services = [outdatedService]

        manager.handleSuccessResponse(mockJSON)

        XCTAssertFalse(self.manager.services.contains(outdatedService))
    }

    //depends on BSPreferencesTests
    func testServicesSyncUpdatesFavoriteService() {
        let favoriteService = BSService(id: 1, data: ["name": "out of date name"])
        manager.services = [favoriteService]
        manager.favoriteService = manager.services.first

        manager.handleSuccessResponse(mockJSON)

        XCTAssertNotNil(self.manager.favoriteService)
        XCTAssertEqual(self.manager.favoriteService?.name, "divvy")
    }
}
