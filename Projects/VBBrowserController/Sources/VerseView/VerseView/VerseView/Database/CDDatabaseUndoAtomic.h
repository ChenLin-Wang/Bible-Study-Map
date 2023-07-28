//
//  CDDatabaseUndoAtomic.h
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/21.
//

#import <Foundation/Foundation.h>
#import "CDRecord.h"
#import "CDUndomanger.h"
NS_ASSUME_NONNULL_BEGIN

@interface CDDatabaseUndoAtomic : NSObject <CDUndoMangerDeleger>
{
    @private
    CDUndoManger * _UndoManeger;
}
@property (nonatomic) NSMutableArray <CDRecord*>* Records;
-(instancetype)initWithUndomanger:(CDUndoManger *)UndoMang;
@end

NS_ASSUME_NONNULL_END
