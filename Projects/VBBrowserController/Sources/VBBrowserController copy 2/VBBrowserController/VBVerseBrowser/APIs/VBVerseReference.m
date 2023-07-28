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

- (NSArray<NSString *> *)versionMarks { return versionMarks; }

- (NSNumber *)verseIndex { return verseIndex; }

@end
