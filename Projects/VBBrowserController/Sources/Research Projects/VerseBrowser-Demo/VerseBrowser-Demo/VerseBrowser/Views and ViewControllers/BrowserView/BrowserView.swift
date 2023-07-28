//
//  BrowserView.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

class BrowserView: NSView {
    
    struct Constant {
        static let maxVerseViewNum = 20
    }
    
    lazy var scrollView = ScrollView()
    var groupedVerseData: GroupedVerseData!
    private weak var swipeEventReciver: SwipeEventReciver?
    
    static func newV() -> BrowserView {
        BrowserView(frame: NSMakeRect(0, 0, 10, 10))
    }
    
    func buildGUI(for eventReciver: SwipeEventReciver) {
        self.swipeEventReciver = eventReciver
        loadScrollView(for: self)
    }
    
    func updateData(_ groupedVerseData: GroupedVerseData) {
        self.groupedVerseData = groupedVerseData
        scrollView.updateGUI(event: .updateVerseGroup, datas: [.verseGroupedData: groupedVerseData])
    }
    
    func append(verseData: VerseData, in direction: ScrollView.HorizontalSwipeDirection) {
        
        let oldScrollingPoint = scrollView.curScrollingPoint
        
//        print("\(oldScrollingPoint) -- \(direction)")
        
        switch direction {
            
        case .left:
            groupedVerseData.insert(verse: verseData, to: 0)
            
            if groupedVerseData.verses.count > Constant.maxVerseViewNum {
                for _ in Constant.maxVerseViewNum..<groupedVerseData.verses.count {
                    groupedVerseData.removeLast()
                }
            }
        
            scrollView.updateGUI(event: .updateVerseGroup, datas: [.verseGroupedData: groupedVerseData])
            scrollView.shouldSendMsg = false
            scrollView.scroll(scrollView.contentView, to: NSMakePoint(TableView.Constant.verseViewSuggestionWidth + oldScrollingPoint.x, oldScrollingPoint.y))
            scrollView.shouldSendMsg = true
        case .right:
            groupedVerseData.append(verse: verseData)
            
            if groupedVerseData.verses.count > Constant.maxVerseViewNum {
                for _ in Constant.maxVerseViewNum..<groupedVerseData.verses.count {
                    groupedVerseData.removeFirst()
                }
            }
            
//            print(NSMakePoint(oldScrollingPoint.x - TableView.Constant.verseViewSuggestionWidth - 1, oldScrollingPoint.y))
            scrollView.updateGUI(event: .updateVerseGroup, datas: [.verseGroupedData: groupedVerseData])
            scrollView.shouldSendMsg = false
            scrollView.scroll(scrollView.contentView, to: NSMakePoint(oldScrollingPoint.x - TableView.Constant.verseViewSuggestionWidth, oldScrollingPoint.y))
            scrollView.shouldSendMsg = true
        }
        
    }
    
    func loadScrollView(for eventReciver: SwipeEventReciver) {
        
        self.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        scrollView.buildGUI(for: eventReciver)
    }
    
}

extension BrowserView: SwipeEventReciver {
    
    func eventRecived(_ event: ScrollView.Event, data: [ScrollView.Key : Any], from scrollView: ScrollView) {
        swipeEventReciver?.eventRecived(event, data: data, from: scrollView)
    }
    
}
