//
//  VBTableView-Categories.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Foundation/Foundation.h>
#import "VBTableView.h"

@interface VBTableView(viewFunctions)

- (void)updateColumnsWithCount:(NSInteger)count;

@end

@interface VBTableView(tableViewProtocols) <NSTableViewDelegate, NSTableViewDataSource>

@end

@interface VBTableView(settings)

- (void)configDefaultValues;
- (void)deploySettings;

@end
