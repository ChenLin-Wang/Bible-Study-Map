//
//  CDField.m
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/20.
//

#import "CDField.h"
#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>

@implementation CDField
-(CDFieldType)readTypeFromFieldname{
    NSString *NameL=[_FieldName lowercaseString];
    NSString *NameU=[_FieldName uppercaseString];
    if ([NameU rangeOfString:@"_ATS"].location!=NSNotFound) return CDFieldisAttributedString;
    if ([NameL rangeOfString:@"_attris"].location!=NSNotFound) return CDFieldisAttributedString;
    if ([NameU rangeOfString:@"_DAY"].location!=NSNotFound) return CDFieldisDate;
    if ([NameL rangeOfString:@"_date"].location!=NSNotFound) return CDFieldisDate;
    if ([NameU rangeOfString:@"_IMG"].location!=NSNotFound) return CDFieldisImage;
    if ([NameL rangeOfString:@"_image"].location!=NSNotFound) return CDFieldisImage;
    if ([NameU rangeOfString:@"_AVA"].location!=NSNotFound) return CDFieldisAudio;
    if ([NameL rangeOfString:@"_audio"].location!=NSNotFound) return CDFieldisAudio;
    if ([NameL rangeOfString:@"_mp3"].location!=NSNotFound) return CDFieldisAudio;
    if ([NameU rangeOfString:@"_MOV"].location!=NSNotFound) return CDFieldisMovie;
    if ([NameL rangeOfString:@"_movie"].location!=NSNotFound) return CDFieldisMovie;
    if ([NameL rangeOfString:@"_sketch"].location!=NSNotFound) return CDFieldisSketch;
    return 0;
};

-(void)reverse_Editable{
    _isEditable=!_isEditable;
};


-(NSData*)DataWithanObject:(id)anObjec{
        NSData * Data=nil;
        switch (_FieldType) {
            case CDFieldisNULL:
           
                break;
            case CDFieldisAttributedString:
                Data=[(NSAttributedString *)anObjec RTFDFromRange:NSMakeRange(0,[(NSAttributedString *)anObjec length] ) documentAttributes:nil];
                //- (nullable NSData *)RTFDFromRange:(NSRange)range documentAttributes:(NSDictionary<NSAttributedStringDocumentAttributeKey, id> *)dict;
                break;
            case CDFieldisAudio:
                //Data=[(AVAudioPlayer*)anObject ]
                break;
            case CDFieldisMovie:
                
                break;
            case CDFieldisImage:
                
                break;
            case CDFieldisSketch:
                
                break;
            case CDFieldisUnkonwType:
                
                break;

            default:
                
                break;
        }
        return Data;
 
};


-(id)objectFromData:(NSData*)aData{
    
    NSData* DD;
    id Object=nil;
    
    switch (_FieldType) {
        case CDFieldisAttributedString:
            Object=[[NSAttributedString new] initWithRTFD:aData documentAttributes:nil];
            if (Object==nil) {
                //旧版本在头部增加了一个字符。
                DD=[NSData new];
                //[DD appendBytes:&T length:1];//再头部安装了一个类型识别符号。因此本程序可以设定255个类型。
                //[Data getBytes:&T length:1];
                DD=[aData subdataWithRange:NSMakeRange(1,[aData length]-1)];
                Object=[[NSAttributedString new] initWithRTFD:DD documentAttributes:nil];
            }
            break;
        case CDFieldisAudio:
            Object=[[AVAudioPlayer new] initWithData:aData error:nil];
            break;
        case CDFieldisMovie:
            Object=[[AVMovie new] initWithData:aData options:nil];
            break;
        case CDFieldisImage:
            Object=[[NSImage new] initWithData:aData];
            break;
        case CDFieldisSketch:
            Object=@"[Null]";
            break;
        default:
            break;
    }
    return Object;
};



