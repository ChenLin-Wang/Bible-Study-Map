//
//  VBWordBrowser.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBWordBrowser+DatabaseOperates.h"
#import "VBWordGroup.h"
#import "VBCommentCard.h"
#import "NSObject+LayoutConstraints.h"
#import "VBWordGroupController.h"

@interface VBWordBrowser()

@property (readonly) NSNumber * BPVNumber;
@property VBWordGroupController * wordGroupController;
@property NSMutableArray<VBCommentCard *> * commentCards;
@property FlippedView * cardsView;

// ----- GraphicLayoutDelegate 的所需参数 -----
@property NSMutableArray<__kindof VBSelectableCard *> * selectedCards;
@property (readonly) NSArray<VBWordCard *> * selectedWordCards;
@property (readonly) NSArray<VBCommentCard *> * selectedCommentCards;
// ------------------------------------------

// ----- MultiSelectionHandler 的所需参数 -----
@property VBMultiSelectionBox * multiSelectionBox;
@property NSPoint multiSelectionStartPoint;
@property NSPoint multiSelectionEndPoint;
@property BOOL canDrag;
@property NSMutableArray<NSValue *> * cardResizeStartFrames;
@property NSRect multiSelectionResizeStartRect;
@property VBSelectionBoxResizeParams lastMultiSelectionResizeParams;
// ------------------------------------------

// ----- SelectionBoxMouseEventHandler 的所需参数 -----
@property (nullable) __kindof NSView * curSelectLockedCardView;
@property (nullable) __kindof NSView * oldSelectLockedCardView;
// --------------------------------------------------

// ----- RightClickMenu 的所需参数 -----
// --------------------------------------------------

// ----- DatabaseOperates 的所需参数 -----
@property CDUndoManger * dataUndomanager;
// --------------------------------------------------

// ----- ContentSize 的所需参数 -----
@property NSSize contentSize;
@property (readonly) NSSize minSize;
@property (readonly) CGFloat widthOverage;
@property (readonly) CGFloat heightOverage;
@property CALayer * contentSizeBorderLayer;
@property CALayer * realContentSizeBorderLayer;
// --------------------------------------------------

@end

@interface VBWordBrowser(DataWrapper)
- (void)fetchCardsFromDatabase;
- (void)fetchCommentsFromDatabase;

- (VBCommentCard *)newCommentCardWithComment:(VBComment *)comment;

- (void)dataChangedWithEffectedCards:(NSArray<__kindof VBSelectableCard *> *)effectedCards type:(VBCardDataChangeType)type;
@end

@interface VBWordBrowser(MultiSelectionHandler)
- (void)prepareMultiSelectionBox;
@end

@interface VBWordBrowser(MultiSelectionHandler)
- (void)refreshWithSelectedCards:(NSMutableArray<__kindof VBSelectableCard *> *)cards;
@end

@interface VBWordBrowser(RightClickMenu)
- (void)prepareMenu;
@end

@interface VBWordBrowser(ContentSize)
- (void)prepareContentSize;
- (BOOL)recorrectCommentCardsFrame;
- (void)calculateTotalContentSizeWithSendChangeNotification:(BOOL)sendChangeNotification;
- (BOOL)appendContentSizeWithRect:(NSRect)rect sendChangeNotification:(BOOL)sendChangeNotification;
- (void)contentSizeChanged;
@end


/*-----------------------------------------------------------------------------------------------------------*/


@implementation VBWordBrowser
@synthesize DBOperator = DBOperator;
@synthesize verseRef = verseRef;
@synthesize curSelectLockedCardView = curSelectLockedCardView;
@synthesize rightMenu = rightMenu;

+ (instancetype)newBrowserWithDBOperator:(CDSQLite3OperaterDelegate *)dbOperator {
    VBWordBrowser * wordBrowser = [VBWordBrowser new];
    wordBrowser->DBOperator = dbOperator;
    [wordBrowser prepare];
    return wordBrowser;
}

- (void)prepare {
    self.selectedCards = [NSMutableArray new];
    self.commentCards = [NSMutableArray new];
    self.cardResizeStartFrames = [NSMutableArray new];
    self.wordGroupController = [VBWordGroupController new];
    
    self.cardsView = [FlippedView new];
    [self addSubview:self.cardsView];
    [self makeEdgeLayoutConstraintsForView:self usingView:self.cardsView];
    
    [self prepareDatabase];
    [self prepareMultiSelectionBox];
    [self prepareContentSize];
}

