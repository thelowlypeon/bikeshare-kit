//
//  BSErrorCodes.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 6/23/16.
//  Copyright © 2016 Out of Something, LLC. All rights reserved.
//

import Foundation

public enum BSErrorCodes: Int {
    case EmptyResponseFromAPI = 10001
    case InvalidResponseFromAPI = 10002
    case ServerError = 10003

    func error(localizedDescription: String) -> NSError {
        return NSError(domain: "com.outofsomething.BikeshareKit", code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
    }
}
