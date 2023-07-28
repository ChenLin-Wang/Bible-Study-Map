//
//  VerseBrowseDocumentView.swift
//  VerseBrowseView
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class VerseBrowseDocumentView: NSView {

    func build() {
        
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.systemPurple.cgColor
        
//        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        self.setContentHuggingPriority(.defaultLow, for: .vertical)
//        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
    }
    
}
