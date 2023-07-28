//
//  CDSQLite3TableView.h
//  BibleOriginWordMap
//
//  Created by 唐道延s on 13-6-6.
//  Copyright (c) 2013年 唐道延s. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "CDSqlite3TableView.h"

@class CDSqlite3TableView;


typedef NS_ENUM(int, CDMouseStute) {
    CDMouseDoubleMybe   =1,
    CDMouseDoubleClicked=2,
    CDMousesingleClicked=3,
    CDMouseDown=4,
    CDmouseTimerStart=5,
    CDmouseTimerEnd=6,
    CDMouseCancel=0,
};
@protocol CDSqlite3TableViewDataSource <NSTableViewDataSource>
@required
-(void)LeftLighterClickedInTableView:(CDSqlite3TableView*)aTableView
                               onRow:(NSInteger)rowIndex
                       onTableColumn:(NSTableColumn *)aTableColumn;

-(void)LeftDeeperClickedInTableView:(CDSqlite3TableView*)aTableView
                              onRow:(NSInteger)rowIndex
                      onTableColumn:(NSTableColumn *)aTableColumn;

-(void)RightDeeperClickedInTableView:(CDSqlite3TableView*)aTableView
                               onRow:(NSInteger)rowIndex
                       onTableColumn:(NSTableColumn *)aTableColumn;

-(void)RightLighterClickedInTableView:(CDSqlite3TableView*)aTableView
                                onRow:(NSInteger)rowIndex
                        onTableColumn:(NSTableColumn *)aTableColumn;

-(NSInteger)numberOfColumnsInTableView:(NSTableView *)aTableView;

-(NSArray *)nameOfColumnInTableView:(NSTableView *)aTableView
                    numberOfColumns:(NSInteger)Columns;

-(NSArray *)WidthofColumnsInTableView:(NSTableView *)aTableView
                      numberOfColumns:(NSInteger)Columns;

@end



@interface CDSqlite3TableView : NSTableView
//-(void)setnameOfColumns:(NSArray *)names;
//-(void)SetNumberOfTableColumns:(NSInteger)Columns;
{
    @protected
    NSEvent * _LeftMouseDownEvent;
    NSEvent * _RightMouseDownEvent;
    CDMouseStute _mousestute;
    NSTimer * _timerForMouseClick;
};
@end
