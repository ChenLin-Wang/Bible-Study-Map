//
//  ViewController.m
//  Gesture Research-OC
//
//  Created by CL Wang on 2/6/23.
//

#import "ViewController.h"

@interface ViewController()

@property (strong) NSMutableDictionary *twoFingersTouches;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.view.allowedTouchTypes = NSTouchTypeMaskDirect | NSTouchTypeMaskIndirect;
//    [NSTouch.TouchTypeMask.direct, NSTouch.TouchTypeMask.indirect];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
