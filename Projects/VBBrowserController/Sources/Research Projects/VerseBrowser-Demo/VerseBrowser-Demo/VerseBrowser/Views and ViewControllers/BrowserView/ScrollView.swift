//
//  ScrollView.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

protocol SwipeEventReciver: AnyObject {
    func eventRecived(_ event: ScrollView.Event, data: [ScrollView.Key: Any], from scrollView: ScrollView)
}

class ClipView: NSClipView {
    override var isFlipped: Bool { true }
}

class ScrollView: NSScrollView {
    
    var shouldSendMsg = true
    
    enum Event {
        case shouldLoadOtherVerseStack
        case shouldAppendNewVerseView
        
        case updateVerseGroup
        case appendVerseView
    }
    
    enum Key {
        case swipeDirection
        case singleVerseData
        case verseGroupedData
    }
    
    struct Constant {
        static let swipeMinDistance: Float = 0.3
    }
    
    enum VerticalSwipeDirection {
        case top
        case bottom
    }
    
    enum HorizontalSwipeDirection {
        case left
        case right
    }
    
    var eventReciver: SwipeEventReciver?
    var curScrollingPoint: NSPoint {
        //CGFloat((documentView! as! VerseStackView).tableView.tableColumns.count) * TableView.Constant.verseViewSuggestionWidth -
        return NSMakePoint(
            (documentView!.bounds.width - contentView.bounds.width) * CGFloat(horizontalScroller!.floatValue),
            (documentView!.bounds.height - contentView.bounds.height) * CGFloat(verticalScroller!.floatValue)
        )
        
    }
    
    private var verseGroupedData: GroupedVerseData?
    
    private let verseStackVC = VerseStackViewController.newVC()
    private var verseStackView: NSView { verseStackVC.view }

    func buildGUI(for obj: SwipeEventReciver) {
        
        settings(for: obj)
        loadDocumentView()
        checkVerseAppendEvent(leadingWidth: self.curScrollingPoint.x)
        
    }
    
    func updateGUI(event: Event, datas: [Key: Any]) {
        
        switch event {
            
        case .updateVerseGroup:
            guard let verseGroupData = datas[.verseGroupedData] as? GroupedVerseData else { fatalError() }
            updateDisplay(for: verseGroupData)
            
        case .appendVerseView:
            guard
                let appendDirection = datas[.swipeDirection] as? HorizontalSwipeDirection,
                let newVerseData = datas[.singleVerseData] as? VerseData
            else { fatalError() }
            append(verseData: newVerseData, at: appendDirection)
            
        default: break
            
        }
        
    }
    
    private func updateDisplay(for verseGroupData: GroupedVerseData) {
        verseStackVC.updateGUI(event: .updateColumns, paras: [
            .columnCounts: verseGroupData.verses.count,
            .columnHeaderLabels: (1...verseGroupData.verses.count).map { "Verse \($0):" }
        ])
        verseStackVC.updateGUI(event: .updateData, paras: [:])
    }
    
    private func append(verseData: VerseData, at direction: HorizontalSwipeDirection) {
        
    }
    
    func loadDocumentView() {
        
        documentView = verseStackView
        
        guard let docView = documentView else { fatalError() }

        docView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = docView.heightAnchor.constraint(equalTo: self.heightAnchor)
        heightConstraint.priority = .init(200)
        heightConstraint.isActive = true
        
        let widthConstraint = docView.widthAnchor.constraint(equalTo: self.widthAnchor)
        widthConstraint.priority = .init(200)
        widthConstraint.isActive = true
        
//        documentView!.wantsLayer = true
//        documentView!.layer!.backgroundColor = NSColor.systemYellow.cgColor
        
    }
    
    func settings(for obj: SwipeEventReciver) {
        
        self.eventReciver = obj
        self.allowedTouchTypes = [.direct, .indirect]
        
        let clipView = ClipView(frame: self.bounds)
        self.contentView = clipView
        
        self.hasHorizontalScroller = true
        self.hasVerticalScroller = true
        
        self.horizontalScrollElasticity = .none
        self.verticalScrollElasticity = .none
        
    }
    
    override var acceptsFirstResponder: Bool { true }
    override func becomeFirstResponder() -> Bool { true }
    override func resignFirstResponder() -> Bool { false }
    
    private var twoFingersTouches_Vertical = FingerRecorder()
    private var beginVerticalBoundState: VerticalBoundState!
    
}

// MARK: - Data Handler

extension ScrollView {
    
    
    
}

// MARK: - Touches and Scroll Event Handle

extension ScrollView {
    
    private enum VerticalBoundState {
        case fixed
        case top
        case bottom
        case mid
    }
    
    private enum HorizontalBoundState {
        case fixed
        case right
        case left
        case mid
    }
    
    private struct FingerRecorder {
        
        private var twoFingersIdentity: [NSCopying & NSObjectProtocol] = []
        private var twoFingersTouches: [NSTouch] = []
        
