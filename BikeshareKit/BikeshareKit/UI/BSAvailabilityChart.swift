//
//  BSAvailabilityChart.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/31/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import UIKit

public class BSAvailabilityChart: UIView {

    //public vars

    public var items: [BSAvailabilityChartItem]!
    public var strokeWidth: CGFloat = 0.6
    public var fill = UIColor.whiteColor()
    public var brandColor: UIColor?

    //default to divvy branded colors
    public var labelColors: (UIColor, UIColor, UIColor) {
        get {
            var r = CGFloat(0.2), g = CGFloat(0.7), b = CGFloat(0.92), alpha = CGFloat(1)
            brandColor?.getRed(&r, green: &g, blue: &b, alpha: &alpha)

            let bikesColor = UIColor(red: r, green: g, blue: b, alpha: 1)
            let docksColor = UIColor(red: max(r - 0.3, 0), green: max(g - 0.3, 0), blue: max(b - 0.3, 0), alpha: 1)
            let inactiveColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)

            return (bikesColor, docksColor, inactiveColor)
        }
    }

    public lazy var inactiveLabelColors: (UIColor, UIColor, UIColor) = {
        let bikesColor = UIColor(white: 0.8, alpha: 1)
        let docksColor = UIColor(white: 0.5, alpha: 1)
        let inactiveColor = UIColor(white: 0.7, alpha: 1)

        return (bikesColor, docksColor, inactiveColor)
    }()

    //private vars

    private var percentages: [CGFloat]!
    private var innerRadius: CGFloat { return (frame.width / 2.0) - (outerRadius * strokeWidth) }
    private var outerRadius: CGFloat { return frame.width / 2.0 }


    private var total: CGFloat {
        get { return self.items.map{$0.value}.reduce(0, combine: {$0 + $1}) }
    }

    //initters

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public convenience init(frame: CGRect, inactiveStation: BSStation) {
        self.init(frame: frame)
        self.items = [BSAvailabilityChartItem(value: 1, color: UIColor.grayColor())]
    }

    public convenience init(frame: CGRect, station: BSStation, brandColor color: UIColor) {
        if !station.active || station.availability == nil {
            self.init(frame: frame, inactiveStation: station)
        } else {
            self.init(frame: frame)
            self.brandColor = color

            let (bikesColor, docksColor, inactiveColor) = station.availability!.effectiveSince < 300 ?
                self.labelColors :
                self.inactiveLabelColors

            let bikes = BSAvailabilityChartItem(value: CGFloat(station.availability!.bikes), color: bikesColor)
            let docks = BSAvailabilityChartItem(value: CGFloat(station.availability!.docks), color: docksColor)
            let inactive = BSAvailabilityChartItem(value: CGFloat(station.inactiveDocks), color: inactiveColor)

            self.items = [bikes, docks, inactive]
        }
    }

    //public methods

    public func draw() {
        self.calculateArcLocationsFromItems()

        self.layer.cornerRadius = outerRadius
        self.backgroundColor = fill
        self.layer.masksToBounds = true

        for var index = 0; index < items.count; index++ {
            self.layer.addSublayer(buildCircleLayer(forIndex: index))
        }
    }

    //private methods

    private func calculateArcLocationsFromItems() {
        percentages = self.items.map{$0.value / self.total}
    }

    private func rangeForItem(atIndex index: Int) -> (CGFloat, CGFloat) {
        if index == 0 {
            return (0, percentages[index])
        }
        let (_, previousEnd) = rangeForItem(atIndex: index - 1)
        return (previousEnd, previousEnd + percentages[index])
    }


    private func buildCircleLayer(forIndex index: Int) -> CAShapeLayer {
        let item = items[index]
        let (start, end) = rangeForItem(atIndex: index)
        let center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))

        let circle = CAShapeLayer()
        let path = UIBezierPath(arcCenter: center, radius: innerRadius + (outerRadius - innerRadius) / 2, startAngle: CGFloat(-(M_PI_2 * 3.0)), endAngle: CGFloat(M_PI_2), clockwise: true)

        circle.fillColor   = UIColor.clearColor().CGColor
        circle.strokeColor = item.color.CGColor
        circle.strokeStart = start
        circle.strokeEnd   = end
        circle.lineWidth   = outerRadius - innerRadius
        circle.path        = path.CGPath
        
        return circle
    }
}