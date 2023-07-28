//
//  VBComment.m
//  VerseView
//
//  Created by CL Wang on 4/9/23.
//

#import "VBComment.h"

@interface VBComment() {
    NSNumber * BPVNumber_Modified;
    NSNumber * commentId_Modified;
    NSAttributedString * rtfdString_Modified;
    NSSize size_Modified;
    NSPoint linerPoint_Modified;
    
    BOOL isBPVNumberModified;
    BOOL isCommentIdModified;
    BOOL isRtfdStringModified;
    BOOL isSizeModified;
    BOOL isLinerPointModified;
}

@end

@implementation VBComment
@synthesize BPVNumber = _BPVNumber;
@synthesize commentId = _commentId;
@synthesize rtfdString = _rtfdString;
@synthesize size = _size;
@synthesize linerPoint = _linerPoint;

+ (instancetype)newCommentWithBPVNumber:(NSNumber *) BPVNumber
                              commentId:(NSNumber *) commentId
                             rtfdString:(NSAttributedString *) rtfdString
                                   size:(NSSize) size
                             linerPoint:(NSPoint) linerPoint {
    VBComment * newComment = [VBComment new];
    newComment->_BPVNumber = BPVNumber;
    newComment->_commentId = commentId;
    newComment->_rtfdString = rtfdString;
    newComment->_size = size;
    newComment->_linerPoint = linerPoint;
    
    return newComment;
}

- (BOOL)isSizeModified { return self->isSizeModified; }
- (BOOL)isLinerPointModified { return self->isLinerPointModified; }

- (NSString *)description { return [NSString stringWithFormat:@"<VBComment: %@_%@, %@, %@>", self.BPVNumber, self.commentId, NSStringFromPoint(self.linerPoint), NSStringFromSize(self.size)]; }

- (NSNumber *)BPVNumber                 {   if (self->isBPVNumberModified)      return self->BPVNumber_Modified;    else return self->_BPVNumber;   }
- (NSNumber *)commentId                 {   if (self->isCommentIdModified)      return self->commentId_Modified;    else return self->_commentId;   }
- (NSAttributedString *)rtfdString      {   if (self->isRtfdStringModified)     return self->rtfdString_Modified;   else return self->_rtfdString;  }
- (NSSize)size                          {   if (self->isSizeModified)           return self->size_Modified;         else return self->_size;        }
- (NSPoint)linerPoint                   {   if (self->isLinerPointModified)     return self->linerPoint_Modified;   else return self->_linerPoint;  }

//- (void)setBPVNumber:(NSNumber *)BPVNumber                  {   self->isBPVNumberModified =     ![BPVNumber isEqualToNumber:self->_BPVNumber];                  self->BPVNumber_Modified = BPVNumber;   }
//- (void)setCommentId:(NSNumber *)commentId                  {   self->isCommentIdModified =     ![commentId isEqualToNumber:self->_commentId];                  self->commentId_Modified = commentId;   }
- (void)setRtfdString:(NSAttributedString *)rtfdString      {   self->isRtfdStringModified =    ![rtfdString isEqualToAttributedString:self->_rtfdString];      self->rtfdString_Modified = rtfdString; }
- (void)setSize:(NSSize)size                                {   self->isSizeModified =          !NSEqualSizes(size, self->_size);                               self->size_Modified = size;             }
- (void)setLinerPoint:(NSPoint)linerPoint                   {   self->isLinerPointModified =    !NSEqualPoints(linerPoint, self->_linerPoint);                  self->linerPoint_Modified = linerPoint; }

- (BOOL)isModified {
    return
        self->isBPVNumberModified   ||
        self->isCommentIdModified   ||
        self->isRtfdStringModified  ||
        self->isSizeModified        ||
        self->isLinerPointModified
    ;
}

- (void)modifySaved {
//    NSLog(@"<----%@: modifySaved", self);           // <- 请暂时保留此 NSLog，若要禁用，请注释，不要删除
    
    if (self->isBPVNumberModified)      self->_BPVNumber = self->BPVNumber_Modified;
    if (self->isCommentIdModified)      self->_commentId = self->commentId_Modified;
    if (self->isRtfdStringModified)     self->_rtfdString = self->rtfdString_Modified;
    if (self->isSizeModified)           self->_size = self->size_Modified;
    if (self->isLinerPointModified)     self->_linerPoint = self->linerPoint_Modified;
    
    self->isBPVNumberModified = false;
    self->isCommentIdModified = false;
    self->isRtfdStringModified = false;
    self->isSizeModified = false;
    self->isLinerPointModified = false;
}

@end
