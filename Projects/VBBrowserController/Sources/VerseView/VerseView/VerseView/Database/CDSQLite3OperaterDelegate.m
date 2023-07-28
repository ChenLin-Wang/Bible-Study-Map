//
//  CDSQLite3OperaterDeLegate.m
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/26.
//

#import "CDSQLite3OperaterDelegate.h"

@implementation CDSQLite3OperaterDelegate
-(id)init{
    self =[super init];
    if (self) {
        _MyEditor=[CDEditorForWhereas_connect new];
        [_MyEditor setDelegate:self];
        _MyDatabase=nil;
        _MyFolder=nil;
    };
    
    return self;
};

- (CDdataOperaterError)connectDataBasewithAddress:(NSString *)address
                                     withDatabase:(NSString *)aDatabase
                                           byUser:(NSString *)user
                                      andPassword:(NSString *)PassW {
    //benDQLite3Operator 不理会 User 和 Password.
    //且看address 只是 文件夹路径 Path of folder。
    //本函数的功能在于建立记住所打开的数据库。并且只能够对应一个
    _MyFolder=address;
    _MyDatabase=aDatabase;
    if (_MyFolder==nil||_MyDatabase==nil) {
        if (_MyFolder==nil) _MyFolder=@"请给目录";
        if (_MyDatabase==nil) _MyDatabase=@"请选择数据库";
        NSMutableArray * pM=[NSMutableArray new];
        [pM addObject:@[@"A",@"201",_MyFolder]];
        [pM addObject:@[@"D",@"201",_MyDatabase]];
        NSDictionary *D=[_MyEditor setParameters:pM];
        _MyFolder= [D objectForKey:@"CDAddress_A"];
        _MyDatabase= [D objectForKey:@"CDDatabase_D"];
    };
    
    NSString *S=[NSString stringWithFormat:@"%@/%@",_MyFolder,_MyDatabase];
    if ([self OpenDataBase:S])
    {
        [self closeDatabase];
        return CDIDU_sucsess;
    };
    _MyFolder=nil;
    _MyDatabase=nil;
    return CDIDU_NoSuchPath;
}

- (NSString *)AddressTextClicked {
    //这里打开文件选择其。
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"选择SQLite3数据库文件"];
    [panel setPrompt:@"OK"];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:NO];
    [panel setCanChooseFiles:NO];
    [panel runModal];//这个操作破坏了原来的modal，不知道该如修复这个
    NSString* pathf=[[panel URL] path];
    return pathf;
}

- (nonnull NSArray<NSString *> *)getListForShowDatabaseFromAddress:(nonnull NSString *)Address byUser:(nonnull NSString *)User WithPassWord:(nonnull NSString *)Password {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:Address]) {
        NSError * __autoreleasing  _Nullable E;
        NSArray *  contents = [fileManager contentsOfDirectoryAtPath:Address error:&E];
        NSMutableArray *  contentsForAnswer=[NSMutableArray new];
        for (NSString *f in contents)
        {
            if ([f containsString:@".sqlite"]){
                if ([self OpenDataBase:[NSString stringWithFormat:@"%@/%@",Address,f]]){
                    [contentsForAnswer addObject:f];
                    [self closeDatabase];
                }
            }
        }
        return contentsForAnswer;
    }else {
        return @[@"Bad Address",@"By User",@"Password"];
    };
}


- (nonnull NSArray<NSString *> *)getListForShowTableNameFromDatabase:(nonnull NSString *)adatabase Address:(nonnull NSString *)Address {
    
    NSArray *M=[self getTablesName:[NSString stringWithFormat:@"%@/%@",Address,adatabase]];
    if (M==nil||[M count]==0) {
        return @[@"数据表格没有找到",@"可能是路径错误",@"或者文件名错误"];
    };
    return M;
}
- (nonnull NSArray<NSString *> *)getListForShowFieldsFromTable:(nonnull NSString *)TableName Database:(nonnull NSString *)adatabase Address:(nonnull NSString *)Address {
    if ([self OpenDataBase:[NSString stringWithFormat:@"%@/%@",Address,adatabase]]) {
        _MyDatabase=adatabase;
        _MyFolder=Address;
        [self closeDatabase];
        return [self getFieldsNameWithTypesByTableName:TableName];
    };
    return @[@"Filed0FromTable",@"Filed1",@"Fileds5",@"Filed7",@"Fileds9"];
}

-(NSMutableArray *)getFieldsNameWithTypesByTableName:(NSString *)TableName{
    NSMutableArray *Result=[NSMutableArray new];
    int b;
    NSString *pK;
    if ([self OpenDataBase:[NSString stringWithFormat:@"%@/%@",_MyFolder,_MyDatabase]])
    {
        NSString *SqlStatementPrepare=[NSString stringWithFormat:@"PRAGMA table_info('%@')",TableName];
        const char *sqlStatement =[SqlStatementPrepare UTF8String];
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        if( b== SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                pK=[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                if ([pK intValue]==1) {
                    [Result insertObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]  atIndex:0];
                } else {
                    [Result addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
                    
                };
            };
            b=sqlite3_finalize(statement);
        }
        else Result=nil;
        [self closeDatabase];
    };
    return Result;
};


