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

open class BSService: NSObject {
    internal let id: Int

    open var name: String?
    open var city: String?
    open var url: URL?
    open var color: UIColor = UIColor(red: 0.2, green: 0.7, blue: 0.92, alpha: 1) //default to divvy colors
    open var image: UIImage?

    open var numberOfDocks: Int = 0
    open var numberOfBikesAvailable: Int = 0
    open var numberOfDocksAvailable: Int = 0
    open var numberOfStations: Int = 0

    open var lastUpdatedFromService: Date?
    open var updatedAt = Date()

    open var stationsUpdatedAt: Date?
    open var stations = Set<BSStation>()

    public init(id: Int, data: NSDictionary) {
        self.id = id
        super.init()
        self.update(data)
    }

    public convenience init?(data: NSDictionary) {
        guard let id = data["id"] as? Int else { return nil }
        self.init(id: id, data: data)
    }

    // Archiving & Initializers
    @objc open func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: kBSServiceIDKey)
        aCoder.encode(self.name, forKey: kBSServiceNameKey)
        aCoder.encode(self.city, forKey: kBSServiceCityKey)
        aCoder.encode(self.color, forKey: kBSServiceColorKey)
        aCoder.encode(self.image, forKey: kBSServiceImageKey)
        aCoder.encode(self.numberOfDocks, forKey: kBSServiceNumberOfDocksKey)
        aCoder.encode(self.numberOfBikesAvailable, forKey: kBSServiceNumberOfBikesAvailableKey)
        aCoder.encode(self.numberOfDocksAvailable, forKey: kBSServiceNumberOfDocksAvailableKey)
        aCoder.encode(self.numberOfStations, forKey: kBSServiceNumberOfStationsKey)
        aCoder.encode(self.url, forKey: kBSServiceURLKey)
        aCoder.encode(self.lastUpdatedFromService, forKey: kBSServiceUpdatedFromService)
        aCoder.encode(self.updatedAt, forKey: kBSServiceUpdatedAt)

        aCoder.encode(self.stations, forKey: kBSServiceStationsKey)
    }

    @objc public required init?(coder aDecoder: NSCoder) {
        //required fields
        self.id = aDecoder.decodeObject(forKey: kBSServiceIDKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSServiceIDKey)

        //fields with defaults
        self.updatedAt = (aDecoder.decodeObject(forKey: kBSServiceUpdatedAt) as? Date) ?? Date()
        self.stations = (aDecoder.decodeObject(forKey: kBSServiceStationsKey) as? Set<BSStation>) ?? Set<BSStation>()
        self.numberOfDocks = aDecoder.decodeObject(forKey: kBSServiceNumberOfDocksKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSServiceNumberOfDocksKey)
        self.numberOfBikesAvailable = aDecoder.decodeObject(forKey: kBSServiceNumberOfBikesAvailableKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSServiceNumberOfBikesAvailableKey)
        self.numberOfDocksAvailable = aDecoder.decodeObject(forKey: kBSServiceNumberOfDocksAvailableKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSServiceNumberOfDocksAvailableKey)
        self.numberOfStations = aDecoder.decodeObject(forKey: kBSServiceNumberOfStationsKey) as? Int ?? aDecoder.decodeInteger(forKey: kBSServiceNumberOfStationsKey)
        if let _color = aDecoder.decodeObject(forKey: kBSServiceColorKey) as? UIColor {
            self.color = _color
        }

        //optional fields
        self.name = aDecoder.decodeObject(forKey: kBSServiceNameKey) as? String
        self.city = aDecoder.decodeObject(forKey: kBSServiceCityKey) as? String
        self.image = aDecoder.decodeObject(forKey: kBSServiceImageKey) as? UIImage
        self.url = aDecoder.decodeObject(forKey: kBSServiceURLKey) as? URL
        self.lastUpdatedFromService = aDecoder.decodeObject(forKey: kBSServiceUpdatedFromService) as? Date

        super.init()
    }

    open func update(_ data: NSDictionary) {
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
            //TODO make this async
            if let URL = BSRouter.serviceImage(_imageName).URLRequest.url {
                if let data = try? Data(contentsOf: URL) {
                    self.image = UIImage(data: data)
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
        let _lastUpdatedFromService = Date.fromAPIString(data["last_fetch"] as? String)
        if _lastUpdatedFromService != lastUpdatedFromService {
            self.lastUpdatedFromService = _lastUpdatedFromService
        }
        let _url = URL(string: (data["url"] as? String) ?? "")
        if _url != url {
            self.url = _url
        }

        updatedAt = Date()
    }

    open func replace(withService rhs: BSService) {
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

        updatedAt = Date()
    }

    override open var description: String {
        return self.name ?? NSLocalizedString("loading...", comment: "Displayed if no name is returned from the API")
    }

    override open var hash: Int { return self.id }

    override open func isEqual(_ object: Any?) -> Bool {
        return self.id == (object as? BSService)?.id
    }

}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat

        guard hexString.hasPrefix("#") else { return nil }

        let start = hexString.index(hexString.startIndex, offsetBy: 1)
        let hexColor = String(hexString[start...])

        guard hexColor.count == 8 else { return nil }

        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else { return nil }

        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000ff) / 255
                    
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
