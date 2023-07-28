//
//  VerseBrowseController.swift
//  VerseBrowseView
//
//  Created by CL Wang on 2/6/23.
//

import Cocoa

class VerseBrowseController: NSViewController {

    lazy var scrollView = self.view.subviews.first as! VerseBrowseScrollView
    lazy var clipView = scrollView.contentView as! VerseBrowseClipView
    lazy var documentView = scrollView.documentView as! VerseBrowseDocumentView
    lazy var contentView = scrollView.documentView!.subviews.first as! VerseBrowseView
    
    lazy var newDemoVC = NSStoryboard(name: "DemoViewController", bundle: nil).instantiateInitialController() as! DemoViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.build()
        clipView.build()
        documentView.build()
        contentView.build()
        
        addDemoView(to: contentView)
        
    }
    
    func shouldStartResize() {
        newDemoVC.demoView.startResize()
    }
    
    func shouldStopResize() {
        newDemoVC.demoView.stopResize()
    }
    
    private func addDemoView(to view: VerseBrowseView) {
        view.addAndDisplay(newDemoVC)
    }
    
}
