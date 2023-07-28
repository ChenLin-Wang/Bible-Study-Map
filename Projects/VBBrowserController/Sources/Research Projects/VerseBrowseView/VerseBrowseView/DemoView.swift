//
//  DemoView.swift
//  VerseBrowseView
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class DemoView: NSView {
    
    private var resizeRatio: CGFloat = 1.2
    private var isFirstResize = true
    
    lazy private var timer = Timer(
        timeInterval: 1,
        target: self,
        selector: #selector(resize(sender:)),
        userInfo: nil,
        repeats: true)

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func startResize() {
        if isFirstResize {
            RunLoop.current.add(timer, forMode: .default)
            isFirstResize = false
        }
        timer.fireDate = .now
    }
    
    func stopResize() {
        timer.fireDate = Date.distantFuture
    }
    
    @objc
    private func resize(sender: Any?) {
        
    }
    
}
