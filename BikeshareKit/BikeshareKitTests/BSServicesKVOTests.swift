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
    var currentlyObservingKeyPath: String?

    override func setUp() {
        super.setUp()
        manager = BSManager()
        manager.favoriteService = nil
    }

    override func tearDown() {
        if currentlyObservingKeyPath != nil {
            //manager.removeObserver(self, forKeyPath: currentlyObservingKeyPath!)
            currentlyObservingKeyPath = nil
        }
        observerCallback = nil
        super.tearDown()
    }

    func observeKeyPath(keyPath: String) {
        currentlyObservingKeyPath = keyPath
        manager.addObserver(self, forKeyPath: currentlyObservingKeyPath!, options: .New, context: nil)
    }

    func testFavoriteServiceIsKVOCompliantForNew() {
        let expectation = expectationWithDescription("Received observer notification for new")
        observeKeyPath("favoriteService")

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
        observeKeyPath("favoriteService")

        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])

        var numCallbacks = 0
        observerCallback = {(change) in
            numCallbacks += 1
            if numCallbacks == 2 {
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


    func testFavoriteServiceDoesntTriggerChangeForNestedChange() {
        let expectation = expectationWithDescription("Received observer notification for change")
        observeKeyPath("favoriteService")

        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let updatedDivvy = BSService(id: 1, data: ["name": "new divvy"])
        let citi = BSService(id: 2, data: ["name": "citibikenyc"])

        var notificationCount = 0
        observerCallback = {(change) in
            notificationCount += 1
            let service = change?[NSKeyValueChangeNewKey] as? BSService
            switch notificationCount {
            case 1:
                XCTAssertEqual(service?.name, "divvy")
                break
            case 2:
                XCTAssertEqual(service?.name, "citibikenyc")
                expectation.fulfill()
                break
            default:
                XCTFail()
            }
        }

        manager.services = [divvy, citi]
        manager.favoriteService = divvy //second notification
        let index = manager.services.indexOf(divvy)!
        manager.services[index].replace(withService: updatedDivvy)
        manager.favoriteService = citi //fulfill

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertEqual(citi, self.manager.favoriteService)
        })
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //print("observed \(change) at \(keyPath), loking for \(currentlyObservingKeyPath)")
        if keyPath == currentlyObservingKeyPath {
            observerCallback?(change)
        }
    }
    
}
