//
//  NSDateExtension.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/19/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

private var APIDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter
}()

extension Date {
    public static func fromAPIString(_ string: String?) -> Date? {
        return string != nil ? APIDateFormatter.date(from: string!) : nil
    }
}
