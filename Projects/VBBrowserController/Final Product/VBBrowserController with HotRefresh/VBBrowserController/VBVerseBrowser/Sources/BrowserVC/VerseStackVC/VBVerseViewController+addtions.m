//
//  VBVerseViewController+addtions.m
//  VBBrowserController
//
//  Created by CL Wang on 3/14/23.
//

#import "VBVerseViewController+addtions.h"
#import <objc/runtime.h>

static const NSString * isNewVC_Key = @"VBBrowserController.VBVerseViewController.Property.Key.IsNewVC";
static const NSString * contentSize_Key = @"VBBrowserController.VBVerseViewController.Property.Key.ContentSize";
static const NSString * isInitialized_Key = @"VBBrowserController.VBVerseViewController.Property.Key.IsInitialized";

@implementation VBVerseViewController (addtions)

- (void)setIsNewVC:(BOOL)isNewVC {
    objc_setAssociatedObject(self, &isNewVC_Key, @(isNewVC), OBJC_ASSOCIATION_COPY);
}

- (BOOL)isNewVC {
    return ((NSNumber *)objc_getAssociatedObject(self,  &isNewVC_Key)).boolValue;
}

- (void)setContentSize:(NSSize)contentSize {
    objc_setAssociatedObject(self, &contentSize_Key, @(contentSize), OBJC_ASSOCIATION_COPY);
}

- (NSSize)contentSize {
    return ((NSValue *)objc_getAssociatedObject(self,  &contentSize_Key)).sizeValue;
}

- (void)setIsInitialized:(BOOL)isInitialized {
    objc_setAssociatedObject(self, &isInitialized_Key, @(isInitialized), OBJC_ASSOCIATION_COPY);
}

- (BOOL)isInitialized {
    return ((NSNumber *)objc_getAssociatedObject(self,  &isInitialized_Key)).boolValue;
}

@end
