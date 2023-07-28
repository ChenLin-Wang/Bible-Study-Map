//
//  VBFreezingBarDelegate.h
//  VBBrowserController
//
//  Created by CL Wang on 5/24/23.
//

#ifndef VBPrivateDefines_h
#define VBPrivateDefines_h

@class VBVerseReference;

@protocol VBFreezingBarDelegate <NSObject>

- (void)translationVersionDidChangeAtVerseRef:(VBVerseReference *)verseRef newVersion:(NSString *)newVersion;
- (void)translationDidChangeWithVersion:(NSString *)version newContent:(NSString *)newContent verseRef:(VBVerseReference *)verseRef;

@end

#endif /* VBPrivateDefines_h */
