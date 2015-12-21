//
//  NSDateExtension.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/19/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import Foundation

private var APIDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.timeZone = NSTimeZone(name: "UTC")
    return formatter
}()

extension NSDate {
    public static func fromAPIString(string: String?) -> NSDate? {
        return string != nil ? APIDateFormatter.dateFromString(string!) : nil
    }
}