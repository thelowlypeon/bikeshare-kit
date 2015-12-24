//
//  BSAvailability.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/24/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

private let kBSAvailabilityBikesKey = "bikeshare_kit__availability_bikes"
private let kBSAvailabilityDocksKey = "bikeshare_kit__availability_docks"
private let kBSAvailabilityEffectiveDateKey = "bikeshare_kit__availability_effective_date"

public class BSAvailability: NSObject {
    public let bikes: Int
    public let docks: Int
    public let effectiveDate: NSDate
    public var effectiveSince: NSTimeInterval {
        return NSDate().timeIntervalSinceDate(effectiveDate)
    }

    public init(bikes: Int, docks: Int, effectiveDate: NSDate) {
        self.bikes = bikes
        self.docks = docks
        self.effectiveDate = effectiveDate
        super.init()
    }

    public convenience init?(data: NSDictionary) {
        let _bikes = data["bikes"] as? Int
        let _docks = data["docks"] as? Int
        let _effectiveDate = NSDate.fromAPIString(data["effective_date"] as? String)

        if _bikes != nil && _docks != nil && _effectiveDate != nil {
            self.init(bikes: _bikes!, docks: _docks!, effectiveDate: _effectiveDate!)
        } else {
            return nil
        }
    }

    // Archiving & Initializers
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.bikes, forKey: kBSAvailabilityBikesKey)
        aCoder.encodeObject(self.docks, forKey: kBSAvailabilityDocksKey)
        aCoder.encodeObject(self.effectiveDate, forKey: kBSAvailabilityEffectiveDateKey)
    }

    public required init?(coder aDecoder: NSCoder) {
        //required fields
        self.bikes = aDecoder.decodeObjectForKey(kBSAvailabilityBikesKey) as! Int
        self.docks = aDecoder.decodeObjectForKey(kBSAvailabilityDocksKey) as! Int
        self.effectiveDate = aDecoder.decodeObjectForKey(kBSAvailabilityEffectiveDateKey) as! NSDate

        super.init()
    }

    override public var description: String {
        let minAgo = Int(floor(effectiveSince / 60))
        let effectiveSinceString = minAgo < 1 ? "just now" : "\(minAgo) minutes ago"
        return "\(bikes) bikes, \(docks) docks as of \(effectiveSinceString)"
    }

    override public func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? BSAvailability {
            return bikes == other.bikes && docks == other.docks && effectiveDate == other.effectiveDate
        }
        return false
    }
}