- (CDdataOperaterError)copyTableToName:(nonnull NSString *)newTableName
                              WithData:(BOOL)isWithData
                          FromDatabase:(nonnull id<DatabaseOperaterDelegate>)anotherDatabase
                         withTablename:(nonnull NSString *)oldTableName {
    //确认新表格名称是否存在
    NSArray *namesOfTable=[self getTablesName:nil];
    if (namesOfTable.count==0)return CDIDU_BadTableName;
    for (NSString *S in namesOfTable) {
        if ([S isEqualToString:newTableName]) return CDIDU_BadTableName;
    }
    //本地拷贝
    if (anotherDatabase==self|anotherDatabase==nil) {
        //确认旧表格名称是否存在
        for (NSString *S in namesOfTable) {
            if ([S isEqualToString:oldTableName]) {
                [self CopyTableWitholdName:oldTableName toNewName:newTableName WithData:isWithData];
                return CDIDU_sucsess;
            }
        }
        return CDIDU_BadTableName;
    };
    //检查所要拷贝的数据是否存在。
    //创建数据表格
    NSArray *aStructofTable= [anotherDatabase listFiledsByTableName:oldTableName];
    if (aStructofTable.count==0) return CDIDU_BadFields;
    if ( [self CreateTable:aStructofTable withTableName:newTableName]!=CDIDU_sucsess) return CDIDU_OtherReasontoFail;
    if (!isWithData) return CDIDU_sucsess;
    CDSelectRecords *RecordsforCopy=[anotherDatabase selectRecordswithFileds:aStructofTable fromTable:oldTableName whereas:nil];
    return  [self insertRecordsIntoTable:RecordsforCopy withnTableNmae:newTableName];
}
-(CDdataOperaterError)CreateTable:(nonnull NSArray<CDField *> *)aStruture withTableName:(nonnull NSString *)tablename {
    /*
     CREATE TABLE COMPANY(
     ID INT PRIMARY KEY     NOT NULL,
     NAME           TEXT,
     AGE            integer,
     SALARY         REAL,
     PHoto          blob
     );
     */
    int b;
    NSString *SqlStatementPrepare;
    NSMutableString *Fields=[NSMutableString new];
    
    if (aStruture==nil|aStruture.count==0) return CDIDU_BadKeyField;
    for (CDField *F in aStruture) {
        if (F.isPrimaryKey) {
            [Fields appendFormat:@"%@ %@ PRIMARY KEY NOT NULL,",F.FieldName,F.stringOfFiledType];
        }else {
            [Fields appendFormat:@"%@ %@,",F.FieldName,F.stringOfFiledType];
        };
    };
    [Fields deleteCharactersInRange:NSMakeRange([Fields length]-1,1)];
    if ([self OpenDataBase:nil])
    {
        SqlStatementPrepare=[NSString stringWithFormat:@"Create table %@ (%@)",tablename ,Fields];//
        const char *sqlStatement =[SqlStatementPrepare UTF8String];
        b=sqlite3_exec(dataBase, sqlStatement, 0, 0, 0);
        b=sqlite3_close(dataBase);
        return CDIDU_sucsess;
    };
    return CDIDU_OtherReasontoFail;
};

-(BOOL)CopyTableWitholdName:(NSString*)oldTableName toNewName:(NSString*)newTableName WithData:(BOOL)withData{
    int b;
    NSString *SqlStatementPrepare;
    if ([self OpenDataBase:nil])
    {
        if (withData) SqlStatementPrepare=[NSString stringWithFormat:@"Create table %@ as select * from %@",newTableName,oldTableName];//这里条指令发生了错误，丢失了blob字段类型。是sqlite3 的一个bug。
        else SqlStatementPrepare=[NSString stringWithFormat:@"Create table %@ as select * from %@ where 0",newTableName,oldTableName];//可能这条指令也有同养的问题。
        const char *sqlStatement =[SqlStatementPrepare UTF8String];
        b=sqlite3_exec(dataBase, sqlStatement, 0, 0, 0);
        b=sqlite3_close(dataBase);
        // NSLog(@"%@ has deleted!",aTablename);
        return YES;
    };
    return NO;};

- (CDSelectRecords *)selectRecordswithFileds:(NSArray<CDField *> *)aStruture fromTable:(nonnull NSString *)tablename whereas:(NSString *)condition {
    
    CDSelectRecords *selectedRecords=[CDSelectRecords new];
    int b;
    NSString *aSQLStatement;
    NSMutableString *aName=[NSMutableString new];
    if ((aStruture==nil)|([aStruture count]==0)) {[aName appendString:@"*"];
        aStruture=[self listFiledsByTableName:tablename];
    }else {
        for (CDField *aField in aStruture){
            [aName appendFormat:@"%@,",[aField FieldName]];}
        [aName deleteCharactersInRange:NSMakeRange([aName length]-1,1)];
    };
    
    if ((condition==nil)|(condition.length==0)){
        aSQLStatement=[NSString stringWithFormat:@"select %@ from '%@'",aName,tablename];
    }else{
        aSQLStatement=[NSString stringWithFormat:@"select %@ from '%@' where %@",aName,tablename,condition];
    };
    
    const char *sqlStatement =[aSQLStatement UTF8String];
    
    if ([self OpenDataBase:nil]) {
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        if( b!= SQLITE_OK) {
            [selectedRecords setError:@"SQL语句有错误，可是条件不对"];
        } else {
            // get records
            [selectedRecords setTableStructure:aStruture];
            sqlite3_value *ColumnValue;
            //NSString *cLName;
            id aData;
            NSMutableArray *anRecords=[NSMutableArray new];
            while (sqlite3_step(statement)== SQLITE_ROW){
                NSMutableArray *aRecord=[NSMutableArray new];
                for (int i=0;i<sqlite3_data_count(statement);i++){
                    ColumnValue=sqlite3_column_value(statement, i);
                    //cLName=[NSString stringWithUTF8String:(char *)sqlite3_column_name(statement, i)];
                    aData=[self GetObjectFromSqlite3Data: ColumnValue FieldStruct:[aStruture objectAtIndex:i]];
                    [aRecord addObject:aData];
                }
                [anRecords addObject:aRecord];
            }
            b=sqlite3_finalize(statement);
            [selectedRecords setRecords:anRecords];
        };
        b=sqlite3_close(dataBase);
        return selectedRecords;
    }
    [selectedRecords setError:@"没有这样的数据库！"];
    return selectedRecords;
};

