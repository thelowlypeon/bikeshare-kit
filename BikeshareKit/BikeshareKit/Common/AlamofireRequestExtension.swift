//
//  AlamofireRequestExtension.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 1/2/16.
//  Copyright © 2016 Out of Something, LLC. All rights reserved.
//

import Foundation
import Alamofire


internal func request(
    method: Alamofire.Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil)
    -> Request
{

    var authorizedParameters: [String: AnyObject] = ["token": _token]
    if parameters != nil {
        for (key, value) in parameters! {
            authorizedParameters.updateValue(value, forKey: key)
        }
    }
    return Alamofire.request(method, URLString, parameters: authorizedParameters, encoding: encoding, headers: headers)
}
