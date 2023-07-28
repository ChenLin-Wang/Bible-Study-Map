//
//  ViewController.swift
//  NSTableView no Scrolling Try
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

class ViewController: NSViewController {
    
    lazy var tableView = TableView(frame: self.view.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.headerView = TableHeaderView()
        
        let headerView = tableView.headerView!
        
        self.view.addSubview(headerView)
        self.view.addSubview(tableView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        headerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        headerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.style = .automatic
        tableView.intercellSpacing = NSMakeSize(20, 30)
        tableView.usesAutomaticRowHeights = true
        
        tableView.focusRingType = .none
        tableView.selectionHighlightStyle = .none
        
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        tableView.backgroundColor = .systemGreen
        
        for i in 0...3 {
            let tableColumn = NSTableColumn(identifier: .init("\(i)"))
            tableColumn.width = self.view.frame.width / 4
            tableColumn.headerCell = TableHeaderCell(textCell: "asdfasdf")
            tableColumn.headerCell.font = NSFont.systemFont(ofSize: 24)
//            tableColumn.headerCell.backgroundColor = .red
//            tableColumn.headerCell.drawsBackground = true
            tableColumn.headerCell.alignment = .center
            tableView.addTableColumn(tableColumn)
        }
        
        tableView.reloadData()
        
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int { 2 }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        ExampleVC.newVC().drawStyle().view
    }
    
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        true
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        print(tableView.selectedColumn)
        return true
    }
    
    func tableView(_ tableView: NSTableView, didDrag tableColumn: NSTableColumn) {
        print("true")
    }
    
}


class TableView: NSTableView {
    
    override var acceptsFirstResponder: Bool { true }
    
}

class TableHeaderView: NSTableHeaderView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
//        self.wantsLayer = true
//        self.layer!.backgroundColor = .black
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class TableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        self.drawInterior(withFrame: cellFrame, in: controlView)
    }

    override init(textCell string: String) {
        super.init(textCell: string)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        print(cellFrame.size)
        print("2: \(controlView.frame)")
        NSColor.systemRed.set()

        NSBezierPath(rect: cellFrame).fill()
        
        let str = NSAttributedString(string: stringValue, attributes:
                                        [NSAttributedString.Key.foregroundColor: self.textColor!,
                                         NSAttributedString.Key.font: self.font!])
        
        str.draw(in: cellFrame)
//        super.drawInterior(withFrame: cellFrame, in: controlView)
    }

}
