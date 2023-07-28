//
//  VerseStackView.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

class VerseStackView: NSView {

    var tableView: TableView = TableView()
    
    func buildGUI() {
        self.deployTableView()
    }
    
    func updateGUI(event: TableView.Event, paras: [TableView.Key: Any]) {
        tableView.updateGUI(event: event, paras: paras)
        self.layout()
        tableView.layout()
//        print("------\(self.bounds.width)")
    }
    
    func deployTableView() {
        tableView.buildGUI(for: self)
    }
    
    func checkAppendDirection(leadingSpace: CGFloat, trailingSpace: CGFloat) -> TableView.AppendDirection? {
//        print("---SSS---\(self.bounds.width)")
        return tableView.checkAppendDirection(leadingSpace: leadingSpace, trailingSpace: trailingSpace)
    }
    
}
