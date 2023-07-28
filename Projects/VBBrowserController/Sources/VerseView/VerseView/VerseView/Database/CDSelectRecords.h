//
//  CDSelectRecords.h
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/21.
//
/*
 这个模块，提供了一批记录记录。实际有意义的只有两个部分，记录和对应的字段。
 目前只有用来为显示提供数据

 本模块支持多数据表题去数据的能力。
 其次，Whereas 和 error,也不是必须的。
 当error==nil表明内容是有意义的。
 */
#import <Foundation/Foundation.h>
#import "CDRecord.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(int, CDTypeofThisGroup) {
    CDForSearch   =1,
    CDstrongNumberForCompare=2,
    CDcustemNumberForCompare=3,
    CDothersNumberForCompare=4,
    CDErrorNumberForCompare=0,
};
//Select 负责显示和检索。
@interface CDSelectRecords : NSObject
@property (nonatomic) id<DatabaseOperaterDelegate> DatabaseOperater;
//@property (nonatomic) NSArray <NSString* >* TableNumes;//所需的数据所在的表格。若有相同的字段名，以排在前面的的表格的数据为准。
@property (nonatomic) NSArray <CDField*>* TableStructure;//这第一个必须是一个关键字段

//调用时必须保证 所有的CDFiled是正确存在于所列的tableNames中的。
//本模块将认为关键字段是在本selectRecord中的，并且与第一个CDField对应。
//如果第一个tablename中没有发现就会在第二个中寻找。
@property (nonatomic) NSMutableArray <NSArray <id>* >* Records;//顺序与TableStructure保持一致。每一个子数组都是一个记录。
@property (nonatomic) NSString *error;//nil 表示没有错误。否则就是错误原因。
@property (nonatomic) CDTypeofThisGroup typeOfThisGroup;
@property (nonatomic) NSString* CompareNumber;//this including strongnumbers for compare.Cdnumbers sence 16384.如果为@“”，表示这是一个临时搭建群。如果要保存 这个群需要安排一个新的custemnumberForCompare。

-(NSInteger)numberOfRows;
-(id)ValueAtRow:(NSUInteger) Row withFieldName:(NSString*)FieldName;
-(BOOL)deleteRecordsFromWithKeyValue:(NSArray <NSString *>*)TheKeys;
-(BOOL)IntersectionWithBKeyValue:(NSArray <NSString *>*)TheKeys;//改变自身成为交集
-(void)AddRecordsIntoWithSelectRecords:(CDSelectRecords*)aselectRecords;//具有相同的字段结构
-(BOOL)AppendDatafromBaseToMeWithKeyValue:(NSArray<NSString*>*)keyValues;//原有的纪录结构不变数据保持不变，只在最后追加。
-(void)ExtentMeWithFields:(NSArray <CDField*>*)newTableStructure;
    //首先将要扩展的字段添加进去，也可以删除一些不再需要的字段。但必须保留关键字段。
    //该模块将只保留关键字段的值，并作为提取数据的依据。不增加记录条数。
-(CDSelectRecords*)CopyMe;
//-(CDField *)KeyField;
//-(NSString *)KeyValueAtRow:(NSUInteger)Row;

@end

NS_ASSUME_NONNULL_END
