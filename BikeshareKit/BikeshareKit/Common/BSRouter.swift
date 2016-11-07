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
    case services
    case stations(BSService)
    case serviceImage(String)

    //note: if temporarily using localhost or other http:// service, add this to your application's Info.plist
    //<key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoads</key><true/></dict>
    fileprivate static let API_BASE: String = "https://api.stationtostationapp.com"
    fileprivate static let API_BASE_URL: String = "\(API_BASE)/v1/"
    fileprivate static let IMAGE_BASE_URL: String = "\(API_BASE)/images/"

    internal var URLRequest: URLRequest {
        let (method, imagePath, path): (BSRouterMethod, Bool, String) = {
            switch self {
            case .services:
                return (.GET, false, "services")
            case .stations(let service):
                return (.GET, false, "services/\(service.id)/stations")
            case .serviceImage(let imageName):
                return (.GET, true, imageName)
            }
        }()

        let URL = Foundation.URL(string: imagePath ? BSRouter.IMAGE_BASE_URL : BSRouter.API_BASE_URL)!.appendingPathComponent(path)
        var URLWithParams = URLComponents(url: URL, resolvingAgainstBaseURL: true)!
        URLWithParams.queryItems = BSRouter.authorizedParameters
        let request = NSMutableURLRequest(url: URLWithParams.url!)
        request.setValue(Bundle.main.preferredLocalizations.first, forHTTPHeaderField: "Accept-Language")

        if !imagePath {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = method.rawValue
        }
        return request as URLRequest
    }

    internal static func validateResponse(_ data: Data?, response: URLResponse?) -> NSError? {
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if statusCode >= 200 && statusCode < 400 {
                return data == nil ? BSErrorType.EmptyResponse : nil
            } else {
                switch statusCode {
                case 401: return BSErrorType.Unauthorized
                case 406: return BSErrorType.InvalidRequest
                case 500: return BSErrorType.Unknown
                default: break
                }
            }
        }
        return BSErrorType.InvalidResponse
    }

    fileprivate static var authorizedParameters: [URLQueryItem] = [
        URLQueryItem(name: "token", value: _token),
        URLQueryItem(name: "uuid", value: BSManager.sharedManager()._uuid),
        URLQueryItem(name: "version", value: (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"),
        URLQueryItem(name: "build", value: (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "")
    ]

}

extension BSRouter {

    internal func request(_ completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        (completionHandler != nil ?
            URLSession.shared.dataTask(with: self.URLRequest, completionHandler: completionHandler!) :
            URLSession.shared.dataTask(with: self.URLRequest)
        ).resume()
    }

}

private var uuid: String?
private var _uuidKey = "uuid"
extension BSManager {

    fileprivate var _uuid: String {
        if uuid == nil {
            if let archived = UserDefaults.standard.string(forKey: _uuidKey) {
                uuid = archived
            } else {
                uuid = UUID().uuidString
                UserDefaults.standard.set(uuid!, forKey: _uuidKey)
                UserDefaults.standard.synchronize()
            }
        }
        return uuid!
    }

}

enum BSRouterMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}