        func finger(id: NSCopying & NSObjectProtocol) -> NSTouch? {
            guard
                let idIndex = self.twoFingersIdentity.firstIndex(where: { $0.isEqual(id) }) as Int?
            else { return nil }
            return twoFingersTouches[idIndex]
        }
        
        mutating func add(finger: NSTouch) {
            self.twoFingersIdentity.append(finger.identity)
            self.twoFingersTouches.append(finger)
        }
        
        mutating func removeAll() {
            self.twoFingersTouches.removeAll(keepingCapacity: true)
            self.twoFingersIdentity.removeAll(keepingCapacity: true)
        }
        
    }
}

extension ScrollView {
    
    override func scroll(_ clipView: NSClipView, to point: NSPoint) {
        super.scroll(clipView, to: point)
//        self.documentView?.layoutSubtreeIfNeeded()
//        print("\(self.curScrollingPoint) -- \(point)")
        if self.curScrollingPoint.x != point.x {
            checkVerseAppendEvent(leadingWidth: point.x)
        }
    }
    
    private func checkVerseAppendEvent(leadingWidth: CGFloat) {
        
        guard shouldSendMsg == true else { return }
        
        let trailingWidth = (documentView!.bounds.width - contentView.bounds.width) - leadingWidth
            
        if let appendDirection = verseStackVC.checkAppendDirection(leadingSpace: leadingWidth, trailingSpace: trailingWidth) {
            eventReciver?.eventRecived(.shouldAppendNewVerseView, data: [.swipeDirection: (appendDirection == .left) ? HorizontalSwipeDirection.left : HorizontalSwipeDirection.right], from: self)
        }
    }
    
//    override func layout() {
//        super.layout()
//
//        checkVerseAppendEvent(leadingWidth: curScrollingPoint.x)
//    }
    
    override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)
        
        guard event.type == .gesture else { return }
            
        let touches = event.touches(matching: .any, in: self)
        if touches.count == 2 {
            
            self.beginVerticalBoundState = checkVerticalBoundState()
            
            self.twoFingersTouches_Vertical.removeAll()
            
            for touch in touches {
                self.twoFingersTouches_Vertical.add(finger: touch)
            }
            
        }
        
    }
    
    override func touchesMoved(with event: NSEvent) {
        super.touchesMoved(with: event)
        
        nextResponder?.touchesMoved(with: event)
    }
    
    override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)
        
        let touches = event.touches(matching: .ended, in: self)
        
        guard touches.count > 0 else { return }
        
        let beginTouches = self.twoFingersTouches_Vertical
        self.twoFingersTouches_Vertical.removeAll()
        
        var magnitudes: [CGFloat] = []
        
        for touch in touches {
            if let beginTouch = beginTouches.finger(id: touch.identity) {
                let magnitude = touch.normalizedPosition.y - beginTouch.normalizedPosition.y
                magnitudes.append(magnitude)
            }
        }
        
        var sum: CGFloat = 0;
        
        for magnitude in magnitudes {
            sum += magnitude
        }
        
        let absoluteSum = fabsf(.init(sum))
        
        guard absoluteSum > Constant.swipeMinDistance else { return }
        
        let boundState = checkVerticalBoundState()
        
        
        guard
            (boundState != .mid && beginVerticalBoundState != .mid) &&
            (beginVerticalBoundState == boundState || beginVerticalBoundState == .fixed || boundState == .fixed)
        else { return }
        
        if sum > 0 {
            if boundState == .bottom || boundState == .fixed {
                self.eventReciver?.eventRecived(.shouldLoadOtherVerseStack, data: [.swipeDirection: VerticalSwipeDirection.bottom], from: self)
            }
            
        } else {
            if boundState == .top || boundState == .fixed {
                self.eventReciver?.eventRecived(.shouldLoadOtherVerseStack, data: [.swipeDirection: VerticalSwipeDirection.top], from: self)
            }
        }
        
    }
    
    override func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)
        
        nextResponder?.touchesCancelled(with: event)
    }
    
    
    
    private func checkVerticalBoundState() -> VerticalBoundState {
        guard let documentView = self.documentView else { fatalError() }

        let clipView = self.contentView
        
        if clipView.bounds.height == documentView.bounds.height {
            return .fixed
        } else if clipView.bounds.origin.y == 0 {
            return .top
        } else if clipView.bounds.origin.y + clipView.bounds.height == documentView.bounds.height {
            return .bottom
        } else {
            return .mid
        }
    }
    
    private func checkHorizontalBoundState() -> HorizontalBoundState {
        guard let documentView = self.documentView else { fatalError() }

        let clipView = self.contentView
        
        if clipView.bounds.width == documentView.bounds.width {
            return .fixed
        } else if clipView.bounds.origin.x == 0 {
            return .left
        } else if clipView.bounds.origin.x + clipView.bounds.width == documentView.bounds.width {
            return .right
        } else {
            return .mid
        }
    }
    
}
