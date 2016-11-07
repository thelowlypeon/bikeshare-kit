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

open class BSStation: NSObject {
    internal dynamic var id: Int

    open dynamic var active: Bool = false
    open dynamic var name: String?
    open dynamic var totalDocks: Int = 0
    open dynamic var inactiveDocks: Int {
        get {
            return self.availability != nil ?
                totalDocks - (self.availability!.bikes + self.availability!.docks)
                : 0
        }
    }
    open dynamic var location: CLLocation?
    open dynamic var availability: BSAvailability?

    open dynamic var updatedAt = Date()

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
    open func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: kBSStationIDKey)
        aCoder.encode(self.active, forKey: kBSStationActiveKey)
        aCoder.encode(self.name, forKey: kBSStationNameKey)
        aCoder.encode(self.totalDocks, forKey: kBSStationTotalDocksKey)
        aCoder.encode(self.location, forKey: kBSStationLocationKey)
        aCoder.encode(self.availability, forKey: kBSStationAvailabilityKey)
        aCoder.encode(self.updatedAt, forKey: kBSStationUpdatedAtKey)
    }

    public required init?(coder aDecoder: NSCoder) {
        //required fields
        self.id = aDecoder.decodeObject(forKey: kBSStationIDKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSStationIDKey)

        //fields with defaults
        self.active = aDecoder.decodeObject(forKey: kBSStationActiveKey) as? Bool ?? aDecoder.decodeBool(forKey: kBSStationActiveKey)
        self.updatedAt = aDecoder.decodeObject(forKey: kBSStationUpdatedAtKey) as? Date ?? Date()
        self.totalDocks = aDecoder.decodeObject(forKey: kBSStationTotalDocksKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSStationTotalDocksKey)

        //optional fields
        self.name = aDecoder.decodeObject(forKey: kBSStationNameKey) as? String
        self.location = aDecoder.decodeObject(forKey: kBSStationLocationKey) as? CLLocation
        self.availability = aDecoder.decodeObject(forKey: kBSStationAvailabilityKey) as? BSAvailability

        super.init()
    }

    open func update(_ data: NSDictionary) {
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

        updatedAt = Date()
    }

    open func replace(withStation rhs: BSStation) {
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

        updatedAt = Date()
    }

    override open var description: String {
        return self.name ?? NSLocalizedString("loading...", comment: "Displayed if the API doesn't return a name for this station")
    }

    override open var hashValue: Int { return self.id }

    override open func isEqual(_ object: Any?) -> Bool {
        return self.id == (object as? BSStation)?.id
    }

}
