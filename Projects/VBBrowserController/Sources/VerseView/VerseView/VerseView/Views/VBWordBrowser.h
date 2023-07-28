//
//  VBWordBrowser.h
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import <Cocoa/Cocoa.h>
#import "CDSQLite3OperaterDelegate.h"
#import "VBVerseReference.h"
#import "VBMultiSelectionBox.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBWordBrowser : FlippedView

@property (readonly) CDSQLite3OperaterDelegate * DBOperator;
@property (readonly) VBVerseReference * verseRef;
@property NSMenu * rightMenu;

+ (instancetype)newBrowserWithDBOperator:(CDSQLite3OperaterDelegate *)dbOperator;

- (void)addComment;
- (void)refreshWithVerseRef:(VBVerseReference *)verseRef;

@end

NS_ASSUME_NONNULL_END
