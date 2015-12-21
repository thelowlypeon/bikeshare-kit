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

        self.manager = BSManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testFavoriteServiceIsIDSaved() {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])
        manager.services = [divvy, citi]
        manager.favoriteService = divvy

        let newManager = BSManager()
        XCTAssertNotNil(newManager.favoriteServiceID)
        XCTAssertEqual(newManager.favoriteServiceID, manager.favoriteServiceID)
    }

    func testFavoriteServiceIsNilIfUpdateRemovesIt() {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])
        manager.services = [divvy, citi]
        manager.favoriteService = divvy

        let newManager = BSManager()
        XCTAssertNil(newManager.favoriteService)
    }

    func testFavoriteServiceIsUpdated() {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])
        manager.services = [divvy, citi]
        manager.favoriteService = divvy

        let newName = "Supa cool divvy"
        divvy.name = newName
        let newManager = BSManager()
        newManager.services = [divvy, citi]

        XCTAssertEqual(newManager.favoriteService?.name, newName)
    }
}
