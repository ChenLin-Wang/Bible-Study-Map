//
//  CDField.h
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/20.
//  PRAGMA table_info (a000) for SQLite 3

/*
 _DAY
 
 
 
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(char, CDFieldType) //字段的值在内存中的表示类型。
{
    CDFieldisNULL   = 0,
    CDFieldisNumberInteger =1,
    CDFieldisNumberReal =2,
    CDFieldisBoolean = 3,
    
    CDFieldisDate   =10,
    CDFieldisString =11,
    
    CDFieldisAttributedString=14,//字段名字_AttriS
    CDFieldisAudio  =15, //字段名字_Audio
    CDFieldisMovie  =16, //字段名字_Movie
    CDFieldisImage  =17, //字段名字_Image
    CDFieldisSketch =18, //字段名字_Sketch
    CDFieldisUnkonwType =127
    
};
typedef NS_ENUM(int, quotertype) //字段的值在内存中的表示类型。
{
    CDQuoterNothing         = 0, //不做什么。
    CDSingleQuoterTakeoff   =1,//去掉两头的单引号；并且恢复里面转移的单引号和双引号；
    CDSingleQuoterMakeOn    =2,//两头加上单引号；并且转移里面的单引号和双引号；
  //  CDSingleQuoterTrans     =3,//仅仅转移其中的单引号。从转移到回复；
    CDDoubleQuoterTakeoff   =4,//去掉两头的双引号；并且恢复里面转移的双引号；
    CDDoubleQuoterMakeOn    =5,//两头加上双引号；并且转移里面的双引号；
   // CDDoubleQuoterTrans   =6,//仅仅转移其中的双引号。从转移到回复；
    

    中文表示也可以吗  =9,
};


@interface CDField : NSObject
{
    BOOL _isEditable;//default=NO;
}
@property (nonatomic) NSString *TableName;//=nil 表示可用于任何数据表格，否则为指定表格。
@property (nonatomic) NSString *FieldName;//=字段正常名字_类型名称。不可有两个下划线。
@property (nonatomic) CDFieldType FieldType;
@property (nonatomic) BOOL isPrimaryKey;
//for display 用户可以
//@property NSRect EditorBoxPosition;
//@property NSRect LebelPosition;
//@property NSString *LebelText;

-(CDFieldType)readTypeFromFieldname;
-(void)reverse_Editable;
-(id)objectFromData:(NSData *)aData;
-(NSData*)DataWithanObject:(id)anObjec;
-(CDFieldType)TypeOfanObject:(id)anObject;
-(NSString *)stringOfFiledType;
-(BOOL)isTheObject:(id)anObject EqualtoObject:(id)otherObject;
-(id)defaultValueAccordingType;
-(id)StringValueAccordtype:(id)anobjecter withQuoter:(quotertype)quoterLike;
-(BOOL)isSame:(CDField*)afield;
@end

NS_ASSUME_NONNULL_END
