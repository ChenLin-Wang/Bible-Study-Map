//Text(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/)//  CDEditorForWhereas_connect.h
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/21.
// 本模块的任务就是人工编辑参数。提供数据地址、数据库、表格、字段、搜索条件。
// 本不负责数据的合法性。仅仅是一个编辑器。
// 调用本模块，仅有一个接口 -(void)setParameters:(NSArray <NSArray *> *)ADNKUPWOL；
// 当编辑好了以后，用户点击试一下、OK 该编辑器会调用-(void)ParameterYouWant:(NSDictionary*)YourParameters;返回参数。
// 其中的关键字 CDNeedEditing 的 0-7；
// AddressTextClicked 和 GetListForShow... 是一组支持函数。你若不能够实现，那么就只能完全手动编辑。
//



#import <Cocoa/Cocoa.h>
#import "CDSqlite3TableView.h"
#import "CDTextField.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(int, CDNeedEditing)
{
    CDEditorNeedListnothing               =100,
    CDEditorNeedListDataBase              =101,
    CDEditorNeedListTablesName            =102,
    CDEditorNeedListFieldsForSelect       =103,
    CDEditorNeedListFieldsForP_Key        =104,
    CDEditorNeedListFieldsForOrder        =105,
    CDWantsEdinting                       =201,
    CDEditableButNotWants                 =202,
    CDEditorReadOnly                      =203,
    CDAddress_A       =0,
    CDDatabase_D      =1,
    CDTableName_N     =2,
    CDP_Key_K         =3,
    CDUser_U          =4,
    CDPassword_P      =5,
    CDWhereas_W       =6,
    CDOrder_O         =7,
    CDListInTable_L   =8,
};


@protocol CDEditorListForDataDelegate <NSObject>
//如果返回nil，表示有错误。如果返回的是Array count==0，表明没有。
-(NSArray<NSString *> *)getListForShowDatabaseFromAddress:(NSString *)Address byUser:(NSString *)User WithPassWord:(NSString *)Password; 
-(NSArray<NSString *> *)getListForShowTableNameFromDatabase:(NSString *)adatabase Address:(NSString *)Address;
-(NSArray<NSString *> *)getListForShowFieldsFromTable:(NSString *)TableName Database:(NSString *)adatabase Address:(NSString *)Address;
-(NSString *)AddressTextClicked;
//the answers
//-(void)ParameterYouWant:(NSDictionary*)YourParameters;//当点击OK时。ADNKUPWOL为顺序。
@end

@interface CDEditorForWhereas_connect : NSWindowController <CDSqlite3TableViewDataSource,NSTableViewDelegate,CDTextFieldDelegate>
{
    //if doube click textfield database table P_k WhereasField Order
    //那么 ListTableView 就要显示这些数据。如果不够条件，就自动跳转到呵护条件的TextView上。
    @private
    int _WhichContentNeedList;
    NSMutableDictionary* _WantsParameters;
    BOOL _isFirstLine;
//    __block void (^SentResultBack)(NSDictionary *YourParameters);
}
@property(assign) id<CDEditorListForDataDelegate> delegate;

//其中子数组包含三个内容，第一个是在ADNKUPWOL之中的一个字符的分类名，第二是字符型的数字CDNeedEditing，第三个是ID行的字符串或者一个数俎NSArray
-(NSMutableDictionary*)setParameters:(NSArray <NSArray *> *)ADNKUPWOL;

@end

NS_ASSUME_NONNULL_END
