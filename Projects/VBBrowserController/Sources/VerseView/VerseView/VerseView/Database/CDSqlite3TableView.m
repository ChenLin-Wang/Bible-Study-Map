//
//  CDSQLite3TableView.m
//  BibleOriginWordMap
//
//  Created by 唐道延s on 13-6-6.
//  Copyright (c) 2013年 唐道延s. All rights reserved.
//  In this class the first Column will should not be moved to other position..
//  该模块 提供了可以动态调整列。

#import "CDSqlite3TableView.h"

@implementation CDSqlite3TableView

- (id)initWithCoder:(NSCoder *)decoder {
    self=[super initWithCoder:decoder];
    if (self) {
        _mousestute=CDMouseCancel;
    };
    return self;
}

-(void)setDataSource:(id<NSTableViewDataSource,CDSqlite3TableViewDataSource>)adataSource{
    [self sendSetColumnMessageToDataSource:adataSource];
    [super setDataSource:adataSource];
};

-(void)sendSetColumnMessageToDataSource:(id < CDSqlite3TableViewDataSource>)aDataSource{
    
    NSInteger c=[aDataSource numberOfColumnsInTableView:self];
    if (c>0){
        [self SetNumberOfTableColumns:c];
        NSArray *Widths=[aDataSource WidthofColumnsInTableView:self numberOfColumns:[self numberOfColumns]];
        [self setnameOfColumns:[aDataSource nameOfColumnInTableView:self numberOfColumns:[self numberOfColumns]] withColumnwidth:Widths];
    }
};

- (void)reloadData{
    [self sendSetColumnMessageToDataSource:(id < CDSqlite3TableViewDataSource>)[self dataSource]];
    [super reloadData];
    return;
};

-(void)setnameOfColumns:(NSArray *)names withColumnwidth:(NSArray *)widths {
    NSInteger b=[names count];
    NSInteger W;
    if (widths==nil) {W=0;} else W=[widths count];
    if (b>[self numberOfColumns]) b=[self numberOfColumns];
    for (NSInteger i=0;i<b;i++)
    {
        NSTableColumn *T=[[self tableColumns] objectAtIndex:i];
        [T setIdentifier:[names objectAtIndex:i]];
        [[T  headerCell] setStringValue:[names objectAtIndex:i]];
        if (i<W) [T setWidth:[[widths objectAtIndex:i]integerValue]];//set default Width of column
    };
};


//adjust TableColumns to Numbers. It best call when this class called in dataSource with numberofRowsIntableview
-(void)SetNumberOfTableColumns:(NSInteger)Columns{
    if ([self numberOfColumns]==Columns ) return ;
    if ([self numberOfColumns]<Columns )//添加
    {
        for (NSInteger i=[self numberOfColumns];i<Columns;i++)
        {
            [self addTableColumn:[NSTableColumn new]];
        };
    }
    else//减少
    {
        for (NSInteger i=[self numberOfColumns];i>Columns;i--)
            [self removeTableColumn:[[self tableColumns] objectAtIndex:0]];
    };
};
//In this class the first Column will should not be moved to other position. so here,does not allows to let first columntable move any position else.
- (void)moveColumn:(NSInteger)columnIndex toColumn:(NSInteger)newIndex{
    if (columnIndex==0) return;
    [super moveColumn:columnIndex toColumn:newIndex];
};

//采用前后两个事件的关联关系，能够设定第二事件的变化，但不能够决定第一事件。因此我们应当抛弃单击和双击的操作概念。而是用浅击和深按座位操作概念。对饮的计算是 timeUp-timeDown >2秒 =深按。 <0.5 =浅击。
-(void)timerClicked{
    if (_mousestute==CDmouseTimerStart){
        _mousestute=CDmouseTimerEnd;
//        NSLog(@"timer clicked!");
        [self DoLeftClicked:_LeftMouseDownEvent isDeeper:YES];
//        NSLog(@"double 深度 on timer");
    };
    [_timerForMouseClick invalidate];
    _timerForMouseClick = nil;
};

