//
//  CDRecord.h
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/20.
//

#import <Foundation/Foundation.h>
#import "CDField.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(int, CDIDUaction) //字段的值在内存中的表示类型。
{
    CDIDU_doNothing  =0,
    CDIDU_doInsert   =1,
    CDIDU_doDelete   =2,
    CDIDU_doUpdate   =3,
};
typedef NS_ENUM(int, CDdataOperaterError) //字段的值在内存中的表示类型。
{
    CDIDU_sucsess =0,
    CDIDU_dataOperaterTimeout=1,
    CDIDU_NoSuchIP=2,
    CDIDU_CanotOpenThebase=3,
    CDIDU_NoSuchTable=4,
    CDIDU_NoSuchField=5,
    CDIDU_NoSuchrecord=6,
    CDIDU_NoSuchKey=7,
    CDIDU_NoSuchPath=8,
    CDIDU_BadCDRecord=9,
    CDIDU_BadSQLStatement=10,
    CDIDU_BadKeyField=11,
    CDIDU_BadFields=12,
    CDIDU_BadTableName=13,
    
    CDIDU_WaitForEditorAnswer=100,
   
    
    CDIDU_DatabaseOperaterisnil=900,
    CDIDU_OtherReasontoFail=999
};
@class CDRecord;
@class CDSelectRecords;
@protocol DatabaseOperaterDelegate <NSObject>
@required
-(CDdataOperaterError)connectDataBasewithAddress:(NSString*)address
                                    withDatabase:(NSString*)aDatabase
                                          byUser:(NSString*)user
                                     andPassword:(NSString*)PassW;
-(NSArray<NSString*>*)listTablesName;
-(NSArray<CDField *>*)listFiledsByTableName:(NSString *)Tablename;
-(CDdataOperaterError)copyTableToName:(NSString*)newTableName
                             WithData:(BOOL)isWithData
                         FromDatabase:(id<DatabaseOperaterDelegate>)anotherDatabase
                        withTablename:(NSString*)oldTableName;

-(CDRecord*)findaRecordwithFileds:(NSArray<CDField *> *)aStruture
                        fromTable:(NSString *)tablename
                          whereas:(NSString *)keyValue;//需要 keValue

-(CDSelectRecords*)selectRecordswithFileds:(NSArray<CDField *> *)aStruture
                        fromTable:(NSString *)tablename
                          whereas:(NSString *)condition;//需要

- (CDSelectRecords*)selectRecordsWithField:(NSArray<CDField *> *)aStructre
                              sqlStatement:(NSString *)sqlStatement;

- (BOOL)AppendDatafromBaseToThisSelectRecords:(nonnull CDSelectRecords*)TheSelectRecord
                                            //被追加的纪录，不可改变其字段结构，和数据表名录。
                                withKeyValue:(NSArray<NSString*>*)keyValues;//所要增加的纪录关键值
        

@end

@protocol DatabaseIDUDelegate <NSObject>
@required
-(CDRecord *)DoIDUaRecord:( nonnull CDRecord *)aRecord; //  (将反操作，直接记录在原来的CDRecord中，下同) 如果aRecord有错误，就在aRecord.error中标注。
@end
@interface CDRecord : NSObject
{

}
@property (nonatomic) id<DatabaseIDUDelegate> DatabaseOperater;
@property (nonatomic)  NSString *TableName;
@property (nonatomic) NSArray <CDField*>* TableStructure;//这第一个必须是一个关键字段
@property (nonatomic) NSArray <id>* Values;//顺序与TableStructure保持一致。且！=nil。
@property (nonatomic) CDIDUaction doAction;//=内存驻留/insert/delete/Update
@property (nonatomic) NSString *error;//nil 表示没有错误。否则就是错误原因。
//-(void)turnUndoAction;
-(CDRecord *)saveToDatabaseWithUndo;
-(CDRecord*)copy;
-(NSString *)getWhereAs;
-(CDField *)KeyField;
-(NSString *)KeyValue;

@end

NS_ASSUME_NONNULL_END