-(CDFieldType)TypeOfanObject:(id)anObject{
    if (anObject==nil) return CDFieldisNULL;
    if([anObject isKindOfClass:[NSNumber class]])
    {
        if ([(NSNumber*)anObject objCType][0]=='q') return CDFieldisNumberInteger;
        return CDFieldisNumberReal;
    }
    if([anObject isKindOfClass:[NSDate class]]) return CDFieldisDate;
    if([anObject isKindOfClass:[NSString class]]) return CDFieldisString;
    
    if([anObject isKindOfClass:[NSAttributedString class]]) return CDFieldisAttributedString;
    if([anObject isKindOfClass:[AVAudioPlayer class]]) return CDFieldisAudio;
    if([anObject isKindOfClass:[AVPlayerItem class]]) return CDFieldisMovie;
    //if([anObject isKindOfClass:[NSImage class]]) return CDFieldisImage;
    //if([anObject isKindOfClass:[CDSketch class]]) return CDFieldisSketch;
    return CDFieldisUnkonwType;
};
-(NSString *)stringOfFiledType{
    switch (_FieldType) {
        case CDFieldisNULL:
            return @"NULL";
            break;
        case CDFieldisNumberInteger:
            return @"int";
        case CDFieldisNumberReal:
            return @"real";
            break;
        case CDFieldisDate:
        case CDFieldisString:
            return @"text";
            break;
        case CDFieldisAttributedString:
        case CDFieldisAudio:
        case CDFieldisMovie:
        case CDFieldisImage:
        case CDFieldisSketch:
            return @"BLOB";
        case CDFieldisUnkonwType:
            break;
        default:
            break;
    }
    return @"NULL";
};


-(BOOL)isTheObject:(id)anObject EqualtoObject:(id)otherObject{
    if (anObject==otherObject) return YES;
    unsigned char T=[self TypeOfanObject:anObject];
    if (T!=[self TypeOfanObject:otherObject]) return NO;
    switch (T) {
        case CDFieldisNULL:
            break;
        case CDFieldisNumberInteger:
        case CDFieldisNumberReal:
            if([(NSNumber *)anObject isEqualToNumber:otherObject]) return YES;
            break;
        case CDFieldisDate:
            if([(NSDate *)anObject isEqualToDate:otherObject]) return YES;
            break;
        case CDFieldisString:
            if([(NSString *)anObject isEqualToString:otherObject]) return YES;
            break;
        case CDFieldisAttributedString:
            break;
        case CDFieldisAudio:
            //[(AVAudioPlayer*)anObject ]
            break;
        case CDFieldisMovie:
            break;
        case CDFieldisImage:
            break;
        case CDFieldisSketch:
            break;
        case CDFieldisUnkonwType:
            break;
        default:
            break;
    }
    return NO;
};
-(id)defaultValueAccordingType{
    switch (_FieldType) {
        case CDFieldisNumberInteger:
            return  [NSNumber numberWithInteger:0];
            break;
        case CDFieldisNumberReal:
            return  [NSNumber numberWithDouble:0];
            break;
        case CDFieldisString:
            return  @"";
            break;
        case CDFieldisDate:
            return  [NSDate date];
            break;
        default:
            return nil;
            break;
    }
};
-(id)StringValueAccordtype:(id)anobjecter withQuoter:(quotertype)quoterLike{
    //确保有值
    id p;
    if (anobjecter==nil) {p=[self defaultValueAccordingType];}else{p=anobjecter;}
    //预备
    NSDateFormatter *theDateMatter=[NSDateFormatter new];
    [theDateMatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
 
    switch (_FieldType) {
        case CDFieldisNumberInteger:
        case CDFieldisNumberReal:
            return  [(NSNumber *)p stringValue];
            break;
        case CDFieldisString:
            return [self quoterString:p withQuoter:quoterLike];
            break;
        case CDFieldisDate:
            return [self quoterString:[theDateMatter stringFromDate:(NSDate*)p] withQuoter:quoterLike];
            break;
        default:
            return nil;
            break;
    }
};
-(NSString *)quoterString:(NSString *)aString withQuoter:(quotertype)quoterLike{
    NSString *S;
    switch (quoterLike) {
        case CDSingleQuoterMakeOn://两头加上单引号；并且转移里面的单引号和双引号；
            S=[aString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            S=[S stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            S=[NSString stringWithFormat:@"'%@'",S];
            return S;
            break;
        case CDSingleQuoterTakeoff://去掉两头的单引号；并且恢复里面转移的单引号和双引号；
            S=[aString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            S=[S stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
            S=[S substringWithRange:NSMakeRange(1, S.length-2)];
            return S;
            break;
        case CDDoubleQuoterMakeOn://两头加上双引号；并且转移里面的双引号；
            S=[aString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            S=[NSString stringWithFormat:@"'%@'",S];
            return S;
            break;
        case CDDoubleQuoterTakeoff://去掉两头的双引号；并且恢复里面转移的双引号；
            S=[aString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            S=[S substringWithRange:NSMakeRange(1, S.length-2)];
            return S;
            break;
        default:
            break;
    }
    return nil;
};

@end
