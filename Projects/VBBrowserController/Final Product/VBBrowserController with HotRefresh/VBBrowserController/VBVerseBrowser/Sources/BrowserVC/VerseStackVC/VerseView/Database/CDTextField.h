//
//  CDTextField.h
//  BibleOriginWordMap
//
//  Created by 唐道延s on 13-6-1.
//  Copyright (c) 2013年 唐道延s. All rights reserved.
//  edited on 2020 年
//

#import <Cocoa/Cocoa.h>

@class CDTextField;

@protocol CDTextFieldDelegate <NSTextFieldDelegate>
@optional
//-(void) CDTextFieldClicked:(CDTextField *)textField;//doubleClicked
-(void) CDTextFieldDoubleClicked:(CDTextField *)textField;//doubleClicked
//-(void) CDTextFieldClickedForEdit:(CDTextField *)textField;
-(void) CDTextFieldClickedWithCommand:(CDTextField *)textField;
-(void) CDTextFieldBecomeFirstResponer:(CDTextField *)textField;
@end

@interface CDTextField : NSTextField
@property(assign) id<CDTextFieldDelegate> Ndelegate;//自从升级到11.1 原来的delegate 就不可以使用了。程序自动将这里注释掉了。所以修改了微Ndelegate
@end
