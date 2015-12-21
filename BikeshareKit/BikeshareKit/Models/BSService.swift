//
//  BSService.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/19/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

public class BSService: NSObject {
    internal dynamic var id: Int

    public dynamic var city: String?
    public dynamic var url: NSURL?
    public dynamic var lastFetch: NSDate? //will this be confusing?

    public init(id: Int, data: NSDictionary) {
        self.id = id
        super.init()
        self.update(data)
    }

    public convenience init?(data: NSDictionary) {
        print("initting services with data: \(data)")
        if let _id = data["id"] as? Int {
            print(" found id: \(_id)")
            self.init(id: _id, data: data)
        } else {
            print(" no id found")
            return nil
        }
    }

    public func update(data: NSDictionary) {
        self.city = data["city"] as? String
        self.lastFetch = NSDate.fromAPIString(data["last_fetch"] as? String)
        self.url = NSURL(string: (data["url"] as? String) ?? "")
    }

    override public var hashValue: Int { return self.id }

    override public func isEqual(object: AnyObject?) -> Bool {
        return self.id == (object as? BSService)?.id
    }

}