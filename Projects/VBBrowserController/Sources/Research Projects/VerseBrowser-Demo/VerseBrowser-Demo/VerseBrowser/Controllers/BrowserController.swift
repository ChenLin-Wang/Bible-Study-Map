//
//  BrowserController.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/7/23.
//

import Cocoa

protocol DataProvider {
    
    
    
}

class BrowserController: NSObject {
    
    private var browserVC: BrowserViewController!

    func buildGUI(in view: NSView, with dataRequestReceiver: DataRequestReciver) {
        browserVC = BrowserViewController.newVC(with: dataRequestReceiver)
        buildLayoutConstraints(in: view)
    }
    
    func show(groupedVerseData: GroupedVerseData) {
        browserVC.updateGUI(event: .updateData, data: [
            .groupedVerseData: groupedVerseData,
            .swipeEventReciver: browserVC,
            .swipeDirection: ScrollView.VerticalSwipeDirection.top
        ])
    }
    
    func append(groupedVerseData: GroupedVerseData, swipeDirection: ScrollView.VerticalSwipeDirection) {
        browserVC.updateGUI(event: .updateData, data: [
            .groupedVerseData: groupedVerseData,
            .swipeEventReciver: browserVC,
            .swipeDirection: swipeDirection
        ])
    }
    
    func appendVerseDataToPresentBrowser(_ verseData: VerseData, at direction: ScrollView.HorizontalSwipeDirection) {
        browserVC.updateGUI(event: .appendVerseData, data: [
            .verseData: verseData,
            .swipeDirection: direction
        ])
    }
    
    private func buildLayoutConstraints(in view: NSView) {
        
        view.addSubview(browserVC.view)
        
        browserVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        browserVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        browserVC.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        browserVC.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        browserVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    
}
