//
//  OverlayWindow.swift
//  Polyphemus
//
//  Created by Junior B. on 04/10/15.
//  Copyright © 2015 Bonto.ch. All rights reserved.
//

import Cocoa

func rectFromPoints(p1: CGPoint, p2: CGPoint) -> CGRect {
    return CGRectMake(min(p1.x, p2.x),
        min(p1.y, p2.y),
        fabs(p1.x - p2.x),
        fabs(p1.y - p2.y))
}

protocol OverlayWindowDelegate {
    func overlayWindowDidSelectRect(overlayWindow: OverlayWindow, rect:CGRect)
}

class OverlayWindow: NSWindow {
    
    override var acceptsFirstResponder: Bool { return true }
    
    let infoView: InfoView = InfoView()
    var infoViewToken: dispatch_once_t = 0
    
    var initialPoint: NSPoint = CGPointZero
    var shapeLayer: CAShapeLayer? = nil
    
    var overlayDelegate: OverlayWindowDelegate?
    
    // MARK: Mouse Events
    
    override func mouseDown(theEvent: NSEvent) {
        let point = theEvent.locationInWindow
        initialPoint = point
        shapeLayer = CAShapeLayer()
        setupShapeLayer(shapeLayer!)
        contentView?.wantsLayer = true
        contentView?.layer?.addSublayer(shapeLayer!)
        hideInfoView()
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let point = theEvent.locationInWindow
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, initialPoint.x, initialPoint.y)
        CGPathAddLineToPoint(path, nil, initialPoint.x, point.y)
        CGPathAddLineToPoint(path, nil, point.x, point.y)
        CGPathAddLineToPoint(path, nil, point.x, initialPoint.y)
        CGPathCloseSubpath(path)
        
        shapeLayer?.path = path
    }
    
    override func mouseUp(theEvent: NSEvent) {
        let point = theEvent.locationInWindow
        overlayDelegate?.overlayWindowDidSelectRect(self, rect: rectFromPoints(initialPoint, p2: point))
    }
    
    // MARK: Info View Management
    func showInfoView() {
        
        dispatch_once(&infoViewToken) { [unowned self] () -> Void in
            // Add nsview to notify the user
            self.infoView.wantsLayer = true
            self.infoView.layer?.masksToBounds = true
            self.infoView.layer?.cornerRadius = 5.0
            self.contentView?.addSubview(self.infoView)
            
            let xConsts = NSLayoutConstraint.constraintsWithVisualFormat("H:|-200-[infoView]-200-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["infoView": self.infoView])
            
            let yConst = NSLayoutConstraint(item: self.infoView,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: self.contentView,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0.0)
            
            self.contentView?.addConstraint(yConst)
            self.contentView?.addConstraints(xConsts)
        }
        
        backgroundColor = NSColor(calibratedWhite: 0.1, alpha: 0.5)
        infoView.hidden = false
    }
    
    func hideInfoView() {
        backgroundColor = NSColor.clearColor()
        infoView.hidden = true
    }
    
    // MARK: Draw View
    
    func setupShapeLayer(shapeLayer: CAShapeLayer) {
        let fillColor = NSColor(calibratedRed: 0, green: 178.0/255.0, blue: 1.0, alpha: 0.3).CGColor
        shapeLayer.fillColor = fillColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = NSColor(calibratedWhite: 1.0, alpha: 1.0).CGColor
        shapeLayer.lineDashPattern = [3,6]
        
        let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.fromValue = 0.0
        dashAnimation.toValue = 15.0
        dashAnimation.duration = 0.75
        dashAnimation.repeatCount = .infinity
        shapeLayer.addAnimation(dashAnimation, forKey: "linePhase")
    }
}
