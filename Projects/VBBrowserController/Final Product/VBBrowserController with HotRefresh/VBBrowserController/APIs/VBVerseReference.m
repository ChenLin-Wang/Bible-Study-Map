//
//  VBVerseReference.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "VBVerseReference.h"

@interface VBVerseReference() {
    NSArray<NSString *> * versionMarks;
    NSNumber * verseIndex;
}


@end

@implementation VBVerseReference


- (VBVerseReference *)initWithVersionMarks:(NSArray<NSString *> *)versionMarks verseIndex:(NSNumber *)verseIndex {
    self = [super init];
    self->versionMarks = versionMarks;
    self->verseIndex = verseIndex;
    return self;
}

- (BOOL)isEqualToVerseRef:(VBVerseReference *)verseRef {
    return
    [self.versionMarks isEqualToArray:verseRef.versionMarks] &&
    [self.verseIndex isEqualToNumber:verseRef.verseIndex];
}

#warning Consider reimplementing this method, then delete this warning.
// 这里暂时如此实现，是为了使 demo 可以顺利进行，要正常使用请重写此方法
- (VBVerseRefCompareResult)isContinuouslyCompareWith:(VBVerseReference *)verseRef {
    // 经文编号不连续
    if (labs(self.verseIndex.integerValue - verseRef.verseIndex.integerValue) != 1) return VBVerseRefCompareResultNotContinuously;
    
    if (self.verseIndex.integerValue > verseRef.verseIndex.integerValue) return VBVerseRefCompareResultDescending;
    else if (self.verseIndex.integerValue < verseRef.verseIndex.integerValue) return VBVerseRefCompareResultAscending;
    
    return VBVerseRefCompareResultNotContinuously;
}

- (NSArray<NSString *> *)versionMarks { return versionMarks; }

- (NSNumber *)verseIndex { return verseIndex; }

- (NSString *)description {
    return [NSString stringWithFormat:@"VBVerseReference: %@", self.verseIndex];
}

@end
