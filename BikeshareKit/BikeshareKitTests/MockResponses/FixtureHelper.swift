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
    
    public func jsonFromFixture(filename: String) -> AnyObject? {
        if let data = self.dataFromFixture(filename) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {}
        }
        return nil
    }

    public func dataFromFixture(filename: String) -> NSData? {
        let bundle = NSBundle(identifier: "com.outofsomething.BikeshareKitTests")
        if let fixturePath = bundle?.pathForResource(filename, ofType: nil) {
            return NSData(contentsOfFile: fixturePath)
        }
        return nil
    }

    public func divvyFixture() -> BSService {
        let divvy = BSService(id: 1, data: ["name": "divvy"])
        let stationsJson = jsonFromFixture("StationsResponse.json")!
        divvy.handleSuccessResponse(stationsJson)
        return divvy
    }


}