- (void)refreshWithVerseRef:(VBVerseReference *)verseRef {
    self->verseRef = verseRef;
    [self clearCurCards];
    [self deployWordGroups];
    [self deployCommentCards];
    
    [self calculateTotalContentSizeWithSendChangeNotification:true];
}

- (void)addComment {
    NSSize size = NSMakeSize(200, 40);
    VBComment * lastComment = self.commentCards.lastObject.comment;
    VBComment * newComment = [self createANewCommentWithLinerPoint:(lastComment != nil) ? NSMakePoint(lastComment.linerPoint.x, lastComment.linerPoint.y + lastComment.size.height + VB_CARD_SPACING) : NSMakePoint(VB_CARD_SPACING, VB_CARD_SPACING) size:size];
    
    VBCommentCard * newCommendCard = [self newCommentCardWithComment:newComment];
    [self.cardsView addSubview:newCommendCard];
    [self.commentCards addObject:newCommendCard];
    [self addCommentToDatabase:newComment];
    
    [self appendContentSizeWithRect:newCommendCard.layoutFrame sendChangeNotification:true];
}

- (void)clearCurCards {
    NSInteger cardsCounts = self.cardsView.subviews.count;
    for (NSInteger i = 0; i < cardsCounts; i ++) {
        [self.cardsView.subviews.firstObject removeFromSuperview];
    }
    
    self.contentSize = NSZeroSize;
    [self.multiSelectionBox clearSelectBox];
    [self.multiSelectionBox clearPreparationRing];
}

- (void)deployWordGroups {
    [self fetchCardsFromDatabase];
    
    for (VBWordGroup * curGroup in self.wordGroupController.groups) {
        for (VBWordCard * curCard in curGroup.wordCards) {
            [self.cardsView addSubview:curCard];
        }
    }
    
    [self.wordGroupController recorrectFrames];
}

- (void)deployCommentCards {
    [self fetchCommentsFromDatabase];
    
    for (VBCommentCard * curCommentCard in self.commentCards) {
        [self.cardsView addSubview:curCommentCard];
    }
    
    [self recorrectCommentCardsFrame];
}






- (NSNumber *)BPVNumber { return self.verseRef.verseIndex; }

- (NSArray<VBWordCard *> *)selectedWordCards {
    NSMutableArray * filteredArray = [NSMutableArray new];
    
    for (__kindof VBSelectableCard * curCard in self.selectedCards) {
        if ([curCard isKindOfClass:VBWordCard.class]) {
            [filteredArray addObject:curCard];
        }
    }
    
    return filteredArray;
}

- (NSArray<VBCommentCard *> *)selectedCommentCards {
    NSMutableArray * filteredArray = [NSMutableArray new];
    
    for (__kindof VBSelectableCard * curCard in self.selectedCards) {
        if ([curCard isKindOfClass:VBCommentCard.class]) {
            [filteredArray addObject:curCard];
        }
    }
    
    return filteredArray;
}

- (__kindof NSView *)curSelectLockedCardView {
    return self->curSelectLockedCardView;
}

- (void)setCurSelectLockedCardView:(__kindof NSView *)curSelectLockedCardView {
    self.oldSelectLockedCardView = self->curSelectLockedCardView;
    self->curSelectLockedCardView = curSelectLockedCardView;
}

- (NSMenu *)rightMenu {
    return self->rightMenu;
}

- (void)setRightMenu:(NSMenu *)rightMenu {
    self->rightMenu = rightMenu;
    [self prepareMenu];
}

- (NSSize)minSize {
    return NSMakeSize(VBWordCard.fixedSize.width, VBWordCard.fixedSize.height * 3 + VB_CARD_SPACING * 2);
}

- (CGFloat)widthOverage {
    return VBWordCard.fixedSize.width + VB_CARD_SPACING;
}

- (CGFloat)heightOverage {
    return VB_SPACING_OVERAGE;
}

@end


/*-----------------------------------------------------------------------------------------------------------*/


// 此分类处理单个 card 的鼠标事件
@implementation VBWordBrowser(GraphicPositionDelegate)

- (void)selectableCard:(__kindof VBSelectableCard *)card didSelect:(NSEvent *)event {
//    NSLog(@"didSelect");
    if (event.modifierFlags & NSEventModifierFlagShift) {
        if (card.selectState) {
            [self.selectedCards removeObject:card];
        } else {
            [self.selectedCards addObject:card];
        }
        
        [card changeSelectState:!card.selectState];
        [self refreshWithSelectedCards:self.selectedCards];
    } else {
        [self refreshWithSelectedCards:[NSMutableArray arrayWithArray:@[card]]];
    }
}

