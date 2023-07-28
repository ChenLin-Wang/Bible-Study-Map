//
//  VerseData.swift
//  VerseBrowser-Demo
//
//  Created by CL Wang on 2/7/23.
//

import Cocoa

class GroupedVerseData: NSObject {
    
    let title: String
    private(set) var verses: [VerseData]
    
    init(title: String, verses: [VerseData] = []) {
        self.title = title
        self.verses = verses
    }
    
    func isEqualTo(_ groupedVerseData: GroupedVerseData) -> Bool {
        self == groupedVerseData
    }
    
    func insert(verse: VerseData, to index: Int) {
        verses.insert(verse, at: index)
    }
    
    func append(verse: VerseData) {
        verses.append(verse)
    }
    
    func removeFirst() {
        verses.removeFirst()
    }
    
    func removeLast() {
        verses.removeLast()
    }
    
}

class VerseData: NSObject {
    
}
