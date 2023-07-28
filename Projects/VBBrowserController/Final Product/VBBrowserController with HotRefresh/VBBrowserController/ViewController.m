//
//  ViewController.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "ViewController.h"
#import "VBBrowserController.h"
#import "CDSQLite3OperaterDelegate.h"

@interface ViewController() <VBBrowserDataSource>

@property VBBrowserController * browserController;
@property (weak) IBOutlet NSView * contentView;
@property CDSQLite3OperaterDelegate * dataOperator;
@property NSNumber * verseIndex;

@end

@implementation ViewController
@synthesize verseIndex = verseIndex;

// 具体的关于 VBBrowserController API 的解释，还是去看那三个头文件吧，这里提供一些简单的介绍
- (void)viewDidLoad {
    self.verseIndex = @(1001001);
    
    // 连接到数据库
    [self connectToDatabase];
    
    // 仅仅使用这三句代码，便可完成 VBBrowserController 的初始化创建：
    // 1. 创建，并传入代理指针，这里这个代理指的是经文索引数据源，只提供经文索引，即某个实现 VBBrowserDataSource 协议的类实例
    self.browserController = [VBBrowserController newBrowserWithDataSource:self];
    
    // 2. 提供一个 view，以将 BrowserController 嵌入在其中
    [self.browserController showBrowserInView:self.contentView];
    
    // 3. 主动刷新经文显示数据
//    [self test];                // <-  这个是测试方法，可以使用它进行批量测试
    [self refreshWithVerseIndex:self.verseIndex];
    
}

// 连接到数据库
- (void)connectToDatabase {
    NSString * databaseAddress = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/NewBibleStudy/database"];

    self.dataOperator = [CDSQLite3OperaterDelegate new];
    CDdataOperaterError connectErr = [_dataOperator connectDataBasewithAddress: databaseAddress
                                                         withDatabase: @"BibleDataBase.sqlite"
                                                               byUser: @""
                                                          andPassword: @""];

    // 检查数据库连接状态
    if (connectErr != CDIDU_sucsess) { NSLog(@"数据库连接失败！错误号为 %d", connectErr); return; }
    NSLog(@"数据库连接成功");
}

- (void)refreshWithVerseIndex:(NSNumber *)verseIndex {
    NSArray * bibleVersions = @[@"SGV", @"CUVS", @"CUVT", @"NKJV", @"NRSV", @"BBE", @"MSG", @"NLT", @"NASB", @"NIV", @"NET"];
    [self.browserController replaceVerseDatas:@[
        [[VBVerseReference alloc] initWithVersionMarks:bibleVersions verseIndex:self.verseIndex],
        [[VBVerseReference alloc] initWithVersionMarks:bibleVersions verseIndex:@(self.verseIndex.integerValue + 1)]
    ]];
}

// 这个测试方法中的所有数据都是随便生成的，但无论如何，都保证了 verseIndex 的连续性，如果索引不连续，则程序会崩溃并抛出异常
// 你可以尝试修改索引使其不连续，程序必然崩溃，关于如何检测经文索引的连续性，
// 去查看 VBVerseReference.h 和 VBVerseReference.m 文件 的 -isContinuouslyCompareWith: 方法，那里有默认实现，
// 为了达到你的目的，你应该重写哪个连续检测方法，除非觉得它可用。
- (void)test {
    
    NSMutableArray * testVerses = [NSMutableArray new];
    NSArray * bibleVersions = @[@"SGV", @"CUVS", @"CUVT", @"NKJV", @"NRSV", @"BBE", @"MSG", @"NLT", @"NASB", @"NIV", @"NET"];
    
    NSInteger startIndex = self.verseIndex.integerValue;
    
    for(NSInteger i = 0; i < 2; i ++) {
        
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

- (IBAction)refreshVerses:(NSButton *)sender { [self test]; }
- (NSNumber *)verseIndex { return self->verseIndex; }

- (void)setVerseIndex:(NSNumber *)verseIndex {
    self->verseIndex = verseIndex;
    [self refreshWithVerseIndex:verseIndex];
}

// MARK: - VBBrowserDataSource 协议方法

- (id)verseDataProviderWithBrowser:(VBBrowserController *)browser {
//    return @"经文数据数据源，VBBrowserController 模块本身不从中取得任何数据，只将其传到底层的 VBVerseView 手中。这里暂时使用一个字符串，确保 VBBrowserController 模块没有使用到此数据源的任何方法";
    // 此处提供数据库指针
    return self.dataOperator;
}

// 在此处判断是否应该追加，如果反回 nil 表示不应当再追加了，已经到底了
// 此处应当查询数据库，看经文是否到头了，这里只是做了个演示，并没有调用数据库
- (VBVerseReference *)verseWillAppend:(VBBrowserController *)browser currentVerseReference:(VBVerseReference *)curVerseReference requestType:(VBVerseRequestType)requestType {
    if (curVerseReference.verseIndex.integerValue <= self.verseIndex.integerValue) return NULL;
    if (curVerseReference.verseIndex.integerValue >= self.verseIndex.integerValue + 49) return NULL;
    return [[VBVerseReference alloc] initWithVersionMarks:@[@"SGV", @"CUVS", @"CUVT", @"NKJV", @"NRSV", @"BBE", @"MSG", @"NLT", @"NASB", @"NIV", @"NET"] verseIndex:@((curVerseReference == NULL) ? 0 : ((requestType == VBVerseRequestTypePrevious) ? curVerseReference.verseIndex.integerValue - 1 : curVerseReference.verseIndex.integerValue + 1))];
}

- (void)translationShouldChange:(VBBrowserController *)browser verseReference:(VBVerseReference *)verseReference bibleVersion:(NSString *)bibleVersion newTranslationContent:(NSString *)newTranslationContent {
    NSLog(@"经文<%@>翻译改动，新翻译为: \"%@\"; 版本为: \"%@\"", verseReference.verseIndex, newTranslationContent, bibleVersion);
}

- (void)bibleVersionDidChange:(VBBrowserController *)browser verseReference:(VBVerseReference *)verseReference newBibleVersion:(NSString *)newBibleVersion {
    NSLog(@"经文<%@>的版本被切换，新版本为: \"%@\"", verseReference.verseIndex, newBibleVersion);
}


@end
