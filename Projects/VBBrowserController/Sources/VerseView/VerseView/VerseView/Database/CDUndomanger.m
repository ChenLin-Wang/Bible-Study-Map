//
//  CDUndomanger.m
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/12/17.
//

#import "CDUndomanger.h"

@implementation CDUndoManger
-(instancetype)initWithSteps:(int)Steps{
    self = [super init];
    if (self) {
        if (Steps>UNDO_MAX)
        _UndoStepsMAX=Steps;
        else
        _UndoStepsMAX=UNDO_MAX;
        _Undo=[NSMutableArray new];
        _Redo=[NSMutableArray new];
    };
    return self;
};

-(int)UndoStepsMax{
    return _UndoStepsMAX;
};

-(void)addDoItWithUndo:(id<CDUndoMangerDeleger>)aDoIt;{
    [_Redo removeAllObjects];
    if (_Undo.count>=_UndoStepsMAX) [_Undo removeObjectAtIndex:0];
    id <CDUndoMangerDeleger> p=[aDoIt DoItWithUndo];
    if (p!=nil) [_Undo addObject:p]; else [NSException raise:@"CDUndomanger" format:@"DoItWithUndo answer nil！"];
};

-(void)Undo{
    if (_Undo.count==0){
        NSBeep();
        return ;
    } else {
        id <CDUndoMangerDeleger> p=[_Undo lastObject];
        [_Undo removeLastObject];
        p=[p DoItWithUndo];
        if (p!=nil) [_Redo addObject:p]; else [NSException raise:@"CDUndomanger" format:@"DoItWithUndo answer nil！"];
    }
};
-(void)Redo{
    if (_Redo.count==0){
        NSBeep();
        return ;
    } else {
        id <CDUndoMangerDeleger> p=[_Redo lastObject];
        [_Redo removeLastObject];
        p=[p DoItWithUndo];
        if (p!=nil) [_Undo addObject:p]; else [NSException raise:@"CDUndomanger" format:@"DoItWithUndo answer nil！"];
    }
};
-(BOOL)canUndo{
    if (_Undo.count>0)
        return YES;
    else
        return NO;
};
-(BOOL)canRedo{
    if (_Redo.count>0)
        return YES;
    else
        return NO;
};
@end