- (BOOL)AppendDatafromBaseToThisSelectRecords:(nonnull CDSelectRecords *)TheSelectRecord withKeyValue:(nonnull NSArray<NSString *> *)keyValues {
    NSArray *aStructrue = TheSelectRecord.TableStructure;
    NSArray *aRecord;
    BOOL isAppend = NO;
    for (NSString *KeyV in keyValues) {
        aRecord = [self SelectaRecordwithField:aStructrue withKeyValue:KeyV];
        if (nil != aRecord) {
            if (aRecord.count>0) {
                [TheSelectRecord.Records addObject:aRecord];
                isAppend = YES;
            }
        }
    }
    return isAppend;
}

-(NSArray<id>*)SelectaRecordwithField:(nonnull NSArray<CDField *> *)aStructure  withKeyValue:(nonnull NSString*)KeyValue{
    //select StrongNumberWordsTranslate_DY.strongNumber,StrongNumberWords_NetBileOrg.HebrewOrGreekWord from StrongNumberWords_NetBileOrg,StrongNumberWordsTranslate_DY where StrongNumberWords_NetBileOrg.strongNumber= StrongNumberWordsTranslate_DY.strongNumber  and StrongNumberWordsTranslate_DY.strongNumber =3435
    
    if (aStructure==nil)
        [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"Fields 不能够为空！"];
    
    if (aStructure.count==0)
        [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"Fields 不能够为空！"];
    
    if (KeyValue==nil)
        [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"关键字 不能够为空！"];
    
    //装配select语句
    NSMutableString *Fields    =[NSMutableString new];
    NSMutableString *tables    =[NSMutableString new];
    NSMutableString *condition =[NSMutableString new];
    
    CDField *F = [aStructure firstObject];
    if (!F.isPrimaryKey)
        [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"first of Fields 必须是关键字段！"];
    
    NSString * keyTableNameWithFieldName = [NSString stringWithFormat:@"%@.%@",F.TableName,F.FieldName];
    [Fields appendString:keyTableNameWithFieldName];
    [tables appendString:F.TableName];
    [condition appendFormat:@"%@=%@", keyTableNameWithFieldName, [self DoubleQuotes:KeyValue]];
    
    NSString *KeyFieldName=F.FieldName;//保留第一的关键字段名
    for (NSUInteger i=1; i<aStructure.count; i++) {
        F = [aStructure objectAtIndex:i];
        
        [Fields appendFormat:@",%@.%@", F.TableName, F.FieldName];
        
        if (![self isTablename:F.TableName IntheTables:tables]) {
            [tables appendFormat:@",%@",F.TableName];
            [condition appendFormat:@" and %@.%@=%@", F.TableName, KeyFieldName, keyTableNameWithFieldName];
        }
    }
    
    int b;
    NSString *aSQLStatement=[NSString stringWithFormat:@"select %@ from %@ where %@",Fields,tables,condition];
    const char *sqlStatement =[aSQLStatement UTF8String];
    //获取数据到
    NSMutableArray *aRecord=[NSMutableArray new];
    if ([self OpenDataBase:nil]) {
        b = sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        
        if( b== SQLITE_OK) {
            // get records
            sqlite3_value *ColumnValue;
            //NSString *cLName;
            id aData;
            if (sqlite3_step(statement)== SQLITE_ROW){
                for (int i=0;i<sqlite3_data_count(statement);i++){
                    ColumnValue = sqlite3_column_value(statement, i);
                    
                    aData = [self GetObjectFromSqlite3Data:ColumnValue
                                               FieldStruct:[aStructure objectAtIndex:i]];
                    
                    [aRecord addObject:aData];
                }
            }//没有记录
            
        } else aRecord=nil;
        
    }else aRecord=nil;
    
    b=sqlite3_finalize(statement);
    b=sqlite3_close(dataBase);
    return aRecord;
};

-(BOOL)isTablename:(NSString*)name IntheTables:(NSString*)Tables{
    NSArray * Ss=[Tables componentsSeparatedByString:@","];
    if (Ss.count<1) return NO;
    for (NSString *S in Ss) {
        if ([S isEqualToString:name]) return YES;
    };
    return NO;
};