- (void)selectableCard:(__kindof VBSelectableCard *)card mouseDown:(NSEvent *)event {}

- (void)selectableCard:(__kindof VBSelectableCard *)card positionDragging:(NSEvent *)event {
    
    VBSelectableCardPositionParams positionParams = card.positionParams;
    
    positionParams.dragStepOffset = NSMakeSize(positionParams.dragStepOffset.width, -positionParams.dragStepOffset.height);
    
    if (![self.selectedCards containsObject:card]) {
        [self refreshWithSelectedCards:[NSMutableArray arrayWithArray:@[card]]];
    }
    
    for (VBSelectableCard * curSelectedCard in self.selectedCards) {
        [curSelectedCard changeFrame:CGRectOffset(curSelectedCard.layoutFrame, positionParams.dragStepOffset.width, positionParams.dragStepOffset.height)];
    }
    
    [self.multiSelectionBox showSelectBoxAtRect:CGRectOffset(self.multiSelectionBox.selectionRect, positionParams.dragStepOffset.width, positionParams.dragStepOffset.height)];
}

- (void)selectableCard:(__kindof VBSelectableCard *)card dragFinished:(NSEvent *)event {
//    NSLog(@"dragFinished");
    VBSelectableCardPositionParams positionParams = card.positionParams;
    
    positionParams.dragTotalOffset = NSMakeSize(positionParams.dragTotalOffset.width, -positionParams.dragTotalOffset.height);
    
    VBCardsMoveResult moveResult = [self.wordGroupController wordCardsDidMove:self.selectedCards offset:positionParams.dragTotalOffset];
    
    if ([card isKindOfClass:VBWordCard.class]) {
        self.curSelectLockedCardView = self;
        [self.window makeFirstResponder:self];
    }
    
    // 检查是否有负坐标的，并纠正
    [self recorrectCommentCardsFrame];
    [self refreshWithSelectedCards:self.selectedCards];
    
    // 通知：cards 数据有变化
    [self dataChangedWithEffectedCards:moveResult.effectedCards type:VBCardDataChangeTypeMove];
    [self calculateTotalContentSizeWithSendChangeNotification:true];
}

@end


/*-----------------------------------------------------------------------------------------------------------*/


@interface VBWordBrowser(SelectionBoxMouseEventHandler)<VBSelectionBoxMouseEventHandler> @end

// 此分类处理鼠标事件传递
@implementation VBWordBrowser(SelectionBoxMouseEventHandler)

- (void)prepareSelectionBoxParams {
    self.curSelectLockedCardView = nil;
}

- (BOOL)selectionBox:(VBMultiSelectionBox *)selectionBox allowResize:(NSEvent *)event {
    for (__kindof VBSelectableCard * curCard in self.selectedCards) {
        if ([curCard isKindOfClass:VBCommentCard.class]) return true;
    }
    return false;
}

- (void)selectionBox:(VBMultiSelectionBox *)selectionBox resizeWillStart:(NSEvent *)event {
//    NSLog(@"resize will start");
    [self refreshWithSelectedCards:((NSMutableArray<__kindof VBSelectableCard *> *)self.selectedCommentCards)];
    
    self.multiSelectionResizeStartRect = self.multiSelectionBox.selectionRect;
    
    [self.cardResizeStartFrames removeAllObjects];
    
    for (__kindof VBSelectableCard * curCard in self.selectedCards) {
        [self.cardResizeStartFrames addObject:@(curCard.layoutFrame)];
    }
}

