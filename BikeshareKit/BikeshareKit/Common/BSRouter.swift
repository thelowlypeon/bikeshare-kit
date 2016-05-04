//
//  BSRouter.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 1/2/16.
//  Copyright © 2016 Out of Something, LLC. All rights reserved.
//
//  Helper for easily defining API endpoints and, if necessary, setting global params, such as HTTP basic auth headers
//
//  Define endpoints by adding a `case` with any necessary params, then returining the corresponding method, path, and params in the URLRequest switch block.
//
//  case MyEndpointType(SomeClass)
//
//  public var URLRequest: NSMutableURLRequest {
//      let (method, path, parameters) = {
//          switch self {
//          ...
//          case MyEndpointType(param):
//              return (.GET, "path", ["param": param])
//
//  Then call the method as needed using:
//
//     Alamofire.request(ODCAPIRouter.MyEndpointType(param))
//              .responseJSON { ... }

import Foundation
import Alamofire

public enum BSRouter: URLRequestConvertible {
    case Services
    case Stations(BSService)
    case ServiceImage(String)

    public var URLRequest: NSMutableURLRequest {
        let (method, base, path): (Alamofire.Method, String, String) = {
            switch self {
            case .Services:
                return (.GET, API_BASE_URL, "services")
            case .Stations(let service):
                return (.GET, API_BASE_URL, "services/\(service.id)/stations")
            case .ServiceImage(let imageName):
                return (.GET, IMAGE_BASE_URL, imageName)
            }
        }()

        let URL = NSURL(string: base)
        let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        URLRequest.HTTPMethod = method.rawValue
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(URLRequest, parameters: BSRouter.authorizedParameters).0
    }

    static var authorizedParameters: [String: AnyObject] = [
        "token": _token,
        "uuid": BSManager.sharedManager()._uuid,
        "version": (NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown",
        "build": (NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String) ?? ""
    ]

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

