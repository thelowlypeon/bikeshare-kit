//
//  BSManager.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/13/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import Alamofire

public class BSManager: NSObject {

    internal let baseURL: String = "http://api.stationtostationapp.com/v1/"

    public dynamic var servicesUpdatedAt: NSDate?
    public dynamic var services = Set<BSService>()
}