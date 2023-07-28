//
//  VBWord.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBWord.h"

@interface VBWord() {
    NSNumber * __nullable BPVWNumber_Modified;
    NSString * __nullable POS_Modified;
    NSString * __nullable HebrewWord_Modified;
    NSNumber * __nullable StrongNumber_Modified;
    NSString * __nullable KJVUsages_Modified;
    NSString * __nullable LocalVersion_Modified;
    NSPoint linerPoint_Modified;
    
    BOOL isBPVWNumberModified;
    BOOL isPOSModified;
    BOOL isHebrewWordModified;
    BOOL isStrongNumberModified;
    BOOL isKJVUsagesModified;
    BOOL isLocalVersionModified;
    BOOL isLinerPointModified;
}
@end

@implementation VBWord

@synthesize BPVWNumber = _BPVWNumber;
@synthesize POS = _POS;
@synthesize HebrewWord = _HebrewWord;
@synthesize StrongNumber = _StrongNumber;
@synthesize KJVUsages = _KJVUsages;
@synthesize LocalVersion = _LocalVersion;
@synthesize linerPoint = _linerPoint;


+ (instancetype)newWordWithBPVWNumber:(NSNumber *)BPVWNumber
                                  POS:(NSString *)POS
                           HebrewWord:(NSString *)HebrewWord
                         StrongNumber:(NSNumber *)StrongNumber
                            KJVUsages:(NSString *)KJVUsages
                         LocalVersion:(NSString *)LocalVersion
                           linerPoint:(NSPoint)linerPoint{
    
    
    VBWord * word = [VBWord new];
    
    word->_BPVWNumber = BPVWNumber;
    word->_POS = POS;
    word->_HebrewWord = HebrewWord;
    word->_StrongNumber = StrongNumber;
    word->_KJVUsages = KJVUsages;
    word->_LocalVersion = LocalVersion;
    word->_linerPoint = linerPoint;
    word->isLinerPointModified = false;
    return word;
}

- (BOOL)isNextWord:(VBWord *)word { return self.BPVWNumber.integerValue == word.BPVWNumber.integerValue - 1; }
- (BOOL)isLinerPointModified { return self->isLinerPointModified; }

- (NSString *)description { return [NSString stringWithFormat:@"<VBWord: %@, %@>", self.BPVWNumber, NSStringFromPoint(self.linerPoint)]; }


- (NSNumber *)BPVWNumber    {   if (self->isBPVWNumberModified)     return self->BPVWNumber_Modified;       else return self->_BPVWNumber;      }
- (NSString *)POS           {   if (self->isPOSModified)            return self->POS_Modified;              else return self->_POS;             }
- (NSString *)HebrewWord    {   if (self->isHebrewWordModified)     return self->HebrewWord_Modified;       else return self->_HebrewWord;      }
- (NSNumber *)StrongNumber  {   if (self->isStrongNumberModified)   return self->StrongNumber_Modified;     else return self->_StrongNumber;    }
- (NSString *)KJVUsages     {   if (self->isKJVUsagesModified)      return self->KJVUsages_Modified;        else return self->_KJVUsages;       }
- (NSString *)LocalVersion  {   if (self->isLocalVersionModified)   return self->LocalVersion_Modified;     else return self->_LocalVersion;    }
- (NSPoint)linerPoint       {   if (self->isLinerPointModified)     return self->linerPoint_Modified;       else return self->_linerPoint;      }


//- (void)setBPVWNumber:(NSNumber *)BPVWNumber        { self->isBPVWNumberModified =      ![BPVWNumber isEqualToNumber:self->_BPVWNumber];        self->BPVWNumber_Modified = BPVWNumber;     }
//- (void)setPOS:(NSString *)POS                      { self->isPOSModified =             ![POS isEqualToString:self->_POS];                      self->POS_Modified = POS;                   }
//- (void)setHebrewWord:(NSString *)HebrewWord        { self->isHebrewWordModified =      ![HebrewWord isEqualToString:self->_HebrewWord];        self->HebrewWord_Modified = HebrewWord;     }
//- (void)setStrongNumber:(NSNumber *)StrongNumber    { self->isStrongNumberModified =    ![StrongNumber isEqualToNumber:self->_StrongNumber];    self->StrongNumber_Modified = StrongNumber; }
//- (void)setKJVUsages:(NSString *)KJVUsages          { self->isKJVUsagesModified =       ![KJVUsages isEqualToString:self->_KJVUsages];          self->KJVUsages_Modified = KJVUsages;       }
//- (void)setLocalVersion:(NSString *)LocalVersion    { self->isLocalVersionModified =    ![LocalVersion isEqualToString:self->_LocalVersion];    self->LocalVersion_Modified = LocalVersion; }
- (void)setLinerPoint:(NSPoint)linerPoint           { self->isLinerPointModified =      !NSEqualPoints(linerPoint, self->_linerPoint);          self->linerPoint_Modified = linerPoint;     }

- (BOOL)isModified {
    return
        self->isBPVWNumberModified      ||
        self->isPOSModified             ||
        self->isHebrewWordModified      ||
        self->isStrongNumberModified    ||
        self->isKJVUsagesModified       ||
        self->isLocalVersionModified    ||
        self->isLinerPointModified
    ;
}

- (void)modifySaved {
//    NSLog(@"<----%@: modifySaved", self);           // <- 请暂时保留此 NSLog，若要禁用，请注释，不要删除
    
    if (self->isBPVWNumberModified)     self->_BPVWNumber = self->BPVWNumber_Modified;
    if (self->isPOSModified)            self->_POS = self->POS_Modified;
    if (self->isHebrewWordModified)     self->_HebrewWord = self->HebrewWord_Modified;
    if (self->isStrongNumberModified)   self->_StrongNumber = self->StrongNumber_Modified;
    if (self->isKJVUsagesModified)      self->_KJVUsages = self->KJVUsages_Modified;
    if (self->isLocalVersionModified)   self->_LocalVersion = self->LocalVersion_Modified;
    if (self->isLinerPointModified)     self->_linerPoint = self->linerPoint_Modified;
    
    self->isBPVWNumberModified = false;
    self->isPOSModified = false;
    self->isHebrewWordModified = false;
    self->isStrongNumberModified = false;
    self->isKJVUsagesModified = false;
    self->isLocalVersionModified = false;
    self->isLinerPointModified = false;
}

@end
