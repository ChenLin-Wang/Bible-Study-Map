//
//  VerseStackViewController.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

class VerseStackViewController: NSViewController {
    
    var stackView: VerseStackView { self.view as! VerseStackView }
    
    static func newVC() -> Self {
        NSStoryboard(name: "VerseStackViewController", bundle: nil).instantiateInitialController() as! Self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildGUI()
    }
    
    func buildGUI() {
        stackView.buildGUI()
    }
    
    func updateGUI(event: TableView.Event, paras: [TableView.Key: Any]) {
        stackView.updateGUI(event: event, paras: paras)
    }
    
    func checkAppendDirection(leadingSpace: CGFloat, trailingSpace: CGFloat) -> TableView.AppendDirection? {
        stackView.checkAppendDirection(leadingSpace: leadingSpace, trailingSpace: trailingSpace)
    }
    
}