- (void)selectionBox:(VBMultiSelectionBox *)selectionBox resizing:(NSEvent *)event resizeParams:(VBSelectionBoxResizeParams)resizeParams {
//    NSLog(@"resizing");
    BOOL lockWidthResize = false;
    BOOL lockHeightResize = false;
    
    for (NSInteger i = 0; i < self.selectedCards.count; i++) {
        __kindof VBSelectableCard * curCard = self.selectedCards[i];
        if (![curCard isKindOfClass:VBCommentCard.class]) continue;
        
        NSRect curCardStartRect = self.cardResizeStartFrames[i].rectValue;
        
        NSSize checkSize = [self offsetSize:curCardStartRect.size resizeParams:resizeParams containerSize:self.multiSelectionResizeStartRect.size];
        
        if (VBCommentCard.minSize.width > checkSize.width) lockWidthResize = true;
        if (VBCommentCard.minSize.height > checkSize.height) lockHeightResize = true;
        
        if (lockWidthResize && lockHeightResize) return;
    }
    
    for (NSInteger i = 0; i < self.selectedCards.count; i++) {
        __kindof VBSelectableCard * curCard = self.selectedCards[i];
        if (![curCard isKindOfClass:VBCommentCard.class]) continue;
        VBCommentCard * curCommentCard = curCard;
        NSRect curCardStartRect = self.cardResizeStartFrames[i].rectValue;
        NSRect newRect = [self offsetRect:curCardStartRect resizeParams:resizeParams containerRect:self.multiSelectionResizeStartRect];
        
        if (lockWidthResize) {
            newRect.origin.x = curCommentCard.layoutFrame.origin.x;
            newRect.size.width = curCommentCard.layoutFrame.size.width;
        } else if (lockHeightResize) {
            newRect.origin.y = curCommentCard.layoutFrame.origin.y;
            newRect.size.height = curCommentCard.layoutFrame.size.height;
        }
        
        [curCommentCard changeFrame:newRect];
    }
    
    NSRect newRect = [self offsetRect:self.multiSelectionResizeStartRect resizeParams:resizeParams containerRect:self.multiSelectionResizeStartRect];
    
    if (lockWidthResize) {
        newRect.origin.x = self.multiSelectionBox.selectionRect.origin.x;
        newRect.size.width = self.multiSelectionBox.selectionRect.size.width;
    } else if (lockHeightResize) {
        newRect.origin.y = self.multiSelectionBox.selectionRect.origin.y;
        newRect.size.height = self.multiSelectionBox.selectionRect.size.height;
    }
    
    [self.multiSelectionBox showSelectBoxAtRect:newRect];
}

- (void)selectionBox:(VBMultiSelectionBox *)selectionBox resizeDidFinish:(NSEvent *)event {
    [self recorrectCommentCardsFrame];
    
    [self refreshWithSelectedCards:self.selectedCards];
    
    // 通知：cards 数据有变化
    [self dataChangedWithEffectedCards:self.selectedCards type:VBCardDataChangeTypeResize];
    [self calculateTotalContentSizeWithSendChangeNotification:true];
}

- (void)selectionBox:(nonnull VBMultiSelectionBox *)selectionBox mouseDown:(nonnull NSEvent *)event {
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:selectionBox];
    BOOL isFounded = false;
    for (__kindof VBSelectableCard * curCard in self.cardsView.subviews.reverseObjectEnumerator) {
        if (NSPointInRect(point, [VBMultiSelectionBox wrappedRect:curCard.frame])) {
            isFounded = true;
            NSOperationQueue * queue = [NSOperationQueue new];
            [queue addOperationWithBlock:^{
                __kindof VBSelectableCard * oldLockedView = self.curSelectLockedCardView;
                self.curSelectLockedCardView = curCard;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self mouseEventSender:event targetView:self.curSelectLockedCardView handler:^(__kindof NSView *view) { [view mouseDown:event]; }];
                    if (oldLockedView != curCard && [oldLockedView isKindOfClass:VBCommentCard.class]) [self dataChangedWithEffectedCards:@[oldLockedView] type:VBCardDataChangeTypeCommentChange]; // <- 每次焦点切换时检测上一个焦点是否为 commentCard，如果是，则通知数据库更新其中的 rtf 内容
                }];
            }];
            break;
        }
    }
    
    if (!isFounded) {
        __kindof VBSelectableCard * oldLockedView = self.curSelectLockedCardView;
        self.curSelectLockedCardView = self;
        [self.window makeFirstResponder:self.curSelectLockedCardView];
        [self mouseEventSender:event targetView:self.curSelectLockedCardView handler:^(__kindof NSView *view) { [view mouseDown:event]; }];
        if ([oldLockedView isKindOfClass:VBCommentCard.class]) [self dataChangedWithEffectedCards:@[oldLockedView] type:VBCardDataChangeTypeCommentChange]; // <- 每次焦点切换时检测上一个焦点是否为 commentCard，如果是，则通知数据库更新其中的 rtf 内容
    }
}

- (void)selectionBox:(nonnull VBMultiSelectionBox *)selectionBox mouseDragged:(nonnull NSEvent *)event {
    [self mouseEventSender:event targetView:self.curSelectLockedCardView handler:^(__kindof NSView *view) { [view mouseDragged:event]; }];
}

- (void)selectionBox:(nonnull VBMultiSelectionBox *)selectionBox mouseUp:(nonnull NSEvent *)event {
    [self mouseEventSender:event targetView:self.curSelectLockedCardView handler:^(__kindof NSView *view) { [view mouseUp:event]; }];
}

