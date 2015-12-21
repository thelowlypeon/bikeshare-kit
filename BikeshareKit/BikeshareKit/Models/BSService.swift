//
//  BSService.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/19/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

private let kBSServiceIDKey = "bikeshare_kit__service_id"
private let kBSServiceNameKey = "bikeshare_kit__service_name"
private let kBSServiceCityKey = "bikeshare_kit__service_city"
private let kBSServiceURLKey = "bikeshare_kit__service_url"
private let kBSServiceLastFetchKey = "bikeshare_kit__service_last_fetch"

public class BSService: NSObject {
    internal dynamic var id: Int

    public dynamic var name: String?
    public dynamic var city: String?
    public dynamic var url: NSURL?
    public dynamic var lastFetch: NSDate? //will this be confusing?

    public init(id: Int, data: NSDictionary) {
        self.id = id
        super.init()
        self.update(data)
    }

    public convenience init?(data: NSDictionary) {
        if let _id = data["id"] as? Int {
            self.init(id: _id, data: data)
        } else {
            return nil
        }
    }

    // Archiving & Initializers
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: kBSServiceIDKey)
        aCoder.encodeObject(self.name, forKey: kBSServiceNameKey)
        aCoder.encodeObject(self.city, forKey: kBSServiceCityKey)
        aCoder.encodeObject(self.url, forKey: kBSServiceURLKey)
        aCoder.encodeObject(self.lastFetch, forKey: kBSServiceLastFetchKey)
    }

    public required init?(coder aDecoder: NSCoder) {
        //required fields
        self.id = aDecoder.decodeObjectForKey(kBSServiceIDKey) as! Int

        //optional fields
        self.name = aDecoder.decodeObjectForKey(kBSServiceNameKey) as? String
        self.city = aDecoder.decodeObjectForKey(kBSServiceCityKey) as? String
        self.url = aDecoder.decodeObjectForKey(kBSServiceURLKey) as? NSURL
        self.lastFetch = aDecoder.decodeObjectForKey(kBSServiceLastFetchKey) as? NSDate

        super.init()
    }

    public func update(data: NSDictionary) {
        self.name = data["name"] as? String
        self.city = data["city"] as? String
        self.lastFetch = NSDate.fromAPIString(data["last_fetch"] as? String)
        self.url = NSURL(string: (data["url"] as? String) ?? "")
    }

    override public var hashValue: Int { return self.id }

    override public func isEqual(object: AnyObject?) -> Bool {
        return self.id == (object as? BSService)?.id
    }

}