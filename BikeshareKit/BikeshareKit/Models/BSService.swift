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
private let kBSServiceUpdatedFromService = "bikeshare_kit__service_last_updated_from_service"
private let kBSServiceUpdatedAt = "bikeshare_kit__service_updated_at"
private let kBSServiceStationsKey = "bikeshare_kit__service_stations"

public class BSService: NSObject {
    internal dynamic var id: Int

    public dynamic var name: String?
    public dynamic var city: String?
    public dynamic var url: NSURL?
    public dynamic var lastUpdatedFromService: NSDate?
    public dynamic var updatedAt = NSDate()

    public dynamic var stationsUpdatedAt: NSDate?
    public dynamic var stations = Set<BSStation>()

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
        aCoder.encodeObject(self.lastUpdatedFromService, forKey: kBSServiceUpdatedFromService)
        aCoder.encodeObject(self.updatedAt, forKey: kBSServiceUpdatedAt)

        aCoder.encodeObject(self.stations, forKey: kBSServiceStationsKey)
    }

    public required init?(coder aDecoder: NSCoder) {
        //required fields
        self.id = aDecoder.decodeObjectForKey(kBSServiceIDKey) as! Int

        //fields with defaults
        self.updatedAt = (aDecoder.decodeObjectForKey(kBSServiceUpdatedAt) as? NSDate) ?? NSDate()
        self.stations = (aDecoder.decodeObjectForKey(kBSServiceStationsKey) as? Set<BSStation>) ?? Set<BSStation>()

        //optional fields
        self.name = aDecoder.decodeObjectForKey(kBSServiceNameKey) as? String
        self.city = aDecoder.decodeObjectForKey(kBSServiceCityKey) as? String
        self.url = aDecoder.decodeObjectForKey(kBSServiceURLKey) as? NSURL
        self.lastUpdatedFromService = aDecoder.decodeObjectForKey(kBSServiceUpdatedFromService) as? NSDate

        super.init()
    }

    public func update(data: NSDictionary) {
        let _name = data["name"] as? String
        if _name != name {
            self.name = _name
        }
        let _city = data["city"] as? String
        if _city != city {
            self.city = _city
        }
        let _lastUpdatedFromService = NSDate.fromAPIString(data["last_fetch"] as? String)
        if _lastUpdatedFromService != lastUpdatedFromService {
            self.lastUpdatedFromService = _lastUpdatedFromService
        }
        let _url = NSURL(string: (data["url"] as? String) ?? "")
        if _url != url {
            self.url = _url
        }

        updatedAt = NSDate()
    }

    public func replace(withService rhs: BSService) {
        if self.name != rhs.name {
            self.name = rhs.name
        }
        if self.city != rhs.city {
            self.city = rhs.city
        }
        if self.lastUpdatedFromService != rhs.lastUpdatedFromService {
            self.lastUpdatedFromService = rhs.lastUpdatedFromService
        }
        if self.url != rhs.url {
            self.url = rhs.url
        }

        updatedAt = NSDate()
    }

    override public var description: String {
        return self.name ?? "loading..."
    }

    override public var hashValue: Int { return self.id }

    override public func isEqual(object: AnyObject?) -> Bool {
        return self.id == (object as? BSService)?.id
    }

}