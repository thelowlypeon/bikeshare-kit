//
//  BSPreferencesTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/21/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSPreferencesTests: XCTestCase {
    var manager: BSManager!
    
    override func setUp() {
        super.setUp()

        NSUserDefaults.resetStandardUserDefaults()
        NSUserDefaults.standardUserDefaults().synchronize()

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

        let newManager = BSManager()
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

        let newManager = BSManager()
        XCTAssertNotNil(newManager.favoriteService)
        newManager.favoriteService = nil
        XCTAssertNil(newManager.favoriteService)
        NSUserDefaults.standardUserDefaults().synchronize()
        let newestManager = BSManager()
        XCTAssertNil(newestManager.favoriteService)
    }
}
