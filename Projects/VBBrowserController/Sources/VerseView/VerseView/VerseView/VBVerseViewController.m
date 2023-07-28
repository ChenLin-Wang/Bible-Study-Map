//
//  VBVerseViewController.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBVerseViewController.h"
#import "CDSQLite3OperaterDelegate.h"
#import "VBWordBrowser.h"

@interface VBVerseViewController ()

@property CDSQLite3OperaterDelegate * dataOperator;
@property VBWordBrowser * wordBrowser;
@property (weak) IBOutlet NSView * contentView;
@property (strong) IBOutlet NSMenu * rightClickMenu;

@end

@implementation VBVerseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * databaseAddress = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/NewBibleStudy/database"];

    _dataOperator = [CDSQLite3OperaterDelegate new];
    CDdataOperaterError connectErr = [_dataOperator connectDataBasewithAddress: databaseAddress
                                                         withDatabase: @"BibleDataBase.sqlite"
                                                               byUser: @""
                                                          andPassword: @""];

    // 检查数据库连接状态
    if (connectErr != CDIDU_sucsess) { NSLog(@"数据库连接失败！错误号为 %d", connectErr); return; }
    NSLog(@"数据库连接成功");

    // 嵌入 wordBrowser
    [self embedWordBrowser];
    
    [self.wordBrowser refreshWithVerseRef:[[VBVerseReference alloc]initWithVersionMarks:@[] verseIndex:@(1001001)]];
}

- (IBAction)addCommentButtonDidClick:(NSButton *)sender {
    [self.wordBrowser addComment];
}

// 嵌入 wordBrowser
- (void)embedWordBrowser {
    self.wordBrowser = [VBWordBrowser newBrowserWithDBOperator:self.dataOperator];
    self.wordBrowser.frame = self.contentView.bounds;
    self.wordBrowser.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.wordBrowser.rightMenu = self.rightClickMenu;
    [self.contentView addSubview: self.wordBrowser];
}

- (VBVerseReference *)verseReference {
    return self.wordBrowser.verseRef;
}

- (void)setVerseReference:(VBVerseReference *)verseReference {
    [self.wordBrowser refreshWithVerseRef:verseReference];
}

@end
