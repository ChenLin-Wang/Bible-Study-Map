//
//  ViewController.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "ViewController.h"
#import "VBVerseViewController.h"

@interface ViewController()

@property VBVerseViewController * verseViewController;
@property NSNumber * BPVNum;

@end

@implementation ViewController
@synthesize BPVNum = BPVNum;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.BPVNum = @(1001001);
    
    // Do any additional setup after loading the view.
}

- (void)setBPVNum:(NSNumber *)BPVNum {
    self->BPVNum = BPVNum;
    self.verseViewController.verseReference = [[VBVerseReference alloc] initWithVersionMarks:@[] verseIndex:self.BPVNum];
}

- (NSNumber *)BPVNum {
    return self->BPVNum;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"VBVerseVC"]) {
        self.verseViewController = segue.destinationController;
    }
}

@end
