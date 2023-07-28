//
//  ViewController.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/7/23.
//

import Cocoa

class ViewController: NSViewController {
    
    let browserController = BrowserController()

    override func viewDidLoad() {
        super.viewDidLoad()

        browserController.buildGUI(in: self.view, with: self)
        browserController.show(groupedVerseData: .init(title: "Title", verses: .init(repeating: .init(), count: 30)))
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: DataRequestReciver {
    func eventRecived(event: BrowserViewController.Event, data: [ScrollView.Key : Any], from sender: BrowserViewController) {
//        print(event)
//        print(data)
        
        switch event {

        case .shouldAppendVerseGroupedData:
            guard let direction = data[.swipeDirection] as? ScrollView.VerticalSwipeDirection else { fatalError() }
            browserController.append(groupedVerseData: .init(title: "Title", verses: .init(repeating: .init(), count: 30)), swipeDirection: direction)
            
        case .shouldAppendSingleVerseData:
            guard let direction = data[.swipeDirection] as? ScrollView.HorizontalSwipeDirection else { fatalError() }
            browserController.appendVerseDataToPresentBrowser(.init(), at: direction)
            
        default: break
            
        }
        
        
    }
}
