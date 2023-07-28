//
//  PageController.swift
//  PageController Research
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class PageController: NSPageController {
    
    let pageViews = [
        NSStoryboard(name: "ExampleView", bundle: nil).instantiateInitialController() as! ExampleVC,
        NSStoryboard(name: "ExampleView", bundle: nil).instantiateInitialController() as! ExampleVC,
        NSStoryboard(name: "ExampleView", bundle: nil).instantiateInitialController() as! ExampleVC
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.arrangedObjects = pageViews
        self.transitionStyle = .horizontalStrip
        
        self.build()
    }
    
    func build() {
        
        self.view.wantsLayer = true
        self.view.layer!.backgroundColor = NSColor.orange.cgColor
        self.view.layer!.borderColor = NSColor.black.cgColor
        self.view.layer!.borderWidth = 3
        
    }
    
}

extension PageController: NSPageControllerDelegate {
    
    func pageController(_ pageController: NSPageController, didTransitionTo object: Any) {
        
    }
    
    func pageController(_ pageController: NSPageController, identifierFor object: Any) -> NSPageController.ObjectIdentifier {
        "\(pageViews.firstIndex { $0 == object as! ExampleVC }!)"
    }
    
    func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
        print(identifier)
        return pageViews[Int(identifier)!]
    }
    
}
