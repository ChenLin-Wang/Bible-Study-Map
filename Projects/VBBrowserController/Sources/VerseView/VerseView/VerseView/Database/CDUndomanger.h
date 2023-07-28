//
//  CDUndomanger.h
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/12/17.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, CDUndoMangerMAX) {
    UNDO_MAX   =20
};

@protocol CDUndoMangerDeleger <NSObject>
-(id<CDUndoMangerDeleger>)DoItWithUndo;//返回一个逆向操作的类指针
@end

@interface CDUndoManger : NSObject
{
    @private
    NSMutableArray <id<CDUndoMangerDeleger>>* _Undo;
    NSMutableArray <id<CDUndoMangerDeleger>>* _Redo;
    int _UndoStepsMAX;//默认20次
}
-(instancetype)initWithSteps:(int)Steps;//设置最大可撤销步数
-(int)UndoStepsMax;
-(void)addDoItWithUndo:(id<CDUndoMangerDeleger>)aDoIt;//将具有 CDUndoMangerDeleger 协议的类指针交付给他。

-(void)Undo;//if empty nsbeep()
-(void)Redo;//if empty nsbeep()
-(BOOL)canUndo;
-(BOOL)canRedo;

@end

NS_ASSUME_NONNULL_END
