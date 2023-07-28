//
//  CDTextField.m
//  BibleOriginWordMap
//
//  Created by 唐道延s on 13-6-1.
//  Copyright (c) 2013年 唐道延s. All rights reserved.
//

#import "CDTextField.h"

@implementation CDTextField


//-(void) CDTextFieldClicked:(CDTextField *)textField{
//    [self.delegate CDTextFieldClicked:self];
//};



-(void)mouseDown:(NSEvent *)event {
    _Ndelegate=[self delegate];//这是一个权益的变通。为了适应问题，见CDTextField.h
 
    //仅在双击 左键才反映。
    if ([event type]==1) { //左键
    //若使用控制键就出发一个编辑。
    NSInteger key=[event modifierFlags];
      //& ( key & NSAlternateKeyMask) & (key & NSControlKeyMask))
      if ( key & NSEventModifierFlagCommand) {
          [_Ndelegate CDTextFieldClickedWithCommand:self];
      } else if (event.clickCount >1) {
          [_Ndelegate CDTextFieldDoubleClicked:self];
          return;
      }//拦截event不叫super使用多于一次的左键。
  }
    [super mouseDown:event];
   [_Ndelegate CDTextFieldBecomeFirstResponer:self];
}

@end
