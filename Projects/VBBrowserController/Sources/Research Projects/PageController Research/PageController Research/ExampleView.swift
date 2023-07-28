//
//  ExampleView.swift
//  PageController Research
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class ExampleView: NSView {

    func build() {
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.white.cgColor
        self.layer!.borderColor = NSColor.black.cgColor
        self.layer!.borderWidth = 3
    }
    
}
