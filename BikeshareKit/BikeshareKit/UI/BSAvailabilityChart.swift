//
//  BSAvailabilityChart.swift
//  BikeshareKit
//
//  Created by Peter Compernolle on 12/31/15.
//  Copyright © 2015 Out of Something, LLC. All rights reserved.
//

import UIKit

open class BSAvailabilityChart: UIView {

    //public vars

    open var items: [BSAvailabilityChartItem]!
    open var strokeWidth: CGFloat = 0.6
    open var fill = UIColor.white
    open var brandColor: UIColor?

    //default to divvy branded colors
    open var labelColors: (UIColor, UIColor, UIColor) {
        get {
            var r = CGFloat(0.2), g = CGFloat(0.7), b = CGFloat(0.92), alpha = CGFloat(1)
            brandColor?.getRed(&r, green: &g, blue: &b, alpha: &alpha)

            let bikesColor = UIColor(red: r, green: g, blue: b, alpha: 1)
            let docksColor = UIColor(red: max(r - 0.3, 0), green: max(g - 0.3, 0), blue: max(b - 0.3, 0), alpha: 1)
            let inactiveColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)

            return (bikesColor, docksColor, inactiveColor)
        }
    }

    open lazy var inactiveLabelColors: (UIColor, UIColor, UIColor) = {
        let bikesColor = UIColor(white: 0.8, alpha: 1)
        let docksColor = UIColor(white: 0.5, alpha: 1)
        let inactiveColor = UIColor(white: 0.7, alpha: 1)

        return (bikesColor, docksColor, inactiveColor)
    }()

    //private vars

    fileprivate var percentages: [CGFloat]!
    fileprivate var innerRadius: CGFloat { return (frame.width / 2.0) - (outerRadius * strokeWidth) }
    fileprivate var outerRadius: CGFloat { return frame.width / 2.0 }


    fileprivate var total: CGFloat {
        get { return self.items.map{$0.value}.reduce(0, {$0 + $1}) }
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
        self.items = [BSAvailabilityChartItem(value: 1, color: UIColor.gray)]
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

    open func draw() {
        self.calculateArcLocationsFromItems()

        self.layer.cornerRadius = outerRadius
        self.backgroundColor = fill
        self.layer.masksToBounds = true

        for (index, _) in items.enumerated() {
            self.layer.addSublayer(buildCircleLayer(forIndex: index))
        }
    }

    //private methods

    fileprivate func calculateArcLocationsFromItems() {
        percentages = self.items.map{$0.value / self.total}
    }

    fileprivate func rangeForItem(atIndex index: Int) -> (CGFloat, CGFloat) {
        if index == 0 {
            return (0, percentages[index])
        }
        let (_, previousEnd) = rangeForItem(atIndex: index - 1)
        return (previousEnd, previousEnd + percentages[index])
    }


    fileprivate func buildCircleLayer(forIndex index: Int) -> CAShapeLayer {
        let item = items[index]
        let (start, end) = rangeForItem(atIndex: index)
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

        let circle = CAShapeLayer()
        let path = UIBezierPath(arcCenter: center, radius: innerRadius + (outerRadius - innerRadius) / 2, startAngle: CGFloat(-((Double.pi / 2) * 3.0)), endAngle: CGFloat(Double.pi / 2), clockwise: true)

        circle.fillColor   = UIColor.clear.cgColor
        circle.strokeColor = item.color.cgColor
        circle.strokeStart = start
        circle.strokeEnd   = end
        circle.lineWidth   = outerRadius - innerRadius
        circle.path        = path.cgPath
        
        return circle
    }
}
