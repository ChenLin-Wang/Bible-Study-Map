//
//  CDDatabaseUndoAtomic.m
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/21.
//

#import "CDDatabaseUndoAtomic.h"
#import <Cocoa/Cocoa.h>

@implementation CDDatabaseUndoAtomic
-(instancetype)initWithUndomanger:(CDUndoManger *)UndoMang{
    self=[super init];
    if (self)
    {
        if (UndoMang==nil) [NSException raise:@"CDDatabaseUndoAtomic initWith" format:@"initWith wrong Undomanger with nil!"];
        _UndoManeger=UndoMang;
        _Records=[NSMutableArray new];
    };
    return self;
};

- (nonnull id<CDUndoMangerDeleger>)DoItWithUndo {
    CDDatabaseUndoAtomic *newUndoAtomic=[[CDDatabaseUndoAtomic alloc] initWithUndomanger:_UndoManeger];
    NSMutableArray * newRecords=[NSMutableArray new];
    CDRecord * UndoREC;
    for (int i=0; i<[_Records count]; i++) {
        UndoREC=[[_Records objectAtIndex:i] saveToDatabaseWithUndo];
        if (UndoREC.error!=nil) {
            //只要发现一条不成立，就要全部撤销。并且不得加入Undo。
            for (NSUInteger j=0; j<[newRecords count]; j++) {
                NSBeep();
                UndoREC=[[_Records objectAtIndex:i] saveToDatabaseWithUndo];
                if (UndoREC.error==nil) [NSException raise:@"CDDatabaseUndoAtomic" format:@"saveToDatabaseWithUndo 存在错误！"];
            };
            return  nil;//i+1;//表明出错的地方
        }else{
            [newRecords addObject:UndoREC];
        };
    }
    [newUndoAtomic setRecords:newRecords];
    return newUndoAtomic;
}

@end
