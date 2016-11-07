//
//  BSErrors.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 6/23/16.
//  Copyright © 2016 Out of Something, LLC. All rights reserved.
//

import Foundation

private let domain = "com.outofsomething.BikeshareKit"
open class BSErrorType {
    open static let EmptyResponse = NSError(domain: domain, code: 10001, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("errors.api.response.empty", comment: "The API returned an empty response or the response was not received")])
    open static let InvalidResponse = NSError(domain: domain, code: 10002, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("errors.api.response.invalid", comment: "The API returned an invalid response or the response was in an invalid format")])
    open static let Unauthorized = NSError(domain: domain, code: 10401, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("errors.api.unauthorized", comment: "The request to the API was rejected because it was not authorized")])
    open static let InvalidRequest = NSError(domain: domain, code: 10406, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("errors.api.request.invalid", comment: "The request to the API was rejected because it was malformed")])
    open static let Unknown = NSError(domain: domain, code: 10500, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("errors.api.unknown", comment: "The API returned an unknown error")])
}