- (void)selectionBox:(nonnull VBMultiSelectionBox *)selectionBox rightMouseDown:(NSEvent *)event {
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:selectionBox];
    
    BOOL shouldContinue = true;
    if (self.selectedCards.count > 0) {
        if (NSPointInRect(point, self.multiSelectionBox.selectionRect)) shouldContinue = false;
    }
    
    if (shouldContinue) {
        self.curSelectLockedCardView = self;
        for (__kindof VBSelectableCard * curCard in self.cardsView.subviews.reverseObjectEnumerator) {
            if (NSPointInRect(point, [VBMultiSelectionBox wrappedRect:curCard.frame])) {
                self.curSelectLockedCardView = curCard;
                [self refreshWithSelectedCards:[NSMutableArray arrayWithArray:@[self.curSelectLockedCardView]]];
                break;
            }
        }
        if (self.curSelectLockedCardView == self) [self refreshWithSelectedCards:[NSMutableArray new]];
    }
    
    [self mouseEventSender:event targetView:self.curSelectLockedCardView handler:^(__kindof NSView *view) { [view rightMouseDown:event]; }];
}

- (void)selectionBox:(nonnull VBMultiSelectionBox *)selectionBox rightMouseUp:(NSEvent *)event {
    [self mouseEventSender:event targetView:self.curSelectLockedCardView handler:^(__kindof NSView *view) { [view rightMouseUp:event]; }];
}

- (void)mouseEventSender:(NSEvent *)event targetView:(__kindof NSView *)targetView handler:(void(^)(__kindof NSView * view))handler {
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:targetView];
    
    if (targetView == self) {
        if (self.oldSelectLockedCardView != self.curSelectLockedCardView) [self.window makeFirstResponder:targetView];
        handler(targetView);
        return;
    }
    
    for (__kindof NSView * curSubView in targetView.subviews.reverseObjectEnumerator) {
        if (NSPointInRect(point, curSubView.frame)) {
            [self mouseEventSender:event targetView:curSubView handler:handler];
            return;
        }
    }
    
    if (self.oldSelectLockedCardView != self.curSelectLockedCardView) [self.window makeFirstResponder:targetView];
    handler(targetView);
}

- (void)normalMouseEventSender:(NSEvent *)event targetView:(__kindof NSView *)targetView handler:(void(^)(__kindof NSView * view))handler {
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:targetView];
    
    for (__kindof NSView * curSubView in targetView.subviews.reverseObjectEnumerator) {
        if (NSPointInRect(point, curSubView.frame)) {
            [self normalMouseEventSender:event targetView:curSubView handler:handler];
            return;
        }
    }
    
    handler(targetView);
}

- (NSRect)offsetRect:(NSRect)rect resizeParams:(VBSelectionBoxResizeParams)resizeParams containerRect:(NSRect)containerRect {
    NSSize size = [self offsetSize:rect.size resizeParams:resizeParams containerSize:containerRect.size];
    return NSMakeRect(
                      containerRect.origin.x + resizeParams.totalOriginOffset.width + (containerRect.size.width + resizeParams.totalSizeOffset.width) * ((rect.origin.x - containerRect.origin.x) / containerRect.size.width),
                      containerRect.origin.y + resizeParams.totalOriginOffset.height + (containerRect.size.height + resizeParams.totalSizeOffset.height) * ((rect.origin.y - containerRect.origin.y) / containerRect.size.height),
                      size.width, size.height
                      );
}

- (NSSize)offsetSize:(NSSize)size resizeParams:(VBSelectionBoxResizeParams)resizeParams containerSize:(NSSize)containerSize {
    return NSMakeSize(
                      size.width + resizeParams.totalSizeOffset.width * (size.width / containerSize.width),
                      size.height + resizeParams.totalSizeOffset.height * (size.height / containerSize.height)
                      );
}

@end


/*-----------------------------------------------------------------------------------------------------------*/


// 此分类处理多选框
@implementation VBWordBrowser(MultiSelectionHandler)

- (void)prepareMultiSelectionBox {
    self.multiSelectionBox = [[VBMultiSelectionBox alloc] initWithMouseEventHandler:self];
    [self addSubview:self.multiSelectionBox];
    [self makeEdgeLayoutConstraintsForView:self usingView:self.multiSelectionBox];
    
    [self prepareSelectionBoxParams];
    
    self.canDrag = NO;
}

- (void)mouseDown:(NSEvent *)event {
    // 要开始多选了
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:self];
    self.multiSelectionStartPoint = point;
    self.canDrag = YES;
}

