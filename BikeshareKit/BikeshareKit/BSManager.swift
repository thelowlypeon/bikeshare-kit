//
//  BSManager.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/13/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

internal var _manager: BSManager!
internal var _token: String!
internal var _includeInactiveStations: Bool = false

public enum BikeshareKitConfigOption: String {
    case Token = "token"
    case IncludeInactiveStations = "includeInactiveStations"
}

open class BSManager: NSObject {

    open dynamic var servicesUpdatedAt: Date?
    open dynamic var services = Set<BSService>()
    open dynamic var favoriteService: BSService?

    open static func configure(_ config: [BikeshareKitConfigOption: Any]) {
        if let token = config[.Token] as? String {
            _token = token
        }
        if let includeInactiveStations = config[.IncludeInactiveStations] as? Bool {
            _includeInactiveStations = includeInactiveStations
        }
    }

    open static func sharedManager() -> BSManager {
        if _manager == nil {
            _manager = BSManager(token: _token)
        }
        return _manager
    }

    open func persist() {
        self.persistServices()
        self.persistFavoriteService()
    }

    open func restore() {
        self.restoreServices()
        self.restoreFavoriteService()
    }

    public init(token: String) {
        _token = token
    }

    deinit {
        self.persist()
    }
}
