//
//  FixtureHelper.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/20/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import XCTest
@testable import BikeshareKit

extension XCTestCase {
    
    public func jsonFromFixture(_ filename: String) -> Any? {
        if let data = self.dataFromFixture(filename) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {}
        }
        return nil
    }

    public func dataFromFixture(_ filename: String) -> Data? {
        let bundle = Bundle(identifier: "com.outofsomething.BikeshareKitTests")
        if let fixturePath = bundle?.path(forResource: filename, ofType: nil) {
            return (try? Data(contentsOf: URL(fileURLWithPath: fixturePath)))
        }
        return nil
    }

    public func divvyFixture() -> BSService {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let stationsJson = jsonFromFixture("StationsResponse.json")!
        let _ = divvy.handleSuccessResponse(stationsJson)
        return divvy
    }


}
