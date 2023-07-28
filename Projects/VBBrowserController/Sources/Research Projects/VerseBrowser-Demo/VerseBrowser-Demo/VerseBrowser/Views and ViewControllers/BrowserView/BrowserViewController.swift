//
//  BrowserViewController.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

protocol DataRequestReciver: AnyObject {
    
    func eventRecived(event: BrowserViewController.Event, data: [ScrollView.Key: Any], from sender: BrowserViewController)
    
}


class BrowserViewController: NSViewController {
    
    enum Event {
        case updateData
        case appendVerseData
        
        case shouldAppendVerseGroupedData
        case shouldAppendSingleVerseData
    }
    
    enum Key {
        case groupedVerseData
        case verseData
        case swipeEventReciver
        case swipeDirection
    }
    
    struct Constant {
        static let animationDuration: TimeInterval = 0.5
        static let maxBrowserViewNum = 3
    }
    
    weak var dataRequestReciver: DataRequestReciver?
    
    private var browserViews: [BrowserView] = []
    private var presentBrowserView: BrowserView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateGUI(event: Event, data: [Key: Any]) {
        
        switch event {
        case .updateData:
            guard
                let groupedVerseData = data[.groupedVerseData] as? GroupedVerseData,
                let swipeEventReciver = data[.swipeEventReciver] as? SwipeEventReciver,
                let swipeDirection = data[.swipeDirection] as? ScrollView.VerticalSwipeDirection
            else { fatalError() }
            updateVerseGroup(groupedVerseData, direction: swipeDirection, swipeEventReciver: swipeEventReciver)
        case .appendVerseData:
            guard
                let verseData = data[.verseData] as? VerseData,
                let direction = data[.swipeDirection] as? ScrollView.HorizontalSwipeDirection
            else { fatalError() }
            append(verseData: verseData, at: direction)
            
        default: break
        }
        
    }
    
    private func append(verseData: VerseData, at direction: ScrollView.HorizontalSwipeDirection) {
        presentBrowserView?.append(verseData: verseData, in: direction)
    }
    
    private func updateVerseGroup(_ groupData: GroupedVerseData, direction: ScrollView.VerticalSwipeDirection, swipeEventReciver: SwipeEventReciver) {
        let targetBrowserView: BrowserView
        
        targetBrowserView = BrowserView.newV()
        targetBrowserView.buildGUI(for: swipeEventReciver)
        
        targetBrowserView.updateData(groupData)
        if presentBrowserView != targetBrowserView {
            embed(browserView: targetBrowserView, embedAnimation: direction)
            presentBrowserView = targetBrowserView
            
            switch direction {
                
            case .top:
                browserViews.insert(targetBrowserView, at: 0)
            case .bottom:
                browserViews.append(targetBrowserView)
            }
            
        }
        
        checkBrowserViewsCount()
        
        func checkBrowserViewsCount() {
            guard browserViews.count > Constant.maxBrowserViewNum else { return }
            
            for _ in 0..<(browserViews.count - Constant.maxBrowserViewNum) {
                switch direction {
                case .top: browserViews.removeLast()
                case .bottom: browserViews.removeFirst()
                }
                
            }
        }
        
    }
    
    private func turn(to targetBrowser: BrowserView, direction: ScrollView.VerticalSwipeDirection) {
        fadeOut(view: presentBrowserView!, embedAnimation: direction)
        fadeIn(view: targetBrowser, embedAnimation: direction)
        presentBrowserView = targetBrowser
    }
    
    static func newVC(with dataRequestReciver: DataRequestReciver) -> Self {
        let newVC = NSStoryboard(name: "BrowserViewController", bundle: nil).instantiateInitialController() as! Self
        newVC.dataRequestReciver = dataRequestReciver
        return newVC
    }
        
    private var heightConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var leftConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
}

// MARK: - View Embed Animations

extension BrowserViewController {

    private func embed(browserView: BrowserView, embedAnimation: ScrollView.VerticalSwipeDirection) {
        if let curBrowserView = presentBrowserView {
            fadeOut(view: curBrowserView, embedAnimation: embedAnimation)
        }
        fadeIn(view: browserView, embedAnimation: embedAnimation)
    }
    
    private func fadeOut(view: BrowserView, embedAnimation: ScrollView.VerticalSwipeDirection) {
        
        view.wantsLayer = true
        
        bottomConstraint.isActive = false
        
        let adjustConstraint: NSLayoutConstraint
        
        switch embedAnimation {
        case .top: adjustConstraint = view.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        case .bottom: adjustConstraint = view.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        }
        
        adjustConstraint.isActive = true
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constant.animationDuration
            context.allowsImplicitAnimation = true
            
            self.view.layoutSubtreeIfNeeded()
        } completionHandler: {
//            emptyConstraints()
            adjustConstraint.isActive = false
            view.removeFromSuperview()
        }
        
        func emptyConstraints() {
            heightConstraint.isActive = false
            rightConstraint.isActive = false
            leftConstraint.isActive = false
            bottomConstraint.isActive = false
            
            heightConstraint = nil
            rightConstraint = nil
            leftConstraint = nil
            bottomConstraint = nil
        }
    }
    
    private func fadeIn(view: BrowserView, embedAnimation: ScrollView.VerticalSwipeDirection) {
        
        view.wantsLayer = true
        
        buildConstraints()
        
        let adjustConstraint: NSLayoutConstraint
        
        switch embedAnimation {
        case .top: adjustConstraint = view.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        case .bottom: adjustConstraint = view.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        }
        adjustConstraint.isActive = true
        
        self.view.layoutSubtreeIfNeeded()
        
        bottomConstraint = view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        adjustConstraint.isActive = false
        bottomConstraint.isActive = true
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constant.animationDuration
            context.allowsImplicitAnimation = true
            
            self.view.layoutSubtreeIfNeeded()
        } completionHandler: {
            view.scrollView.documentView!.layoutSubtreeIfNeeded()
        }
        
        
        func buildConstraints() {
            self.view.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            heightConstraint = view.heightAnchor.constraint(equalTo: self.view.heightAnchor)
            rightConstraint = view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
            leftConstraint = view.leftAnchor.constraint(equalTo: self.view.leftAnchor)
            
            heightConstraint.isActive = true
            rightConstraint.isActive = true
            leftConstraint.isActive = true
        }
        
    }
}

// MARK: - Swipe Event Reciver

extension BrowserViewController: SwipeEventReciver {
    
    func eventRecived(_ event: ScrollView.Event, data: [ScrollView.Key : Any], from scrollView: ScrollView) {
        
        switch event {

        case .shouldLoadOtherVerseStack:
            
            guard let direction = data[.swipeDirection] as? ScrollView.VerticalSwipeDirection else { fatalError() }
            let curBrowserIndex: Int = browserViews.firstIndex { $0 == presentBrowserView }!
            
            if
                (direction == .top && curBrowserIndex > 0) ||
                (direction == .bottom && curBrowserIndex < (browserViews.count - 1))
            {
                
                let targetIndex: Int
                
                switch direction {
                case .top: targetIndex = curBrowserIndex - 1
                case .bottom: targetIndex = curBrowserIndex + 1
                }
                
                turn(to: browserViews[targetIndex], direction: direction)
            } else {
                self.dataRequestReciver?.eventRecived(event: .shouldAppendVerseGroupedData, data: data, from: self)
            }

        case .shouldAppendNewVerseView: self.dataRequestReciver?.eventRecived(event: .shouldAppendSingleVerseData, data: data, from: self)
        default: break
        }
        
    }
    
}
