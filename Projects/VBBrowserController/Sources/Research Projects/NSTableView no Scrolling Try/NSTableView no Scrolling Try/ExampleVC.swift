//
//  ExampleVC.swift
//  NSTableView no Scrolling Try
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

class ExampleVC: NSViewController {

    static func newVC() -> ExampleVC {
        NSStoryboard(name: "ExampleVC", bundle: nil).instantiateInitialController() as! Self
    }
    
    func drawStyle() -> ExampleVC {
        self.view.wantsLayer = true
        self.view.layer!.backgroundColor = NSColor.systemYellow.cgColor
        return self
    }
    
}