-(NSString *)DoubleQuotes:(NSString *)aString{
    NSMutableString *S=[NSMutableString stringWithString:aString];
    [S replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:
     NSCaseInsensitiveSearch range:NSMakeRange(0,S.length)];
    return [NSString stringWithFormat:@"\"%@\"",S];
};
-(NSString *)SingleQuotes:(NSString *)aString{
    NSMutableString *S=[NSMutableString stringWithString:aString];
    [S replaceOccurrencesOfString:@"'" withString:@"\'" options:
     NSCaseInsensitiveSearch range:NSMakeRange(0,S.length)];
    return [NSString stringWithFormat:@"'%@'",S];
};

- (CDRecord *)findaRecordwithFileds:(NSArray<CDField *> *)aStruture fromTable:(nonnull NSString *)tablename whereas:(nonnull NSString *)condition {
    if (condition==nil|condition.length==0) [NSException raise:@"CDRecord" format:@"CRecord 缺少whereas条件！"];
    
    CDRecord * aRecordForresult=[CDRecord new];
    [aRecordForresult setDatabaseOperater:self];
    
    NSMutableString *aName=[NSMutableString new];
    if ((aStruture==nil)|([aStruture count]==0)) {[aName appendString:@"*"];
        aStruture=[self listFiledsByTableName:tablename];
    }else{
        for (CDField *aField in aStruture){
            [aName appendFormat:@"\"%@\",",[aField FieldName]];}
        [aName deleteCharactersInRange:NSMakeRange([aName length]-1,1)];
    }
    
    [aRecordForresult setTableName:tablename];
    [aRecordForresult setTableStructure:aStruture];
    
    NSString *aSQLStatement=[NSString stringWithFormat:@"select %@ from '%@' where %@",aName,tablename,condition];
    const char *sqlStatement =[aSQLStatement UTF8String];
    
    if ([self OpenDataBase:nil]) {
        int b;
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        if( b!= SQLITE_OK) {
            [aRecordForresult setError:@"SQL语句有错误，可是条件不对"];
        } else {
            // get records
            sqlite3_value *ColumnValue;
            //NSString *cLName;
            id aData;
            if (sqlite3_step(statement)== SQLITE_ROW){
                NSMutableArray *aRecord=[NSMutableArray new];
                for (int i=0;i<sqlite3_data_count(statement);i++){
                    ColumnValue=sqlite3_column_value(statement, i);
                    //cLName=[NSString stringWithUTF8String:(char *)sqlite3_column_name(statement, i)];
                    aData=[self GetObjectFromSqlite3Data: ColumnValue FieldStruct:[aStruture objectAtIndex:i]];
                    [aRecord addObject:aData];
                }
                [aRecordForresult setValues:aRecord];
            } else {
                [aRecordForresult setError:@"没有找到记录"];
            };
        };
        b=sqlite3_finalize(statement);
        b=sqlite3_close(dataBase);
        return aRecordForresult;
    }
    [aRecordForresult setError:@"没有这样的数据库！"];
    return aRecordForresult;
};

