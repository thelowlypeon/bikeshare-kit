//
//  BSFavoriteServiceTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/29/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSFavoriteServiceTests: XCTestCase {
    var manager: BSManager!
    
    override func setUp() {
        super.setUp()

        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.synchronize()
        manager = BSManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChangingFavoriteInstanceIsReflectedInManager() {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let expectedName = "new divvy name"
        manager.services = [divvy]
        manager.favoriteService = divvy

        manager.favoriteService!.name = expectedName

        XCTAssertEqual(manager.favoriteService?.name, expectedName)
    }

}
