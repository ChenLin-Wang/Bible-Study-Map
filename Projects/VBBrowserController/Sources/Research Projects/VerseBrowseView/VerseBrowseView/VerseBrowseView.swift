//
//  VerseBrowseView.swift
//  VerseBrowseView
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class VerseBrowseView: NSView {
    
    var viewControllers: [NSViewController] = []

    func addAndDisplay(_ viewController: NSViewController) {
        viewControllers.append(viewController)
        
        addAndSetConstraints(view: viewController.view)
    }
    
    private func addAndSetConstraints(view: NSView) {
        
//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        view.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(view)
        
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
//        rightConstraint.priority = .defaultHigh
//        topConstraint.priority = .defaultHigh
//        leftConstraint.priority = .defaultHigh
//        bottomConstraint.priority = .defaultHigh
        
        self.addConstraints([rightConstraint, topConstraint, leftConstraint, bottomConstraint])
    }
    
    
    func build() {
        
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.white.cgColor
        
//        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        self.setContentHuggingPriority(.defaultLow, for: .vertical)
//        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
    }
    
}
