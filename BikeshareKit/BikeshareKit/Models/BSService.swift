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
private let kBSServiceColorKey = "bikeshare_kit__service_color"
private let kBSServiceImageKey = "bikeshare_kit__service_image"
private let kBSServiceNumberOfDocksKey = "bikeshare_kit__service_num_docks"
private let kBSServiceNumberOfBikesAvailableKey = "bikeshare_kit__service_num_bikes_available"
private let kBSServiceNumberOfDocksAvailableKey = "bikeshare_kit__service_num_docks_available"
private let kBSServiceNumberOfStationsKey = "bikeshare_kit__service_num_stations"
private let kBSServiceURLKey = "bikeshare_kit__service_url"
private let kBSServiceUpdatedFromService = "bikeshare_kit__service_last_updated_from_service"
private let kBSServiceUpdatedAt = "bikeshare_kit__service_updated_at"
private let kBSServiceStationsKey = "bikeshare_kit__service_stations"

public class BSService: NSObject {
    internal dynamic var id: Int

    public dynamic var name: String?
    public dynamic var city: String?
    public dynamic var url: NSURL?
    public dynamic var color: UIColor = UIColor(red: 0.2, green: 0.7, blue: 0.92, alpha: 1) //default to divvy colors
    public dynamic var image: UIImage?

    public dynamic var numberOfDocks: Int = 0
    public dynamic var numberOfBikesAvailable: Int = 0
    public dynamic var numberOfDocksAvailable: Int = 0
    public dynamic var numberOfStations: Int = 0

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
        aCoder.encodeObject(self.color, forKey: kBSServiceColorKey)
        aCoder.encodeObject(self.image, forKey: kBSServiceImageKey)
        aCoder.encodeObject(self.numberOfDocks, forKey: kBSServiceNumberOfDocksKey)
        aCoder.encodeObject(self.numberOfBikesAvailable, forKey: kBSServiceNumberOfBikesAvailableKey)
        aCoder.encodeObject(self.numberOfDocksAvailable, forKey: kBSServiceNumberOfDocksAvailableKey)
        aCoder.encodeObject(self.numberOfStations, forKey: kBSServiceNumberOfStationsKey)
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
        self.numberOfDocks = (aDecoder.decodeObjectForKey(kBSServiceNumberOfDocksKey) as? Int) ?? 0
        self.numberOfBikesAvailable = (aDecoder.decodeObjectForKey(kBSServiceNumberOfBikesAvailableKey) as? Int) ?? 0
        self.numberOfDocksAvailable = (aDecoder.decodeObjectForKey(kBSServiceNumberOfDocksAvailableKey) as? Int) ?? 0
        self.numberOfStations = (aDecoder.decodeObjectForKey(kBSServiceNumberOfStationsKey) as? Int) ?? 0
        if let _color = aDecoder.decodeObjectForKey(kBSServiceColorKey) as? UIColor {
            self.color = _color
        }

        //optional fields
        self.name = aDecoder.decodeObjectForKey(kBSServiceNameKey) as? String
        self.city = aDecoder.decodeObjectForKey(kBSServiceCityKey) as? String
        self.image = aDecoder.decodeObjectForKey(kBSServiceImageKey) as? UIImage
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
        if let _numberOfDocks = data["num_docks"] as? Int {
            if _numberOfDocks != numberOfDocks {
                self.numberOfDocks = _numberOfDocks
            }
        }
        if let _numberOfBikesAvailable = data["num_bikes_available"] as? Int {
            if _numberOfBikesAvailable != numberOfBikesAvailable {
                self.numberOfBikesAvailable = _numberOfBikesAvailable
            }
        }
        if let _numberOfDocksAvailable = data["num_docks_available"] as? Int {
            if _numberOfDocksAvailable != numberOfDocksAvailable {
                self.numberOfDocksAvailable = _numberOfDocksAvailable
            }
        }
        if let _numberOfStations = data["num_stations"] as? Int {
            if _numberOfStations != numberOfStations {
                self.numberOfStations = _numberOfStations
            }
        }
        if let _imageName = data["image"] as? String {
            request(.GET, "\(IMAGE_BASE_URL)\(_imageName)").response() {(_, _, data, error) in
                if error == nil && data != nil {
                    self.image = UIImage(data: data!)
                }
            }
        }
        if let _colorHex = data["brand_color_hex"] as? String {
            if let _color = UIColor(hexString: _colorHex) {
                if _color != self.color {
                    self.color = _color
                }
            }
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
        if self.numberOfDocks != rhs.numberOfDocks {
            self.numberOfDocks = rhs.numberOfDocks
        }
        if self.numberOfBikesAvailable != rhs.numberOfBikesAvailable {
            self.numberOfBikesAvailable = rhs.numberOfBikesAvailable
        }
        if self.numberOfDocksAvailable != rhs.numberOfDocksAvailable {
            self.numberOfDocksAvailable = rhs.numberOfDocksAvailable
        }
        if self.numberOfStations != rhs.numberOfStations {
            self.numberOfStations = rhs.numberOfStations
        }
        if self.lastUpdatedFromService != rhs.lastUpdatedFromService {
            self.lastUpdatedFromService = rhs.lastUpdatedFromService
        }
        if self.color != rhs.color {
            self.color = rhs.color
        }
        if self.image != rhs.image {
            self.image = rhs.image
        }
        if self.url != rhs.url {
            self.url = rhs.url
        }
        self.stations = rhs.stations

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

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat

        if hexString.hasPrefix("#") {
            let start = hexString.startIndex.advancedBy(1)
            let hexColor = hexString.substringFromIndex(start)

            if hexColor.characters.count == 8 {
                let scanner = NSScanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexLongLong(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        //TODO in swift 3, remove this and return nil. known bug https://bugs.swift.org/browse/SR-704
        self.init(red: 0, green: 0, blue: 1, alpha: 1)
    }
}
