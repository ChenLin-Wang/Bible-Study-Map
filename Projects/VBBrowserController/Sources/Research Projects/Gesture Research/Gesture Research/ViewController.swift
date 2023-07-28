//
//  ViewController.swift
//  Gesture Research
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class ClipView: NSClipView {
    
    override var isFlipped: Bool { true }
    
}

class ViewController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let view = NSView(frame: NSMakeRect(0, 0, 2000, 1000))
        view.wantsLayer = true
        view.layer!.backgroundColor = NSColor.systemGreen.cgColor
        
        scrollView.contentView = ClipView()
        scrollView.documentView = view
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func buttonDidClick(_ sender: Any) {
        scrollView.scroll(scrollView.contentView, to: NSMakePoint(200, 0))
    }
    

}

