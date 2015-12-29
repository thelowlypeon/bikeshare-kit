//
//  BSStation.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/22/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation
import CoreLocation

private let kBSStationIDKey = "bikeshare_kit__station_id"
private let kBSStationActiveKey = "bikeshare_kit__station_active"
private let kBSStationNameKey = "bikeshare_kit__station_name"
private let kBSStationTotalDocksKey = "bikeshare_kit__station_total_docks"
private let kBSStationLocationKey = "bikeshare_kit__station_location"
private let kBSStationAvailabilityKey = "bikeshare_kit__station_availability"
private let kBSStationUpdatedAtKey = "bikeshare_kit__station_updated_at"

public class BSStation: NSObject {
    internal dynamic var id: Int

    public dynamic var active: Bool = false
    public dynamic var name: String?
    public dynamic var totalDocks: Int = 0
    public dynamic var inactiveDocks: Int {
        get {
            return self.availability != nil ?
                totalDocks - (self.availability!.bikes + self.availability!.docks)
                : 0
        }
    }
    public dynamic var location: CLLocation?
    public dynamic var availability: BSAvailability?

    public dynamic var updatedAt = NSDate()

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
        aCoder.encodeObject(self.id, forKey: kBSStationIDKey)
        aCoder.encodeObject(self.active, forKey: kBSStationActiveKey)
        aCoder.encodeObject(self.name, forKey: kBSStationNameKey)
        aCoder.encodeObject(self.totalDocks, forKey: kBSStationTotalDocksKey)
        aCoder.encodeObject(self.location, forKey: kBSStationLocationKey)
        aCoder.encodeObject(self.availability, forKey: kBSStationAvailabilityKey)
        aCoder.encodeObject(self.updatedAt, forKey: kBSStationUpdatedAtKey)
    }

    public required init?(coder aDecoder: NSCoder) {
        //required fields
        self.id = aDecoder.decodeObjectForKey(kBSStationIDKey) as! Int

        //fields with defaults
        self.active = (aDecoder.decodeObjectForKey(kBSStationActiveKey) as? Bool) ?? false
        self.updatedAt = (aDecoder.decodeObjectForKey(kBSStationUpdatedAtKey) as? NSDate) ?? NSDate()
        self.totalDocks = aDecoder.decodeObjectForKey(kBSStationTotalDocksKey) as? Int ?? 0

        //optional fields
        self.name = aDecoder.decodeObjectForKey(kBSStationNameKey) as? String
        self.location = aDecoder.decodeObjectForKey(kBSStationLocationKey) as? CLLocation
        self.availability = aDecoder.decodeObjectForKey(kBSStationAvailabilityKey) as? BSAvailability

        super.init()
    }

    public func update(data: NSDictionary) {
        let _name = data["name"] as? String
        if _name != name {
            self.name = _name
        }
        let _active = (data["active"] as? Bool) ?? false
        if active != _active {
            self.active = _active
        }
        let _latitude = data["latitude"] as? Double
        let _longitude = data["longitude"] as? Double
        let loc: CLLocation? = _latitude != nil && _longitude != nil ? CLLocation(latitude: _latitude!, longitude: _longitude!) : nil
        if loc?.coordinate.latitude != self.location?.coordinate.latitude || loc?.coordinate.longitude != self.location?.coordinate.longitude {
            self.location = loc
        }
        let _totalDocks = (data["total_docks"] as? Int) ?? 0
        if totalDocks != _totalDocks {
            self.totalDocks = _totalDocks
        }

        if let availabilityData = data["availability"] as? NSDictionary {
            if let _availability = BSAvailability(data: availabilityData) {
                self.availability = _availability
            }
        }

        updatedAt = NSDate()
    }

    public func replace(withStation rhs: BSStation) {
        if self.active != rhs.active {
            self.active = rhs.active
        }
        if self.name != rhs.name {
            self.name = rhs.name
        }
        if self.totalDocks != rhs.totalDocks {
            self.totalDocks = rhs.totalDocks
        }
        if self.location != rhs.location {
            self.location = rhs.location
        }
        if self.availability != rhs.availability {
            self.availability = rhs.availability
        }

        updatedAt = NSDate()
    }

    override public var description: String {
        return self.name ?? "loading..."
    }

    override public var hashValue: Int { return self.id }

    override public func isEqual(object: AnyObject?) -> Bool {
        return self.id == (object as? BSStation)?.id
    }

}
