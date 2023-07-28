//
//  ViewController.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "ViewController.h"
#import "VBBrowserController.h"

@interface ViewController() <VBBrowserDataSource>

@property VBBrowserController * browserController;
@property (weak) IBOutlet NSView * contentView;

@end

@implementation ViewController


// 具体的关于 VBBrowserController API 的解释，还是去看那三个头文件吧，这里提供一些简单的介绍
- (void)viewDidAppear {
    [super viewDidAppear];
    
    // 仅仅使用这三句代码，便可完成 VBBrowserController 的初始化创建：
    // 1. 创建，并传入代理指针，这里这个代理指的是经文索引数据源，只提供经文索引，即某个实现 VBBrowserDataSource 协议的类实例
    self.browserController = [VBBrowserController newBrowserWithDataSource:self];
    
    // 2. 提供一个 view，以将 BrowserController 嵌入在其中
    [self.browserController showBrowserInView:self.contentView];
    
    // 3. 主动刷新经文显示数据，或不进行这一步，你可以注释这一句。
    [self test];
}

// 这个测试方法中的所有数据都是随便生成的，但无论如何，都保证了 verseIndex 的连续性，如果索引不连续，则程序会崩溃并抛出异常
// 你可以尝试修改索引使其不连续，程序必然崩溃，关于如何检测经文索引的连续性，
// 去查看 VBVerseReference.h 和 VBVerseReference.m 文件 的 -isContinuouslyCompareWith: 方法，那里有默认实现，
// 为了达到你的目的，你应该重写哪个连续检测方法，除非觉得它可用。
- (void)test {
    
    NSMutableArray * testVerses = [NSMutableArray new];
    NSArray * bibleVersions = @[@"SGV", @"CUVS", @"CUVT", @"NKJV", @"NRSV", @"BBE", @"MSG", @"NLT", @"NASB", @"NIV", @"NET"];
    
    NSInteger startIndex = 20;
    
    for(NSInteger i = 0; i < 30; i ++) {
        
        NSInteger randomVersionNum = random() % bibleVersions.count;
        NSMutableArray * curVersions = [NSMutableArray new];
        
        NSMutableArray * curBibleVersions = [NSMutableArray arrayWithArray:bibleVersions];
        for(NSInteger i2 = 0; i2 < randomVersionNum; i2 ++) {
            NSInteger curRandomVersionIndex = random() % curBibleVersions.count;
            [curVersions addObject:curBibleVersions[curRandomVersionIndex]];
            [curBibleVersions removeObjectAtIndex:curRandomVersionIndex];
        }
        
        [testVerses addObject: [[VBVerseReference alloc] initWithVersionMarks:curVersions verseIndex:@(startIndex + i)]];
    }
    
    [self.browserController replaceVerseDatas:testVerses];
    
}

- (IBAction)refreshVerses:(NSButton *)sender {
    [self test];
}


// MARK: - VBBrowserDataSource 协议方法

- (id)verseDataProviderWithBrowser:(VBBrowserController *)browser {
    return @"经文数据数据源，VBBrowserController 模块本身不从中取得任何数据，只将其传到底层的 VBVerseView 手中。这里暂时使用一个字符串，确保 VBBrowserController 模块没有使用到此数据源的任何方法";
}

- (VBVerseReference *)verseWillAppend:(VBBrowserController *)browser currentVerseReference:(VBVerseReference *)curVerseReference requestType:(VBVerseRequestType)requestType {
    if (!curVerseReference) return [[VBVerseReference alloc] initWithVersionMarks:@[@"INIT"] verseIndex:@(20)];
    if (curVerseReference.verseIndex.integerValue <= 0) return NULL;
    if (curVerseReference.verseIndex.integerValue >= 100) return NULL;
    return [[VBVerseReference alloc] initWithVersionMarks:@[@"Append"] verseIndex:@((requestType == VBVerseRequestTypePrevious) ? curVerseReference.verseIndex.integerValue - 1 : curVerseReference.verseIndex.integerValue + 1)];
}


@end
