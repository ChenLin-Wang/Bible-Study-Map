//
//  CDRecord.m
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/20.
//

#import "CDRecord.h"

@implementation CDRecord
-(void)turnUndoAction{
    //CDIDUdonothing,CDIDUdoundate needed to change!
    if (_doAction==CDIDU_doInsert){_doAction=CDIDU_doDelete;return;};
    if (_doAction==CDIDU_doDelete){_doAction=CDIDU_doInsert;return;};
};
-(CDRecord *)saveToDatabaseWithUndo{
    if (_DatabaseOperater!=nil) {
        return  [_DatabaseOperater DoIDUaRecord:self];};
    _error=@"DatabaseOperater=nil";
    return self;
};
-(id)init{
    self =[super init];
    if (self) {
        _error=nil;
        _doAction=CDIDU_doNothing;
    };
    return self;
};
-(NSString *)getWhereAs{
    return [NSString stringWithFormat:@"%@ is '%@'",_TableStructure.firstObject.FieldName,_Values.firstObject];
};
-(void)setTableStructure:(NSArray<CDField *> *)TableStructure{
    if (!TableStructure.firstObject.isPrimaryKey) [NSException raise:@"CDRecord" format:@"CRecord 缺少关键字段！"];
    _TableStructure=TableStructure;
};
-(void)setValues:(NSArray<id> *)Values{
    id p=Values.firstObject;
    CDField *KField=[_TableStructure firstObject];
    if (p==nil) p=[KField defaultValueAccordingType];
    _Values=Values;
};
-(CDField *)KeyField{
    return [_TableStructure firstObject];
};

-(NSString * )KeyValue{
    return [[_TableStructure firstObject] StringValueAccordtype:[_Values firstObject] withQuoter:CDDoubleQuoterMakeOn];
};
-(CDRecord *)copy{
    CDRecord * anew=[CDRecord new];
    [anew setDatabaseOperater:_DatabaseOperater];
    [anew setTableName:_TableName];
    [anew setTableStructure:_TableStructure];
    [anew setError:nil];
    [anew setValues:_Values];
    [anew setDoAction:_doAction];
    return anew;
};

@end