- (void)mouseUp:(NSEvent *)event {
    // 结束多选
    [self.multiSelectionBox clearPreparationRing];
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:self];
    self.multiSelectionEndPoint = point;
    NSRect selectionRect = [self rectFromPoint1:self.multiSelectionStartPoint point2:self.multiSelectionEndPoint];
    NSArray<VBWordCard *> * curSelectedWordCards = [self.wordGroupController selectedCardsAtMultiSelectionRect:selectionRect];
    NSArray<VBCommentCard *> * curSelectedCommentCards = [self selectedCommentCardsAtMultiSelectionRect:selectionRect];
    
    NSMutableArray<__kindof VBSelectableCard *> * curSelectedCards = [NSMutableArray arrayWithArray:curSelectedWordCards];
    [curSelectedCards addObjectsFromArray:curSelectedCommentCards];
    
    if (event.modifierFlags & NSEventModifierFlagShift) {
        for (VBWordCard * curSelectedCard in curSelectedCards) {
            if ([self.selectedCards containsObject:curSelectedCard]) {
                [self.selectedCards removeObject:curSelectedCard];
                [curSelectedCard changeSelectState:NO];
            } else {
                [self.selectedCards addObject:curSelectedCard];
            }
        }
        [self refreshWithSelectedCards:self.selectedCards];
    } else {
        [self refreshWithSelectedCards:curSelectedCards];
    }
    self.canDrag = NO;
}

- (NSArray<VBCommentCard *> *)selectedCommentCardsAtMultiSelectionRect:(NSRect)rect {
    NSMutableArray<VBCommentCard *> * result = [NSMutableArray new];
    for (VBCommentCard * curCommentCard in self.commentCards) if (NSIntersectsRect(curCommentCard.frame, rect)) [result addObject:curCommentCard];
    return result;
}

- (void)mouseDragged:(NSEvent *)event {
    // 正在进行多选
    if (!self.canDrag) return;
    if (!(event.modifierFlags & NSEventModifierFlagShift)) [self.multiSelectionBox clearSelectBox];
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:self];
    self.multiSelectionEndPoint = point;
    if (!NSEqualPoints(self.multiSelectionStartPoint, self.multiSelectionEndPoint)) {
        [self.multiSelectionBox showPreparationRingAtRect:[self rectFromPoint1:self.multiSelectionStartPoint point2:self.multiSelectionEndPoint]];
    }
}

- (void)refreshWithSelectedCards:(NSMutableArray<__kindof VBSelectableCard *> *)cards {
    NSRect selectedRect = [self maxRectOfWordCards:cards];
    
    for (VBSelectableCard * curCard in self.selectedCards) [curCard changeSelectState:NO];
    for (VBWordCard * curCard in cards) [curCard changeSelectState:YES];
    
    self.selectedCards = cards;
    
    if (!NSEqualRects(selectedRect, NSZeroRect)) {
        if (!self.multiSelectionBox.superview) [self addSubview:self.multiSelectionBox];
        [self.multiSelectionBox showSelectBoxAtRect:selectedRect];
    } else {
        [self.multiSelectionBox clearSelectBox];
    }
}

// 以两点定矩形
- (NSRect)rectFromPoint1:(NSPoint)point1 point2:(NSPoint)point2 {
    CGFloat x1 = point1.x, y1 = point1.y, x2 = point2.x, y2 = point2.y;
    
    CGFloat width = fabs(x1 - x2);
    CGFloat height = fabs(y1 - y2);
    
    CGFloat x = x2 < x1 ? x2 : x1;
    CGFloat y = y2 < y1 ? y2 : y1;
    
    return NSMakeRect(x, y, width, height);
}

- (NSRect)maxRectOfWordCards:(NSArray<VBWordCard *> *)cards {
    if (cards.count < 1) return NSZeroRect;
    NSRect curRect = cards.firstObject.frame;
    
    for (VBWordCard * curCard in cards) {
        curRect = CGRectUnion(curRect, curCard.frame);
    }
    
    return curRect;
}

@end


/*-----------------------------------------------------------------------------------------------------------*/


// 此分类实现一些补充功能
@implementation VBWordBrowser(AdditionFunctions)

- (void)deleteSelectedComments {
    NSMutableArray<VBComment *> * commentsShouldDelete = [NSMutableArray new];
    for (VBCommentCard * curCommentCard in self.selectedCommentCards) {
        [curCommentCard removeFromSuperview];
        [self.selectedCards removeObject:curCommentCard];
        [self.commentCards removeObject:curCommentCard];
        [commentsShouldDelete addObject:curCommentCard.comment];
    }
    [self refreshWithSelectedCards:self.selectedCards];
    
    // 通知：有更改
    [self deleteCommentsFromDatabase:commentsShouldDelete];
    [self calculateTotalContentSizeWithSendChangeNotification:true];
}

