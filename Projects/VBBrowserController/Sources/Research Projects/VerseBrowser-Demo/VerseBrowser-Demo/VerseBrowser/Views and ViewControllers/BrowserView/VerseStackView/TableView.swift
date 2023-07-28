//
//  TableView.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/9/23.
//

import Cocoa

class TableView: NSTableView {
    
    enum Key {
        case columnCounts
        case columnHeaderLabels
    }

    enum Event {
        case updateColumns
        case updateData
    }
    
    enum AppendDirection {
        case left
        case right
    }
    
    struct Constant {
        
        static let verseViewSuggestionWidth: CGFloat = 500
        static var verseViewMaxWidth: CGFloat { Self.verseViewSuggestionWidth }
        static var verseViewMinWidth: CGFloat { Self.verseViewSuggestionWidth }
        static let rowNumber = 1
        static let headerViewHeight: CGFloat = 13
        
    }
    

    func buildGUI(for superView: NSView) {
        
        buildConstraints(superView)
        settings()
//        self.wantsLayer = true
//        self.layer!.backgroundColor = NSColor.systemGreen.cgColor
    }
    
    func updateGUI(event: Event, paras: [Key: Any]) {
        
        switch event {
            
        case .updateColumns:
            guard
                let count = paras[.columnCounts] as? Int,
                let headerLabels = paras[.columnHeaderLabels] as? [String],
                headerLabels.count == count
            else { fatalError() }
            updateColumns(with: count, headerLabels: headerLabels)
            
        case .updateData:
            updateData()
            
        }
        
    }
    
    func checkAppendDirection(leadingSpace: CGFloat, trailingSpace: CGFloat) -> AppendDirection? {
        
        guard tableColumns.count > 0 else { return .left }
        
        let leftestColumn = tableColumns.first!
        let rightestColumn = tableColumns.last!
        
        if leftestColumn.width > leadingSpace {
            return .left
        } else if rightestColumn.width > trailingSpace {
            return .right
        }
        
        return nil
    }
    
    func buildConstraints(_ superView: NSView) {
        
        guard let headerView = self.headerView else { return }
        
        let separatorLine = NSBox(frame: .init(x: 0, y: 0, width: 100, height: 1))
        separatorLine.boxType = .separator
        
        superView.addSubview(headerView)
        superView.addSubview(separatorLine)
        superView.addSubview(self)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: Constant.headerViewHeight).isActive = true
        headerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        headerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        separatorLine.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        separatorLine.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
        separatorLine.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        
        self.topAnchor.constraint(equalTo: separatorLine.bottomAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        
        self.setContentHuggingPriority(.init(190), for: .vertical)
        self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        self.setContentHuggingPriority(.init(190), for: .horizontal)
        self.setContentCompressionResistancePriority(.init(220), for: .horizontal)
        
    }
    
    func settings() {
        
        self.delegate = self
        self.dataSource = self
        self.style = .fullWidth
        self.intercellSpacing = NSZeroSize
        self.usesAutomaticRowHeights = true
        self.focusRingType = .none
        self.selectionHighlightStyle = .none
        self.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        self.gridStyleMask = [.solidVerticalGridLineMask]
        
    }
    
    private var contentWidth: CGFloat = 0
    
}

// MARK: - Layout

extension TableView {
    
    override var intrinsicContentSize: NSSize {
        
        guard tableColumns.count > 0 else { return NSZeroSize }
        
        if let height = rowView(atRow: 0, makeIfNecessary: false)?.fittingSize.height {
            return NSSize(width: contentWidth, height: height + Constant.headerViewHeight)
        }
        
        return .init(width: 1200, height: Constant.headerViewHeight)
    }
    
    override func layout() {
        super.layout()
        
        guard let actualWidth = self.superview?.superview?.superview?.frame.width else { return }
        
        let columnCount = CGFloat(tableColumns.count)
        
        let maxWidth = Constant.verseViewMaxWidth * columnCount
        let minWidth = Constant.verseViewMinWidth * columnCount
        
        if actualWidth < maxWidth && actualWidth > minWidth {
            contentWidth = actualWidth
            self.setContentCompressionResistancePriority(.init(190), for: .horizontal)
        } else if actualWidth >= maxWidth {
            contentWidth = maxWidth
            self.setContentCompressionResistancePriority(.init(190), for: .horizontal)
        } else if actualWidth <= minWidth {
            contentWidth = minWidth
            self.setContentCompressionResistancePriority(.init(220), for: .horizontal)
        }
        
    }
    
}

// MARK: - UpdateData

extension TableView {
    
    func updateData() {
        reloadData()
    }
    
}

// MARK: - UpdateColumns

extension TableView {
    
    func updateColumns(with count: Int, headerLabels: [String]) {
        
        let neededColumns = count - tableColumns.count
        guard neededColumns != 0 else { return }
        
        if neededColumns > 0 {
            
            for i in 0..<neededColumns {
                let newColumn = makeNewColumn(with: "\(i)")
                addTableColumn(newColumn)
            }
            
        } else {
            
            for _ in 0..<(-neededColumns) {
                self.removeTableColumn(tableColumns.last!)
            }
            
        }
        
        // update header labels
        for (i, curColumns) in tableColumns.enumerated() {
            curColumns.headerCell.stringValue = headerLabels[i]
        }
        
    }
    
    func makeNewColumn(with id: String) -> NSTableColumn {
        let tableColumn = NSTableColumn(identifier: .init(id))
        tableColumn.width = Constant.verseViewSuggestionWidth
        tableColumn.maxWidth = Constant.verseViewMaxWidth
        tableColumn.minWidth = Constant.verseViewMinWidth
        tableColumn.headerCell = TableHeaderCell(textCell: id)
        tableColumn.headerCell.font = NSFont.systemFont(ofSize: 15)
        return tableColumn
    }
    
}

extension TableView: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return (tableColumns.count > 0) ? Constant.rowNumber : 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = VerseViewController.newVC().view
        return view
    }
    
}


class TableHeaderCell: NSTableHeaderCell {

    override init(textCell string: String) {
        super.init(textCell: string)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
