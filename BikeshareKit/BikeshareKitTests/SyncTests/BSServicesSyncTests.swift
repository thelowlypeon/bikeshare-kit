//
//  BikeshareKitTests.swift
//  BikeshareKitTests
//
//  Created by Peter Compernolle on 12/13/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import XCTest
import Alamofire
@testable import BikeshareKit

class BSServicesSyncTests: XCTestCase {
    var manager: BSManager!
    var mockResponse: Response<AnyObject, NSError>!
    
    override func setUp() {
        super.setUp()

        manager = BSManager()

        // mock the resonse from API for services
        let json = jsonFromFixture("ServicesResponse.json")!
        let result = Result<AnyObject, NSError>.Success(json)
        mockResponse  = Response(request: nil, response: nil, data: nil, result: result)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testServicesSyncFetchesServices() {
        let expectedServicesCount = 5

        let expectation = expectationWithDescription("Mock response arrived")
        manager.syncServicesCompletionHandler({(error) in
            expectation.fulfill()
            XCTAssertNil(error)
        })(mockResponse)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertEqual(self.manager.services.count, expectedServicesCount)
        })
    }

    func testServicesSyncSetsFields() {
        let expectation = expectationWithDescription("Mock response arrived")
        manager.syncServicesCompletionHandler({(error) in
            expectation.fulfill()
        })(mockResponse)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertNotNil(self.manager.servicesUpdatedAt)
            for service in self.manager.services {
                XCTAssertNotEqual(service.id, -1)
                XCTAssertNotNil(service.url)
                XCTAssertNotNil(service.city)
                XCTAssertNotNil(service.lastUpdatedFromService)
            }
        })
    }

    func testServicesSyncUpdatesExistingService() {
        let divvy = BSService(id: 1, data: ["name": "divvy", "city": "The Windy City"])
        manager.services = [divvy]

        let expectation = expectationWithDescription("Mock response arrived")
        manager.syncServicesCompletionHandler({(error) in
            expectation.fulfill()
        })(mockResponse)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertTrue(self.manager.services.contains(divvy))
            for service in self.manager.services {
                if service.id == 1 {
                    XCTAssertEqual(service.city, "Chicago")
                    break
                }
            }
        })
    }

    func testServicesSyncRemovesOutdatedServices() {
        let outdatedService = BSService(id: 19, data: ["city": "Lamesville"])
        manager.services = [outdatedService]

        let expectation = expectationWithDescription("Mock response arrived")
        manager.syncServicesCompletionHandler({(error) in
            expectation.fulfill()
        })(mockResponse)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertFalse(self.manager.services.contains(outdatedService))
        })
    }

    //depends on BSPreferencesTests
    func testServicesSyncUpdatesFavoriteService() {
        let favoriteService = BSService(id: 1, data: ["name": "out of date name"])
        manager.services = [favoriteService]
        manager.favoriteService = manager.services.first

        let expectation = expectationWithDescription("Mock response arrived")
        manager.syncServicesCompletionHandler({(error) in
            expectation.fulfill()
        })(mockResponse)

        waitForExpectationsWithTimeout(10, handler: { _ -> Void in
            XCTAssertNotNil(self.manager.favoriteService)
            XCTAssertEqual(self.manager.favoriteService?.name, "divvy")
        })
    }
}