- (void)selectAll {
    self.selectedCards = [NSMutableArray arrayWithArray:self.wordGroupController.allcards];
    [self.selectedCards addObjectsFromArray:self.commentCards];
    [self refreshWithSelectedCards:self.selectedCards];
}

- (BOOL)undo {
    if (![self.dataUndomanager canUndo]) { NSBeep(); return false; }
    [self.dataUndomanager Undo];
    [self refreshWithVerseRef:self.verseRef];
    return true;
}

- (BOOL)redo {
    if (![self.dataUndomanager canRedo]) { NSBeep(); return false; }
    [self.dataUndomanager Redo];
    [self refreshWithVerseRef:self.verseRef];
    return true;
}

@end



/*-----------------------------------------------------------------------------------------------------------*/



@implementation VBWordBrowser(RightClickMenu)

- (void)prepareMenu {
    for (NSMenuItem * curItem in self.rightMenu.itemArray) {
        curItem.target = self;
        curItem.enabled = true;
        
        if ([curItem.identifier isEqualToString:@"SelectAll"])              curItem.action = @selector(selectAll);
        else if ([curItem.identifier isEqualToString:@"AddComment"])        curItem.action = @selector(addComment);
        else if ([curItem.identifier isEqualToString:@"DeleteComment"])     curItem.action = @selector(deleteSelectedComments);
        else if ([curItem.identifier isEqualToString:@"Undo"])              curItem.action = @selector(undo);
        else if ([curItem.identifier isEqualToString:@"Redo"])              curItem.action = @selector(redo);
    }
}

// 呼出右键菜单
- (void)rightMouseUp:(NSEvent *)event {
    [self.rightMenu popUpMenuPositioningItem:nil atLocation:[self.window.contentView convertPoint:event.locationInWindow toView:self] inView:self];
}

@end


/*-----------------------------------------------------------------------------------------------------------*/


#import "ANSI Keys.h"

// 快捷键绑定
@implementation VBWordBrowser(KeyboardMonitor)

- (void)keyDown:(NSEvent *)event {
    
    if (event.modifierFlags == 256)
        switch (event.keyCode) {
            case KEY_DELETE: [self deleteSelectedComments]; break;                                      // delete
            default: [super keyDown:event];
        }
    else {
        int key = event.keyCode;
        BOOL command = (event.modifierFlags & NSEventModifierFlagCommand) != 0;
        BOOL shift = (event.modifierFlags & NSEventModifierFlagShift) != 0;
        BOOL option = (event.modifierFlags & NSEventModifierFlagOption) != 0;
        BOOL control = (event.modifierFlags & NSEventModifierFlagControl) != 0;
        
        if (command && key == KEY_EQUALS && !option && !control && !shift)      [self addComment];                              // <- command + =
        else if (command && key == KEY_A && !option && !control && !shift)      [self selectAll];                               // <- command + a
        else if (command && key == KEY_Z && !option && !control && !shift)      [self undo];                                    // <- command + z
        else if (command && shift && key == KEY_Z && !option && !control)       [self redo];                                    // <- command + shift + z
        else [super keyDown:event];
    }
}

@end


/*-----------------------------------------------------------------------------------------------------------*/


@interface VBWordBrowser(GraphicPositionDelegate)<VBGraphicPositionDelegate> @end

@implementation VBWordBrowser(DataWrapper)

- (void)fetchCardsFromDatabase {
    [self.wordGroupController clearAllGroups];
    [self.wordGroupController remakeWithWords:[self wordsFromDatabase] cardDelegate:self];
}

- (void)fetchCommentsFromDatabase {
    [self.commentCards removeAllObjects];
    NSArray<VBComment *> * comments = [self commentsFromDatabase];
    
    for (VBComment * curComment in comments) {
        VBCommentCard * curCommentCard = [self newCommentCardWithComment:curComment];
        [self.commentCards addObject:curCommentCard];
    }
    
}

- (VBCommentCard *)newCommentCardWithComment:(VBComment *)comment {
    VBCommentCard * curCommentCard = [[VBCommentCard alloc] initWithComment:comment layoutDelegate:self] ;
    [curCommentCard changeSize:comment.size];
    [curCommentCard changeOrigin:comment.linerPoint];
    return curCommentCard;
}

