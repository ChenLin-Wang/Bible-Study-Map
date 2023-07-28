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

@protocol VBVerseViewLayoutDelegate;

@interface VBWordBrowser : FlippedView

@property (readonly, weak) CDSQLite3OperaterDelegate * DBOperator;
@property (readonly, weak) VBVerseReference * verseRef;
@property (class, readonly) NSSize minimumSize;
@property (weak) id<VBVerseViewLayoutDelegate> layoutDelegate;
@property (weak) NSMenu * rightMenu;

+ (instancetype)newBrowserWithDBOperator:(CDSQLite3OperaterDelegate *)dbOperator layoutDelegate:(id<VBVerseViewLayoutDelegate>)layoutDelegate;

- (void)addComment;
- (void)refreshWithVerseRef:(VBVerseReference *)verseRef;

@end

NS_ASSUME_NONNULL_END