-(id)GetObjectFromSqlite3Data:(sqlite3_value *)ColumnValue FieldStruct:(CDField *)aFieldStructure{
    /* 这里数据的类型可能与字段定义的类型不一致，SQLite3 具有任何类型字段都可以随意挂载任何类型的数据的能力。
     如果发现的情况，就要做一些调整，甚至丢弃数据。因此要确保输入的数据与字段的类型一致。
     */
    id p;
    NSDateFormatter *theDateMatter=[NSDateFormatter new];
    NSData * DD;
    switch (sqlite3_value_type(ColumnValue)) {
        case SQLITE_BLOB:
            //如果字段不适合blob，那么就返回一个NULL。
            DD=[[NSData alloc] initWithBytes :sqlite3_value_blob(ColumnValue) length:sqlite3_value_bytes(ColumnValue)];
            p=[aFieldStructure objectFromData:DD];
            break;
        case SQLITE_INTEGER:
            p= [NSNumber numberWithInteger:sqlite3_value_int64(ColumnValue)];
            break;
        case SQLITE_FLOAT:
            p= [NSNumber numberWithDouble:sqlite3_value_double(ColumnValue)];
            break;
        case SQLITE_TEXT:
            p= [NSString stringWithUTF8String:(char *)sqlite3_value_text(ColumnValue)];
            switch (aFieldStructure.FieldType) {
                case CDFieldisDate:
                    [theDateMatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    p=[theDateMatter dateFromString:p];
                    break;
                case CDFieldisNumberInteger:
                    p=[NSNumber numberWithInteger:[p integerValue]];
                    break;
                case CDFieldisNumberReal:
                    p=[NSNumber numberWithDouble:[p doubleValue]];
                    break;
                case CDFieldisAttributedString:
                    p=[[NSAttributedString new] initWithString:p];
                    break;
                default:
                    break;
            }
            break;
        case SQLITE_NULL://初始化
            switch (aFieldStructure.FieldType) {
                case CDFieldisNumberInteger:
                    p=[NSNumber numberWithInteger:0];break;
                case CDFieldisNumberReal:
                    p=[NSNumber numberWithDouble:0.0];break;
                case CDFieldisAttributedString:
                    p=[NSAttributedString new];break;
                case CDFieldisDate:
                    p=[NSDate new] ;break;
                case CDFieldisString:
                    p=@"[Null]";break;
                case CDFieldisAudio:
                    p=[AVAudioPlayer new];break;
                case CDFieldisMovie:
                    p=[AVMovie new];break;
                case CDFieldisImage:
                    p=[NSImage new];break;
                case CDFieldisSketch:
                    
                default:
                    p=nil;
                    break;
            }
    }
    if (p==nil) p=@"[Null]";
    return p;
};


- (nonnull NSArray<NSString *> *)listTablesName{
    if (_MyFolder==nil||_MyDatabase==nil) return nil;
    return [self getTablesName:[NSString stringWithFormat:@"%@/%@",_MyFolder,_MyDatabase]];
}

- (nonnull NSArray<CDField *> *)listFiledsByTableName:(nonnull NSString *)Tablename {
    
    int b;
    NSMutableArray *Structures=[NSMutableArray new];
    if ([self OpenDataBase:nil])
    {
        NSString *SqlStatementPrepare=[NSString stringWithFormat:@"PRAGMA table_info('%@')",Tablename];
        const char *sqlStatement =[SqlStatementPrepare UTF8String];
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        NSString * Fieldreading;
        CDFieldType FieldTypeInt=0;
        BOOL Key=NO;
        if( b== SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                CDField *p=[CDField new];
                FieldTypeInt = 0;
                [p setFieldName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
                Fieldreading=[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                Fieldreading=[Fieldreading lowercaseString];
                //下面这一条是多余的。因为sqlite3出现了一个bug，当使用create Table as select from 命令是，他会丢失原来表格中的blob字段类型。从而成为一个@"".因此在这里做了修正处理。
                if ([Fieldreading isEqualToString:@""]) Fieldreading=@"blob";
                
                if ([Fieldreading containsString:@"int"])
                    FieldTypeInt = CDFieldisNumberInteger;
                
                if ([Fieldreading isEqualToString:@"real"])
                    FieldTypeInt = CDFieldisNumberReal;
                
                if ([Fieldreading isEqualToString:@"boolean"]) {
                    FieldTypeInt = CDFieldisBoolean;
                }
                
                if ([Fieldreading containsString:@"char"])
                    FieldTypeInt = CDFieldisString;
                
                if ([Fieldreading isEqualToString:@"text"]) {
                    FieldTypeInt = [p readTypeFromFieldname];
                    
                    if (FieldTypeInt==0)
                        FieldTypeInt = CDFieldisString;
                }
                
                if ([Fieldreading isEqualToString:@"blob"])
                    FieldTypeInt = [p readTypeFromFieldname];
                
                
                
                if (FieldTypeInt == 0) {
                    b = sqlite3_finalize(statement);
                    b = sqlite3_close(dataBase);
                    [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"FieldsName %@ wrong!",Fieldreading];
                }
                
                [p setFieldType:FieldTypeInt];
                Fieldreading = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                Key=[Fieldreading boolValue];
                [p setIsPrimaryKey:Key];
                if (Key == YES) {
                    [Structures insertObject:p atIndex:0];
                } else {
                    [Structures addObject:p];
                }
            }
            b = sqlite3_finalize(statement);
        }
        else Structures=nil;
        b=sqlite3_close(dataBase);
    }
    return Structures;
}

- (CDSelectRecords *)selectRecordsWithField:(nonnull NSArray<CDField *> *)aStructure
                                       sqlStatement:(nonnull NSString *)sqlStatement {
    CDSelectRecords *selectedRecords = nil;
    
    if ([self OpenDataBase:nil]) {
        selectedRecords = [CDSelectRecords new];
        int res;
        res = sqlite3_prepare_v2(dataBase, sqlStatement.UTF8String, -1, &statement, NULL);
        if(res != SQLITE_OK) {
            [selectedRecords setError:@"SQL语句有错误，可是条件不对"];
        } else {
            // get records
            [selectedRecords setTableStructure:aStructure];
            sqlite3_value *ColumnValue;
            //NSString *cLName;
            id aData;
            NSMutableArray *anRecords=[NSMutableArray new];
            while (sqlite3_step(statement)== SQLITE_ROW){
                NSMutableArray *aRecord=[NSMutableArray new];
                for (int i=0;i<sqlite3_data_count(statement);i++){
                    ColumnValue=sqlite3_column_value(statement, i);
                    //cLName=[NSString stringWithUTF8String:(char *)sqlite3_column_name(statement, i)];
                    aData = [self GetObjectFromSqlite3Data:ColumnValue FieldStruct:[aStructure objectAtIndex:i]];
                    [aRecord addObject:aData];
                }
                [anRecords addObject:aRecord];
            }
            res = sqlite3_finalize(statement);
            [selectedRecords setRecords:anRecords];
        };
        res = sqlite3_close(dataBase);
        return selectedRecords;
    }
    [selectedRecords setError:@"没有这样的数据库！"];
    return selectedRecords;
}

-(nonnull CDRecord *)DoIDUaRecord:( nonnull CDRecord *)aRecord {
    //if ([aRecord.TableStructure count]!=[aRecord.Values count])
    //    [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"DoIDUaRecord aRecord 字段名与字段值 错误"];
    if (aRecord.error!=nil) return aRecord; //带有问题的，可能数据不合适，因此不应惩罚编程员。
    CDRecord *UndoRecord;
    UndoRecord=[self findaRecordwithFileds:aRecord.TableStructure fromTable:aRecord.TableName whereas:aRecord.getWhereAs];
    int ExistOfRecord=0;
    if ([UndoRecord.error isEqualToString:@"没有找到记录"]) ExistOfRecord=2;
    if (UndoRecord.error==nil) ExistOfRecord=1;//找到记录
    if (ExistOfRecord==0)   return UndoRecord;//没有找到数据库；
    //紧接的switch块，是要根据试图处理的记录是否存在做的修正。是的这个模块更加坚固。
    UndoRecord=aRecord.copy;
    
    switch (UndoRecord.doAction) {
        case CDIDU_doNothing:
            
            break;
        case CDIDU_doInsert:
            if (ExistOfRecord==1)  [UndoRecord setDoAction:CDIDU_doUpdate];
            break;
        case CDIDU_doDelete:
            if (ExistOfRecord==2)  [UndoRecord setDoAction:CDIDU_doNothing];
            break;
        case CDIDU_doUpdate:
            if (ExistOfRecord==2)  [UndoRecord setDoAction:CDIDU_doInsert];
            break;
        default:
            [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"doAction 错误"];
            break;
    }
    switch (UndoRecord.doAction) {
        case CDIDU_doNothing:
            return UndoRecord;
            break;
        case CDIDU_doInsert:
            if ( [self insertRecordIntoTable:UndoRecord]==CDIDU_sucsess) {
                [UndoRecord setDoAction:CDIDU_doDelete];
            } else {
                UndoRecord.error=@"插入失败";
            }
            return UndoRecord;
            break;
        case CDIDU_doDelete:
            UndoRecord=[self findaRecordwithFileds:nil fromTable:aRecord.TableName whereas:[aRecord getWhereAs]];
            [UndoRecord setDoAction:CDIDU_doInsert];
            if ([self deleteRecordFromTable:aRecord]==CDIDU_sucsess) {
                return UndoRecord;
            } else {
                UndoRecord.error=@"删除失败";
                return  UndoRecord;
            };
            break;
        case CDIDU_doUpdate:
            UndoRecord=[self findaRecordwithFileds:aRecord.TableStructure fromTable:aRecord.TableName whereas:aRecord.getWhereAs];
            [UndoRecord setDoAction:CDIDU_doUpdate];
            if ([self updateaRecordIntoTable:aRecord]==CDIDU_sucsess) {
                return UndoRecord;
            } else {
                UndoRecord.error=@"更新失败";
                return UndoRecord;
            };
            break;
        default:
            [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"doAction 错误"];
            break;
    }
    return nil;//保护性语句，没有实际意义。
}
-(CDdataOperaterError)insertRecordIntoTable:(nonnull CDRecord *)aRecord{
    NSString *aName;
    NSMutableString *SQLStatement=[NSMutableString new];
    NSMutableString *SQLValues=[NSMutableString new];
    NSUInteger m=[aRecord.TableStructure count];
    for (NSUInteger i=0;i<m;i++)
    {   aName=[aRecord.TableStructure objectAtIndex:i].FieldName;
        [SQLStatement appendFormat:@"%@,",aName];
        [SQLValues appendString:@"?,"];
    };
    [SQLStatement deleteCharactersInRange:NSMakeRange([SQLStatement length]-1,1)];
    [SQLValues deleteCharactersInRange:NSMakeRange([SQLValues length]-1,1)];
    SQLStatement=[NSMutableString stringWithFormat:@"insert into %@ (%@) values (%@)",aRecord.TableName,SQLStatement,SQLValues];
    
    // NSLog(@"%@",SQLStatement);
    int b;
    CDdataOperaterError Error=0;
    
    if (![self OpenDataBase:nil]) {Error=CDIDU_CanotOpenThebase;}
    else
    {   const char *sqlStatement =[SQLStatement UTF8String];
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        if( b!= SQLITE_OK) {Error=CDIDU_CanotOpenThebase;}
        else
        {   //bind data into statement
            for (NSUInteger i=0;i<m;i++)
                [self SetObjectIntoSqlite3statement:[aRecord.Values objectAtIndex:i]
                                      withFiledType:[aRecord.TableStructure objectAtIndex:i].FieldType WithNumberOfBinding:i+1];
            b = sqlite3_step(statement);//SQLITE_DONE=101
            if (b!=101) Error=CDIDU_BadSQLStatement;
        }
        b=sqlite3_finalize(statement);
        b=sqlite3_close(dataBase);
    }
    return Error;
};
-(CDdataOperaterError)insertRecordsIntoTable:(nonnull CDSelectRecords*)aRecords withnTableNmae:(NSString*)TableName {
    //本模块默认 数据表结构是包含了CDSelectRecords 的字段的。
    NSString *aName;
    NSMutableString *SQLStatement=[NSMutableString new];
    NSMutableString *SQLValues=[NSMutableString new];
    NSUInteger m=[aRecords.TableStructure count];
    for (NSUInteger i=0;i<m;i++)
    {   aName=[aRecords.TableStructure objectAtIndex:i].FieldName;
        [SQLStatement appendFormat:@"%@,",aName];
        [SQLValues appendString:@"?,"];
    };
    [SQLStatement deleteCharactersInRange:NSMakeRange([SQLStatement length]-1,1)];
    [SQLValues deleteCharactersInRange:NSMakeRange([SQLValues length]-1,1)];
    SQLStatement=[NSMutableString stringWithFormat:@"insert into '%@' (%@) values (%@)",TableName,SQLStatement,SQLValues];
    
    // NSLog(@"%@",SQLStatement);
    int b;
    CDdataOperaterError Error=0;
    
    if (![self OpenDataBase:nil]) {Error=CDIDU_CanotOpenThebase;}
    else
    {   const char *sqlStatement =[SQLStatement UTF8String];
        for (NSArray *aRecord in aRecords.Records) {
            b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
            if( b!= SQLITE_OK) {Error=CDIDU_CanotOpenThebase;}
            else
            {   //bind data into statement
                for (NSUInteger i=0;i<m;i++)
                    [self SetObjectIntoSqlite3statement:[aRecord objectAtIndex:i]
                                          withFiledType:[aRecords.TableStructure objectAtIndex:i].FieldType WithNumberOfBinding:i+1];
                b = sqlite3_step(statement);//SQLITE_DONE=101
                if (b!=101) Error=CDIDU_BadSQLStatement;
            }
            b=sqlite3_finalize(statement);
        }
        b=sqlite3_close(dataBase);
    }
    return Error;
};


-(CDdataOperaterError)updateaRecordIntoTable:(nonnull CDRecord *)aRecord{
    //prepare SQLStatement
    NSUInteger m=[aRecord.TableStructure count];
    if (m<1) return CDIDU_BadCDRecord; //是可以为1个的。因为后面有关键字段 作为定位器。
    // [self SaveUndo:aTableName PrimaryKey:Pk isKeyValue:oldKeyValue];
    
    NSString *aName;
    NSMutableString *SQLStatement=[NSMutableString new];
    
    for (NSUInteger i=0;i<m;i++) {
        CDField *field = [aRecord.TableStructure objectAtIndex:i];
        if (!field.isPrimaryKey) {
            aName=field.FieldName;
            [SQLStatement appendFormat:@"%@=?,",aName];
        }
    };
    

    [SQLStatement deleteCharactersInRange:NSMakeRange([SQLStatement length]-1,1)];
    SQLStatement=[NSMutableString stringWithFormat:@"update %@ set %@ where %@",aRecord.TableName,SQLStatement,aRecord.getWhereAs];
    
    //NSLog(@"SQLStatement: %@",SQLStatement);
    int b;
    int Error=0;
    
    if (![self OpenDataBase:nil]) {
        Error=CDIDU_CanotOpenThebase;
    } else {
        const char *sqlStatement =[SQLStatement UTF8String];
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        if( b!= SQLITE_OK) {
            Error=CDIDU_BadSQLStatement;
            
        } else {
            //bind data into statement
            for (NSUInteger i=0, bindNum=1; i<m; i++) {
                CDField *field = [aRecord.TableStructure objectAtIndex:i];
                if (!field.isPrimaryKey) {
                    [self SetObjectIntoSqlite3statement:[aRecord.Values objectAtIndex:i]
                                          withFiledType:[aRecord.TableStructure objectAtIndex:i].FieldType WithNumberOfBinding:bindNum];
                    ++bindNum;
                }
                // [self SetObjectIntoSqlite3statement:aRecord.KeyValue withFiledType:aRecord.KeyField.FieldType WithNumberOfBinding:1];
            }
            
            b = sqlite3_step(statement);//SQLITE_DONE=101
            if (b!=101) Error=CDIDU_BadSQLStatement;
        }
        b=sqlite3_finalize(statement);
        b=sqlite3_close(dataBase);
    }
    return Error;
};

-(CDdataOperaterError)deleteRecordFromTable:(nonnull CDRecord *)aRecord{
    //(nonnull NSString *)aTableName withKeyField:(nonnull CDField *)KeyField isKeyValue:(nonnull NSString *)oldKeyValue{
    // if (!KeyField.isPrimaryKey) return CDIDU_BadKeyField;
    //prepare SQLStatement
    NSMutableString *SQLStatement=[NSMutableString new];
    SQLStatement=[NSMutableString stringWithFormat:@"delete from %@ where %@",aRecord.TableName,aRecord.getWhereAs];
    int b;
    CDdataOperaterError Error=CDIDU_sucsess;
    
    if (![self OpenDataBase:nil]) {Error=CDIDU_CanotOpenThebase;}
    else
    {   const char *sqlStatement =[SQLStatement UTF8String];
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        if( b!= SQLITE_OK) {Error=CDIDU_BadSQLStatement;}
        else
        {   //bind data into statement
            // [self SetObjectIntoSqlite3statement:aRecord.KeyValue withFiledType:aRecord.KeyField.FieldType WithNumberOfBinding:1];
            b = sqlite3_step(statement);//SQLITE_DONE=101
            if (b!=101) Error=CDIDU_BadSQLStatement;
        }
        b=sqlite3_finalize(statement);
        b=sqlite3_close(dataBase);
    }
    return Error;
};

-(void)SetObjectIntoSqlite3statement:(id)anObject
                       withFiledType:(CDFieldType)FieldType
                 WithNumberOfBinding:(NSUInteger)BNumber{
    int b;
    NSData *DATA;
    NSString *X;
    NSDateFormatter *theDateMatter=[NSDateFormatter new];
    [theDateMatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString *clasN=[anObject className] ;
    if ([anObject isKindOfClass:[NSString class]])
        if ([(NSString *)anObject isEqualToString:@"[Null]"])
        {b=sqlite3_bind_null(statement, (int)BNumber);return;};
    switch (FieldType) {
        case CDFieldisNULL:
            b=sqlite3_bind_null(statement, (int)BNumber);
            break;
        case CDFieldisNumberInteger:
            b=sqlite3_bind_int(statement, (int)BNumber, [(NSNumber *)anObject intValue]);
            break;
        case CDFieldisNumberReal:
            b=sqlite3_bind_double(statement, (int)BNumber, [(NSNumber *)anObject doubleValue]);
            break;
        case CDFieldisDate:
            X=[theDateMatter stringFromDate:(NSDate*)anObject];
            b=sqlite3_bind_text(statement, (int)BNumber, [X UTF8String],-1, nil);
            break;
        case CDFieldisString:
            b=sqlite3_bind_text(statement, (int)BNumber, [(NSString*)anObject UTF8String],-1, nil);
            break;
        case CDFieldisAttributedString:
            DATA=[(NSAttributedString *)anObject RTFDFromRange:NSMakeRange(0,[(NSAttributedString *)anObject length] ) documentAttributes:nil];
            b=sqlite3_bind_blob(statement, (int)BNumber, [DATA bytes],(int)[DATA length], SQLITE_TRANSIENT);
            break;
        case CDFieldisAudio:
        case CDFieldisMovie:
        case CDFieldisImage:
        case CDFieldisSketch:
        case CDFieldisUnkonwType:
        default:
            b=sqlite3_bind_null(statement, (int)BNumber);
            break;
    }
};
-(BOOL)OpenDataBase:(NSString*)dbPath{
    if (dbPath==nil) {//仅在确保有数据的时候可以如此调用
        if (_MyFolder==nil||_MyDatabase==nil) return NO;
        dbPath=[NSString stringWithFormat:@"%@/%@",_MyFolder,_MyDatabase];
    };
    int optRes = sqlite3_open([dbPath UTF8String], &dataBase);
    if (SQLITE_OK == optRes) {
        char *errMeg;
        optRes = sqlite3_exec(dataBase, "PRAGMA table_info(try);", nil, nil, &errMeg);
        // printf("error: %d \nMeg: %s\n", optRes, errMeg)
        if (optRes!=SQLITE_NOTADB) return YES;
    }
    sqlite3_close(dataBase);
    return NO;
};

-(void)closeDatabase{
    if (dataBase !=nil) sqlite3_close(dataBase);
    dataBase=nil;
};

-(NSArray*)getTablesName:(NSString *)dbPath{
    //NSMutableArray *SelectTables=[[NSMutableArray alloc] init];
    NSMutableArray *Names=[NSMutableArray new];
    if ([self OpenDataBase:dbPath])
    {
        int b=0;
        // 设置SQL查询语名
        const char *sqlStatement ="SELECT name FROM sqlite_master where type ='table'";
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        if( b== SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *aName=[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                [Names addObject:aName];
            };
            b=sqlite3_finalize(statement);
        };
        [self closeDatabase];
    };
    
    return [Names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
};

-(void)saveLinerToBibleScopeMap:(NSUInteger)Liner withBPVnum:(NSUInteger)BPVW{
    if ([self OpenDataBase:nil]) {
        int b=0;
        // 设置SQL查询语名
        
        NSString * SQLStatement=[NSString stringWithFormat:@"update BibleScopeMap set Liner=%lu where BPVWNum=%lu",(unsigned long)Liner,(unsigned long)BPVW ];
        const char *sqlStatement =[SQLStatement UTF8String];
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        
        b = sqlite3_step(statement);//SQLITE_DONE=101
        if (b!=101) [NSException raise:@"CDSQLite3OperaterDeLegate" format:@"saveLinerToBibleScopeMap CDIDU_BadSQLStatement"];
        
        b=sqlite3_finalize(statement);
        //b=sqlite3_close(dataBase);
    };
    [self closeDatabase];
};

-(NSUInteger)BpvwnumByLiner:(NSUInteger)aLiner{
    return [self Bpvwnum2Liner:aLiner Want2Bpvw:YES];
};

-(NSUInteger)LinerByBPVW:(NSUInteger)aBPVWnum{
    return [self Bpvwnum2Liner:aBPVWnum Want2Bpvw:NO];
};

-(NSUInteger)Bpvwnum2Liner:(NSUInteger)BoL Want2Bpvw:(BOOL)D {
    int b;
    NSUInteger L;
    NSString * SQLStatement;
    if (D) {
        SQLStatement=[NSString stringWithFormat:@"select BPVWNum from BibleScopeMap where BPVWNum>=%lu limit 1",(unsigned long)BoL ];
    } else {
        SQLStatement=[NSString stringWithFormat:@"select Liner from BibleScopeMap where BPVWNum>=%lu limit 1",(unsigned long)BoL ];
    }
    const char *sqlStatement =[SQLStatement UTF8String];
    
    if ([self OpenDataBase:nil]) {
        b=sqlite3_prepare_v2(dataBase, sqlStatement, -1, &statement, NULL);
        if( b== SQLITE_OK) {
            sqlite3_value *ColumnValue;
            if (sqlite3_step(statement)== SQLITE_ROW){
                ColumnValue=sqlite3_column_value(statement, 0);
                L= sqlite3_value_int64(ColumnValue);
                b=sqlite3_finalize(statement);
                b=sqlite3_close(dataBase);
                return L;
            };
            b=sqlite3_finalize(statement);
        };
        b=sqlite3_close(dataBase);
    }
    return 0;
};

- (NSURL *)databaseAddress {
    return [NSURL fileURLWithPath:_MyFolder];
}

@end
