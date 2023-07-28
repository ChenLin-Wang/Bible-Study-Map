//
//  CDSelectRecords.m
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/21.
//

#import "CDSelectRecords.h"

@implementation CDSelectRecords
-(id)init{
    self =[super init];
    if (self) {
        _Records=[NSMutableArray new];
        _error=nil;
    };
    
    return self;
};

-(CDSelectRecords*)CopyMe{
    CDSelectRecords * newSelectRecords=[CDSelectRecords new];

    newSelectRecords.DatabaseOperater=_DatabaseOperater;
    newSelectRecords.TableStructure=[NSArray arrayWithArray: _TableStructure];
    newSelectRecords.Records=[NSMutableArray arrayWithArray: _Records];;
    newSelectRecords.typeOfThisGroup=_typeOfThisGroup;
    newSelectRecords.CompareNumber=_CompareNumber;
    newSelectRecords.error=_error;
    return newSelectRecords;
};

-(NSInteger)numberOfRows{
    return _Records.count;
};
-(id)ValueAtRow:(NSUInteger) Row withFieldName:(NSString*)FieldName{
    if (Row>=_Records.count) return nil;
    NSUInteger column=[self numberOfField:FieldName];
    if (column==NSNotFound) return  nil;
    return [[_Records objectAtIndex:Row] objectAtIndex:column];
};

-(NSInteger)numberOfField:(NSString*)FieldName{
    for (NSUInteger i=0;i<_TableStructure.count;i++){
        if ([[_TableStructure objectAtIndex:i].FieldName isEqual:FieldName])
            return i;
    }
    return NSNotFound;
};

-(BOOL)deleteRecordsFromWithKeyValue:(NSArray<NSString *> *)TheKeys{
    BOOL isChanged = NO;
    if (_Records==nil|_Records.count==0)
        return isChanged ;//因为记录为空，没有可减除的。
    
    if (TheKeys==nil|TheKeys.count==0)
        return isChanged;//因为关键值为空，没有要减除的。
    
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[self takeDuplicateAway:TheKeys]];
    for (NSString *key in keys) {
        for (int i = (int)_Records.count-1; i>=0; i--) {
            if ([[self getStringValue:[[_Records objectAtIndex:i] firstObject]] isEqualToString:key]){
                [self.Records removeObjectAtIndex:i];
                isChanged = YES;
                break;
            }
        }
    }
    return isChanged;
};

-(NSString *)getStringValue:(id)obj{
    if ([[obj className] isEqualToString:@"NSString"])
        return obj;
    return [NSString stringWithFormat:@"%@", obj];
};

/// 剔除重复的关键值
/// @param TheKeys 查询数据库时用的关键值
-(NSArray<NSString *>*)takeDuplicateAway:(NSArray<NSString *> *)TheKeys{
    if (TheKeys ==nil|TheKeys.count<2)
        return TheKeys;
    
    NSMutableArray *Mkeys = [NSMutableArray new];
    for (NSString *key in TheKeys) {
        if (![Mkeys containsObject:key]) {
            [Mkeys addObject:[self getStringValue:key]];
        }
    }
    return Mkeys;
};

-(BOOL)IntersectionWithBKeyValue:(NSArray <NSString *> *)TheKeys {
    if (nil==_Records|0==_Records.count)
        return NO; //因为记录为空, 没有可提取的。
    
    if (nil==TheKeys|0==TheKeys.count)
        return NO; //因为记录为空, 没有可提取的。
    
    TheKeys = [self takeDuplicateAway:TheKeys];
    NSMutableArray<NSArray<id> *> *newRecords = [NSMutableArray new];
    
    for (NSString *key in TheKeys) {
        for (NSArray *record in _Records) {
            if ([[self getStringValue:record[0]] isEqualToString:key]) {
                [newRecords addObject:record];
                break;
            }
        }
    }
    
    if (newRecords.count > 0) {
        _Records = newRecords;
        return YES;
    }
    
    return NO;//因为交集为空。
};

-(void)AddRecordsIntoWithSelectRecords:(CDSelectRecords*)aselectRecords{
    if (_Records==nil)
        _Records=[NSMutableArray new];
    
    if (aselectRecords.Records==nil)
        return;
    
    if (![self hasSameFieldswithTheSelectRecords:aselectRecords])
        return;
    
    [_Records addObjectsFromArray:aselectRecords.Records];
    return ;
};

-(BOOL)hasSameFieldswithTheSelectRecords:(CDSelectRecords*)aselectRecords{
    if ([aselectRecords TableStructure].count!=_TableStructure.count) return NO;
    for (NSUInteger i=0;i<_TableStructure.count;i++)
        if(![[aselectRecords.TableStructure objectAtIndex:i] isSame:[_TableStructure objectAtIndex:i]]) return NO;
    return YES;
};

-(BOOL)AppendDatafromBaseToMeWithKeyValue:(NSArray<NSString*>*)keyValues {
    //如果已经存在关键字, 就不作什么.
    if (keyValues==nil|keyValues.count==0)
        return NO;
    
    // 将重复的 关键值 剔除掉
    NSMutableArray * MkeyValues = [NSMutableArray arrayWithArray:[self takeDuplicateAway:keyValues]];
    
    // 通过过滤过的 key Values 过滤已存在的数据.
    if (nil == _Records) {
        _Records = [NSMutableArray array];
    }
//    NSString * K;
    if (_Records.count != 0) {
        for (NSArray *record in _Records) {
            for (NSString *key in MkeyValues) {
                if ([[self getStringValue:record[0]] isEqualToString:key]) {
                    [MkeyValues removeObject:key];
                    break;
                }
            }
        }
    }
    
    if (0 == MkeyValues.count)
        return NO; //表明已经都在其中。
    
    if (_DatabaseOperater==nil)
        [NSException raise:@"CDSelectRecords" format:@"DatabaseOperater 没有设置！"];
    
    // 将不存在的数据从数据库中查出来追加到自己的集合内.
    return [_DatabaseOperater AppendDatafromBaseToThisSelectRecords:self withKeyValue:MkeyValues];
};//原有的纪录结构不变数据保持不变，只在最后追加。

-(void)ExtentMeWithFields:(NSArray <CDField*>*)newTableStructure{
    //本模块只保留关键字段的值，也就是第一个CDField。其他的值都重新从数据库中提取。
    if (_Records==nil|_Records.count==0) return;
    NSMutableArray *keyV=[NSMutableArray new];
    CDField *F=[_TableStructure firstObject];
    for (NSArray *aRecord in _Records) {
        [keyV addObject:[F StringValueAccordtype:[aRecord firstObject] withQuoter:CDDoubleQuoterMakeOn]];
    };
    _TableStructure=newTableStructure;
    [_Records removeAllObjects];
    [self AppendDatafromBaseToMeWithKeyValue:keyV];
    return ;
};

@end
