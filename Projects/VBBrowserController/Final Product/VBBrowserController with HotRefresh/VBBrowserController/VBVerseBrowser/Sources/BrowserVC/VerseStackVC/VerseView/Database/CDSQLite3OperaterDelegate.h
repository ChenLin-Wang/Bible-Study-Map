//
//  CDSQLite3OperaterDeLegate.h
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/26.
// 本模块负责和数据库打交道。
// 本模块实现三个基本协议：
// CDEditorListForDataDelegate，参数编辑器协议。
// DatabaseOperaterDelegate 本协议必须实现的功能函数。
// DatabaseIDUDelegate CDRecord和CDDatabaseUndoAtomic专用协议。
// 该协议只有一个带有Undo功能的-(CDdataOperaterError)DoIDUaRecord:(CDRecord *)aRecord;
// 按照CDRecord的要求，操作之后，将CDRecord的改变为你操作的CDRecord。
// 若用户希望扩展其他数据库，简单地拷贝本模块并且修改。或者直接重写。不要继承本类，因为本垒是专为SQLite3而写的。


#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "CDEditorForWhereas_connect.h"
#import "CDRecord.h"
#import "CDSelectRecords.h"
#import "CDField.h"
#import "CDDatabaseUndoAtomic.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDSQLite3OperaterDelegate : NSObject<CDEditorListForDataDelegate,DatabaseOperaterDelegate,DatabaseIDUDelegate>
{
   @private
    sqlite3 *dataBase;
    sqlite3_stmt *statement;
    const char *errorMsg;
    NSString *_MyFolder;
    NSString *_MyDatabase;
    //NSString *_pathforAddress;//
}

@property CDEditorForWhereas_connect * MyEditor;
-(void)saveLinerToBibleScopeMap:(NSUInteger)Liner withBPVnum:(NSUInteger)BPVW;
-(NSUInteger)LinerByBPVW:(NSUInteger)aBPVWnum;
-(NSUInteger)BpvwnumByLiner:(NSUInteger)aLiner;

- (NSURL *)databaseAddress;

//-(void)ShowEditor;//仅仅用于调试。

@end

NS_ASSUME_NONNULL_END
