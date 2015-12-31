//
//  BSAvailabilityChartItem.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/31/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

public class BSAvailabilityChartItem: NSObject {
    public var value: CGFloat
    public var color: UIColor

    public init(value: CGFloat, color: UIColor) {
        self.value = value
        self.color = color
        super.init()
    }
    
}