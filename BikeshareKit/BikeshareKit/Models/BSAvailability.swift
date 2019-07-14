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

open class BSAvailability: NSObject {
    public let bikes: Int
    public let docks: Int
    public let effectiveDate: Date
    open var effectiveSince: TimeInterval {
        return Date().timeIntervalSince(effectiveDate)
    }

    public init(bikes: Int, docks: Int, effectiveDate: Date) {
        self.bikes = bikes
        self.docks = docks
        self.effectiveDate = effectiveDate
        super.init()
    }

    public convenience init?(data: NSDictionary) {
        let _bikes = data["bikes"] as? Int
        let _docks = data["docks"] as? Int
        let _effectiveDate = Date.fromAPIString(data["effective_date"] as? String)

        if _bikes != nil && _docks != nil && _effectiveDate != nil {
            self.init(bikes: _bikes!, docks: _docks!, effectiveDate: _effectiveDate!)
        } else {
            return nil
        }
    }

    // Archiving & Initializers
    @objc open func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(self.bikes, forKey: kBSAvailabilityBikesKey)
        aCoder.encode(self.docks, forKey: kBSAvailabilityDocksKey)
        aCoder.encode(self.effectiveDate, forKey: kBSAvailabilityEffectiveDateKey)
    }

    @objc public required init?(coder aDecoder: NSCoder) {
        //required fields
        self.bikes = aDecoder.decodeObject(forKey: kBSAvailabilityBikesKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSAvailabilityBikesKey)
        self.docks = aDecoder.decodeObject(forKey: kBSAvailabilityDocksKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSAvailabilityDocksKey)
        self.effectiveDate = aDecoder.decodeObject(forKey: kBSAvailabilityEffectiveDateKey) as! Date

        super.init()
    }

    override open var description: String {
        let minAgo = Int(floor(effectiveSince / 60))
        let effectiveSinceString = minAgo < 1 ? "just now" : "\(minAgo) minutes ago"
        return "\(bikes) bikes, \(docks) docks as of \(effectiveSinceString)"
    }

    override open func isEqual(_ object: Any?) -> Bool {
        if let other = object as? BSAvailability {
            return bikes == other.bikes && docks == other.docks && effectiveDate == other.effectiveDate
        }
        return false
    }
}
