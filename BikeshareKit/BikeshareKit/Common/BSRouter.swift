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
//     NSURLSession.sharedSession().dataTaskWithRequest(BSRouter.MyEndpointType(param).URLRequest) {(data, response, error) in
//         ...
//     }
//
//  Externally, call BSRouter.MyEndpointType(param).request(completion)

import Foundation

internal enum BSRouter {
    case Services
    case Stations(BSService)
    case ServiceImage(String)

    //note: if temporarily using localhost or other http:// service, add this to your application's Info.plist
    //<key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoads</key><true/></dict>
    private static let API_BASE: String = "https://api.stationtostationapp.com"
    private static let API_BASE_URL: String = "\(API_BASE)/v1/"
    private static let IMAGE_BASE_URL: String = "\(API_BASE)/images/"

    internal var URLRequest: NSMutableURLRequest {
        let (method, imagePath, path): (BSRouterMethod, Bool, String) = {
            switch self {
            case .Services:
                return (.GET, false, "services")
            case .Stations(let service):
                return (.GET, false, "services/\(service.id)/stations")
            case .ServiceImage(let imageName):
                return (.GET, true, imageName)
            }
        }()

        let URL = NSURL(string: imagePath ? BSRouter.IMAGE_BASE_URL : BSRouter.API_BASE_URL)!.URLByAppendingPathComponent(path)
        let URLWithParams = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true)!
        URLWithParams.queryItems = BSRouter.authorizedParameters
        let request = NSMutableURLRequest(URL: URLWithParams.URL!)

        if !imagePath {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = method.rawValue
        }
        return request
    }

    private static var authorizedParameters: [NSURLQueryItem] = [
        NSURLQueryItem(name: "token", value: _token),
        NSURLQueryItem(name: "uuid", value: BSManager.sharedManager()._uuid),
        NSURLQueryItem(name: "version", value: (NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"),
        NSURLQueryItem(name: "build", value: (NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String) ?? "")
    ]

}

extension BSRouter {

    internal func request(completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        (completionHandler != nil ?
            NSURLSession.sharedSession().dataTaskWithRequest(self.URLRequest, completionHandler: completionHandler!) :
            NSURLSession.sharedSession().dataTaskWithRequest(self.URLRequest)
        ).resume()
    }

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

enum BSRouterMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}