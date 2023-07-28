//
//  View.m
//  Gesture Research-OC
//
//  Created by CL Wang on 2/6/23.
//

#import "View.h"

#define kSwipeMinimumLength 0.2

@interface View()

@property (strong) NSMutableDictionary *twoFingersTouches;

@end

@implementation View

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    self.allowedTouchTypes = NSTouchTypeDirect | NSTouchTypeIndirect;
    // Drawing code here.
}


- (void)touchesBeganWithEvent:(NSEvent *)event{
    [super touchesBeganWithEvent:event];
    NSLog(@"touches");
    if(event.type == NSEventTypeGesture){
        NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
        if(touches.count == 2){
            self.twoFingersTouches = [[NSMutableDictionary alloc] init];

            for (NSTouch *touch in touches) {
                [self.twoFingersTouches setObject:touch forKey:touch.identity];
            }
        }
    }
}


- (void)touchesMovedWithEvent:(NSEvent*)event {
    
    [super touchesMovedWithEvent:event];
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseEnded inView:self];

//    NSLog(@"%d", touches.count);

    if(touches.count > 0){
        NSMutableDictionary *beginTouches = [self.twoFingersTouches copy];
        self.twoFingersTouches = nil;

        NSMutableArray *magnitudes = [[NSMutableArray alloc] init];

        for (NSTouch *touch in touches)
        {
            NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];

            if (!beginTouch) continue;
            
            float magnitude = touch.normalizedPosition.y - beginTouch.normalizedPosition.y;
            [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
        }

        float sum = 0;

        for (NSNumber *magnitude in magnitudes)
            sum += [magnitude floatValue];

        NSLog(@"%f", sum);

        // See if absolute sum is long enough to be considered a complete gesture
        float absoluteSum = fabsf(sum);

        if (absoluteSum < kSwipeMinimumLength) return;

        // Handle the actual swipe
        // This might need to be > (i am using flipped coordinates)
        if (sum > 0){
            NSLog(@"go back");
        }else{
            NSLog(@"go forward");
        }
    }
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    [super touchesEndedWithEvent:event];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event {
    [super touchesCancelledWithEvent:event];
}

@end
