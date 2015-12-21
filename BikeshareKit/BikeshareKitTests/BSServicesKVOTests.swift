//
//  BSServicesKVOTests.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/21/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
@testable import BikeshareKit

class BSServicesKVOTests: XCTestCase {
    var manager: BSManager!

    var observerCallback: ([String: AnyObject]? -> Void)?
    var currentlyObservingKeyPath: String? {
        didSet {
            if currentlyObservingKeyPath != nil {
                manager.addObserver(self, forKeyPath: currentlyObservingKeyPath!, options: .New, context: nil)
            }
        }
        willSet(new) {
            if new == nil && currentlyObservingKeyPath != nil {
                manager.removeObserver(self, forKeyPath: currentlyObservingKeyPath!)
            }
        }
    }

    override func setUp() {
        super.setUp()
        manager = BSManager()
    }

    override func tearDown() {
        currentlyObservingKeyPath = nil
        observerCallback = nil
        super.tearDown()
    }

    func testFavoriteServiceIsKVOCompliantForNew() {
        let expectation = expectationWithDescription("Received observer notification for new")
        currentlyObservingKeyPath = "favoriteService"

        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])

        observerCallback = {(change) in
            if let change = change?[NSKeyValueChangeNewKey] {
                expectation.fulfill()
                XCTAssertEqual((change as? BSService)?.id, divvy.id)
            } else {
                XCTFail("Received invalid change dictionary")
            }
        }

        manager.services = [divvy, citi]
        manager.favoriteService = divvy

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertTrue(true)
        })
    }

    func testFavoriteServiceIsKVOCompliantForChange() {
        let expectation = expectationWithDescription("Received observer notification for change")
        currentlyObservingKeyPath = "favoriteService"

        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])

        var numCallbacks = 0
        observerCallback = {(change) in
            if ++numCallbacks == 2 {
                expectation.fulfill()
            }
        }

        manager.services = [divvy, citi]
        manager.favoriteService = divvy
        manager.favoriteService = citi

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertTrue(true)
        })
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("observed \(change) at \(keyPath), loking for \(currentlyObservingKeyPath)")
        if keyPath == currentlyObservingKeyPath {
            observerCallback?(change)
        }
    }
    
}
