//
//  VerseViewController.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

class VerseViewController: NSViewController {
    
    var verseView: VerseView { self.view as! VerseView }

    static func newVC() -> Self {
        NSStoryboard(name: "VerseViewController", bundle: nil).instantiateInitialController() as! Self
    }
    
    override func viewDidLoad() {
        
    }
    
}
