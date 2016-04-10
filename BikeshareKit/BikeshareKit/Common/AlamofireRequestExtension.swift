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

    var authorizedParameters: [String: AnyObject] = [
        "token": _token,
        "uuid": BSManager.sharedManager()._uuid,
        "version": (NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown",
        "build": (NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String) ?? ""
    ]

    if parameters != nil {
        for (key, value) in parameters! {
            authorizedParameters.updateValue(value, forKey: key)
        }
    }
    return Alamofire.request(method, URLString, parameters: authorizedParameters, encoding: encoding, headers: headers)
}

private var uuid: String?
private var _uuidKey = "uuid"
extension BSManager {

    private var _uuid: String {
        if uuid == nil {
            if let archived = NSUserDefaults.standardUserDefaults().stringForKey(_uuidKey) {
                uuid = archived
            } else {
                uuid = NSUUID().UUIDString
                NSUserDefaults.standardUserDefaults().setObject(uuid!, forKey: _uuidKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        return uuid!
    }

}
