//
//  ViewController.swift
//  VerseBrowseView
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class ViewController: NSViewController {
    
    var viewBrowseController: VerseBrowseController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func startResizeButtonDidClick(_ sender: NSButton) {
        viewBrowseController.shouldStartResize()
    }
    
    @IBAction func stopResizeButtonDidClick(_ sender: NSButton) {
        viewBrowseController.shouldStopResize()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "VerseBrowseController" {
            viewBrowseController = segue.destinationController as? VerseBrowseController
        }
    }
    
}