- (void)dataChangedWithEffectedCards:(NSArray<__kindof VBSelectableCard *> *)effectedCards type:(VBCardDataChangeType)type {
    CDDatabaseUndoAtomic * undoAtomic = [[CDDatabaseUndoAtomic alloc] initWithUndomanger:self.dataUndomanager];
    
    BOOL isModified = false;
    for (__kindof VBSelectableCard * curCard in effectedCards) {
        if ([curCard isKindOfClass:VBWordCard.class]) {
            VBWord * curWord = ((VBWordCard *)curCard).word;
            if (curWord.isModified) { [self updateWordAtDatabase:curWord type:type undoAtomic:undoAtomic]; isModified = true; }
        } else {
            VBComment * curComment = ((VBCommentCard *)curCard).comment;
            if (curComment.isModified) { [self updateCommentAtDatabase:curComment type:type undoAtomic:undoAtomic]; isModified = true; };
        }
    }
    
    if (isModified) [self addDoItToUndoManagerWithUndoAtomic:undoAtomic];
}

@end


/*-----------------------------------------------------------------------------------------------------------*/


@implementation VBWordBrowser(ContentSize)

- (void)prepareContentSize {
    self.contentSizeBorderLayer = [CALayer new];
    
    self.contentSizeBorderLayer.borderColor = NSColor.systemGreenColor.CGColor;
    self.contentSizeBorderLayer.borderWidth = 2;
    self.contentSizeBorderLayer.cornerRadius = 5;
    
    self.realContentSizeBorderLayer = [CALayer new];
    
    self.realContentSizeBorderLayer.borderColor = NSColor.systemBlueColor.CGColor;
    self.realContentSizeBorderLayer.borderWidth = 2;
    self.realContentSizeBorderLayer.cornerRadius = 5;
    
    self.contentSizeBorderLayer.frame = NSZeroRect;
    self.realContentSizeBorderLayer.frame = NSZeroRect;
    self.cardsView.wantsLayer = true;
    [self.cardsView.layer addSublayer:self.contentSizeBorderLayer];
    [self.cardsView.layer addSublayer:self.realContentSizeBorderLayer];
}

- (BOOL)recorrectCommentCardsFrame {
    BOOL isRecorrected = false;
    for (VBCommentCard * curCommentCard in self.commentCards) {
        if (curCommentCard.layoutFrame.origin.x < VB_SPACING_OVERAGE || curCommentCard.layoutFrame.origin.y < VB_SPACING_OVERAGE) {
            isRecorrected = true;
            [curCommentCard changeOrigin:NSMakePoint(curCommentCard.layoutFrame.origin.x < VB_SPACING_OVERAGE ? VB_SPACING_OVERAGE : curCommentCard.layoutFrame.origin.x, curCommentCard.layoutFrame.origin.y < VB_SPACING_OVERAGE ? VB_SPACING_OVERAGE : curCommentCard.layoutFrame.origin.y)];
        }
    }
    return isRecorrected;
}

- (void)calculateTotalContentSizeWithSendChangeNotification:(BOOL)sendChangeNotification{
    
    NSSize oldSize = self.contentSize;
    self.contentSize = NSZeroSize;
    for (__kindof VBSelectableCard * curCard in self.cardsView.subviews) {
        [self appendContentSizeWithRect:curCard.layoutFrame sendChangeNotification:false];
    }
    self.contentSize = NSMakeSize(self.contentSize.width < self.minSize.width ? self.minSize.width : self.contentSize.width, self.contentSize.height < self.minSize.height ? self.minSize.height : self.contentSize.height);
    if (!NSEqualSizes(oldSize, self.contentSize) && sendChangeNotification) [self contentSizeChanged];
}

- (BOOL)appendContentSizeWithRect:(NSRect)rect sendChangeNotification:(BOOL)sendChangeNotification {
    CGFloat width = rect.origin.x + rect.size.width;
    CGFloat height = rect.origin.y + rect.size.height;
    
    if (width <= self.contentSize.width && height <= self.contentSize.height) return false;
    
    self.contentSize = NSMakeSize(width > self.contentSize.width ? width : self.contentSize.width , height > self.contentSize.height ? height : self.contentSize.height);
    if (sendChangeNotification) [self contentSizeChanged];
    
    return true;
}

- (void)contentSizeChanged {
    NSSize size = NSMakeSize(self.contentSize.width + self.widthOverage, self.contentSize.height + self.heightOverage);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.contentSizeBorderLayer.frame = NSMakeRect(0, 0, size.width, size.height);
    self.realContentSizeBorderLayer.frame = NSMakeRect(0, 0, self.contentSize.width, self.contentSize.height);
    [CATransaction commit];
    
    NSLog(@"Size Changed: %@", NSStringFromSize(size));
    
}

@end
