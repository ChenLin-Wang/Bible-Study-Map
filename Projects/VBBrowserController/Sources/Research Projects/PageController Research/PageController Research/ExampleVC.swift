//
//  ExampleVC.swift
//  PageController Research
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class ExampleVC: NSViewController {

    var exampleView: ExampleView { self.view as! ExampleView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exampleView.build()
        
    }
    
}
