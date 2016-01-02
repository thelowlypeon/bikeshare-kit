//
//  TestHelper.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 1/2/16.
//  Copyright © 2016 Out of Something, LLC. All rights reserved.
//

import Foundation
@testable import BikeshareKit

extension BSManager {
    internal convenience override init() {
        self.init(token: "tests")
    }

    internal convenience init(restore: Bool) {
        self.init()
        if restore {
            self.restore()
        }
    }
}