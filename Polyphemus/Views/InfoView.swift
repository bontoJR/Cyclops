//
//  InfoView.swift
//  Polyphemus
//
//  Created by Junior B. on 04/10/15.
//  Copyright © 2015 Bonto.ch. All rights reserved.
//

import Cocoa

class InfoView: NSView {

    var textField: NSTextField!
    
    override var allowsVibrancy: Bool { return true }
    override var opaque: Bool {return false}
    
    init() {
        super.init(frame: NSZeroRect)
        
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = NSColor(deviceWhite: 0.9, alpha: 0.7).CGColor
        // Add Vibrancy
       
        let background = NSVisualEffectView(frame: NSZeroRect)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.blendingMode = .BehindWindow
        background.state = .Active
        background.material = .Light
        
        // Init Text
        textField = NSTextField(frame: NSZeroRect)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.alignment = .Center
        textField.font = NSFont.systemFontOfSize(32.0)
        textField.bezeled = false
        textField.editable = false
        textField.drawsBackground = false
        textField.selectable = false
        
        self.addSubview(textField)
        
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[textField]-20-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["textField": self.textField])
        
        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[textField]-20-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["textField": self.textField])
        
        self.addConstraints(vertical)
        self.addConstraints(horizontal)
    }

    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
}