-(void)mouseUp:(NSEvent *)theEvent{
//    NSLog(@"Left Up");
    //  [super mouseDown: _LeftMouseDownEvent];
    if (_mousestute==CDmouseTimerStart){
        _mousestute=CDmouseTimerEnd;
        if (theEvent.timestamp- _LeftMouseDownEvent.timestamp>=0.85) {
            [self DoLeftClicked:theEvent isDeeper:YES];
//            NSLog(@"double 深度");
        } else{
            [self DoLeftClicked:theEvent isDeeper:NO];
//            NSLog(@"single 浅击");
        };
    }
    _mousestute=CDmouseTimerEnd;
    // [super mouseUp:theEvent];
};
- (void)mouseDown:(NSEvent *)theEvent{
    _LeftMouseDownEvent=theEvent;
    
    //    if (theEvent.clickCount>1) {
    //        [self DoLeftClicked:theEvent isDeeper:YES];
    //        NSLog(@"double 深度 mouse down");
    //        _mousestute=CDmouseTimerEnd;
    //        return;//保留双击的概念
    //    }
//    NSLog(@"Left Down");
    _mousestute=CDmouseTimerStart;
    _timerForMouseClick=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerClicked) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timerForMouseClick forMode:NSRunLoopCommonModes];
};

-(void)DoLeftClicked:(NSEvent *)theEvent isDeeper:(BOOL)isDeeper{
    // Get the row and column on which the user clicked
    NSPoint localPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    NSInteger row = [self rowAtPoint:localPoint];
//    NSLog(@"%ld",(long)row);
    NSInteger column=[self columnAtPoint:localPoint];
    if (column<0) column=[[self tableColumns] count]-1;
    // If the user didn't click on a row of column , we're done
    
    if (row > -1)
    {
        if (!isDeeper) {
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            [self scrollRowToVisible:row];
        }
        // NSLog(@"%@ at row %ld column %ld",[[[[self tableColumns] objectAtIndex:column] dataCellForRow:row] stringValue]  ,row  ,column);
        if (isDeeper) {
            [ (id < CDSqlite3TableViewDataSource>)[self dataSource]  LeftDeeperClickedInTableView:self onRow:row onTableColumn:[[self tableColumns] objectAtIndex:column]];
        } else {
            [ (id < CDSqlite3TableViewDataSource>)[self dataSource]  LeftLighterClickedInTableView:self onRow:row onTableColumn:[[self tableColumns] objectAtIndex:column]];
        };
        
        //redisplay it.
        
        [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:column]];
    };
    
};

-(void)rightMouseUp:(NSEvent *)theEvent{
    
    if (theEvent.timestamp-_RightMouseDownEvent.timestamp>=0.85) {
        [self DoRightClicked:_RightMouseDownEvent isDeeper:YES];
//        NSLog(@"right double 深度");
    } else{
        [self DoRightClicked:_RightMouseDownEvent isDeeper:NO];
//        NSLog(@"right single 浅击");
    };
    [super rightMouseUp:theEvent];
};
- (void)rightMouseDown:(NSEvent *)theEvent {
    
    [super rightMouseDown:theEvent];
    _RightMouseDownEvent=theEvent;
};
- (void)DoRightClicked:(NSEvent *)theEvent isDeeper:(BOOL)isDeeper{
    
    // Get the row and column on which the user clicked
    NSPoint localPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    NSInteger row = [self rowAtPoint:localPoint];
    NSInteger column=[self columnAtPoint:localPoint];
    // If the user didn't click on a row of column , we're done
    if (row > -1)
    {
        if (isDeeper) {
            // NSLog(@"%@ at row %ld column %ld",[[[[self tableColumns] objectAtIndex:column] dataCellForRow:row] stringValue]  ,row  ,column);
            [(id < CDSqlite3TableViewDataSource>)[self dataSource] RightDeeperClickedInTableView:self onRow:row onTableColumn:[[self tableColumns] objectAtIndex:column]];
            //NSLog(@"RightClicked!%ldRow %ldColumn ",row,column);
            
        } else {
            [ (id < CDSqlite3TableViewDataSource>)[self dataSource]  RightLighterClickedInTableView:self onRow:row onTableColumn:[[self tableColumns] objectAtIndex:column]];
        };
        
    };
    
};

@end
