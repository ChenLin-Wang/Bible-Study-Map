//
//  CDEditorForWhereas_connect.m
//  BibleStudyMap
//
//  Created by 唐道延s on 2020/10/21.
//

#import "CDEditorForWhereas_connect.h"


@interface CDEditorForWhereas_connect ()
{
    NSArray <NSString*>* _ListInTable;
};
@property (weak) IBOutlet NSTableView * TableViewForList;
@property (weak) IBOutlet CDTextField *AddressTEXT;
@property (weak) IBOutlet NSTextField *UserTEXT;
@property (weak) IBOutlet NSSecureTextField *PWTEXT;

//TextForDatabase,TextForTableName,TextForP_key,TextForWhereAS,TextForOrder
@property (weak) IBOutlet CDTextField *DatabaseTEXT;
@property (weak) IBOutlet CDTextField *TableTEXT;
@property (weak) IBOutlet CDTextField *P_KeyTEXT;
@property (weak) IBOutlet CDTextField *WhereASTEXT;
@property (weak) IBOutlet CDTextField *OrderTEXT;

@property (unsafe_unretained) IBOutlet NSTextView *WhereAsBox;


@property (weak) IBOutlet NSComboBoxCell *WhereasAndCombox;
@property (weak) IBOutlet NSComboBoxCell *WhereasNotCombox;
@property (weak) IBOutlet NSComboBoxCell *WhereasIsLikeComBox;
@property (weak) IBOutlet NSTextField *WhereasValueText;

//window 指示editorwindow


@end

@implementation CDEditorForWhereas_connect

-(id)init{
    self= [super initWithWindowNibName: @"CDEditorForWhereas_connect"];
    _WhichContentNeedList=CDEditorNeedListnothing;
    _WantsParameters=[NSMutableDictionary new];
    _isFirstLine=YES;
    [self loadWindow]; //如果没有这一条使得Nib中的IBOutlet连接起来，不然CDTextField指针都是空的。
    [[self window] orderOut:nil];
    return self;
};
- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

//TableViewForList single click
//-(void)DoubleClickedAtTableColumnInTableView:self onRow:row withTableColumn:[[self tableColumns] objectAtIndex:column]];

-(void)LeftDeeperClickedInTableView:(CDSqlite3TableView*)aTableView onRow:(NSInteger)rowIndex onTableColumn:(NSTableColumn *)aTableColumn{
    NSLog(@"double clicked on row=%ld",(long)rowIndex);
    return ;
};
-(void)LeftLighterClickedInTableView:(CDSqlite3TableView *)aTableView onRow:(NSInteger)rowIndex onTableColumn:(NSTableColumn *)aTableColumn{
    NSString *valueOnrow=[_ListInTable objectAtIndex:rowIndex];
    //NSLog(@"single clicked %@ on row=%ld when %d",valueOnrow ,(long)rowIndex,_WhichContentNeedList);
    
    switch (_WhichContentNeedList) {
        case CDEditorNeedListnothing:
                
            break;
        case CDEditorNeedListDataBase:
            [_DatabaseTEXT setStringValue:valueOnrow];
            break;
        case CDEditorNeedListTablesName:
            [_TableTEXT setStringValue:valueOnrow];
            break;
        case CDEditorNeedListFieldsForP_Key:
            [_P_KeyTEXT setStringValue:valueOnrow];
            break;
        case CDEditorNeedListFieldsForSelect:
            [_WhereASTEXT setStringValue:valueOnrow];
            break;
        case CDEditorNeedListFieldsForOrder:
            [_OrderTEXT setStringValue:valueOnrow];
            break;

        default:
            break;
    };
};
-(void)RightDeeperClickedInTableView:(CDSqlite3TableView*)aTableView onRow:(NSInteger)rowIndex onTableColumn:(NSTableColumn *)aTableColumn{
    //NSString *a=@"asdf";
    return ;
};
-(void)RightLighterClickedInTableView:(CDSqlite3TableView*)aTableView onRow:(NSInteger)rowIndex onTableColumn:(NSTableColumn *)aTableColumn{
    //NSString *a=@"asdf";
    return ;
};
//
-(NSInteger)numberOfColumnsInTableView:(NSTableView *)aTableView{
    return 1;
};
-(NSArray *)nameOfColumnInTableView:(NSTableView *)aTableView
                    numberOfColumns:(NSInteger)Columns;{
    switch (_WhichContentNeedList) {
        case CDEditorNeedListnothing:
            return [[NSArray alloc] initWithObjects:@"提示 警告", nil];
            break;
        case CDEditorNeedListDataBase:
            return [[NSArray alloc] initWithObjects:@"Databases", nil];
            break;
        case CDEditorNeedListTablesName:
            return [[NSArray alloc] initWithObjects:@"TablesName", nil];
            break;
        case CDEditorNeedListFieldsForSelect:
            return [[NSArray alloc] initWithObjects:@"FieldsForSelect", nil];
            break;
        case CDEditorNeedListFieldsForP_Key:
            return [[NSArray alloc] initWithObjects:@"FieldsForP_Key", nil];
            break;
        case CDEditorNeedListFieldsForOrder:
            return [[NSArray alloc] initWithObjects:@"FieldsForOrder", nil];
            break;

        default:
            break;
    };
    return [[NSArray alloc] initWithObjects:@"参数出错了", nil];
};

-(NSArray *)WidthofColumnsInTableView:(NSTableView *)aTableView
                      numberOfColumns:(NSInteger)Columns;{
    return nil;
};




//support for listEdit TableView
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (_ListInTable==nil) return 0;
    return [_ListInTable count];
};
//-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row//tablView content mode= view based
//{
//    NSTableCellView *m=[tableView makeViewWithIdentifier:@"TBV" owner:nil];
//    [[m textField] setStringValue:@"1234"];
//    return m;
//};
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex//tablView content mode= cell based
{
    return [_ListInTable objectAtIndex:rowIndex];
};

//TextForDatabase,TextForTableName,TextForP_key,TextForSelect,TextForOrder,
-(void) CDTextFieldDoubleClicked:(CDTextField *)textField{
    NSString *Filedidentifier=[textField identifier];
    NSString *A=[_AddressTEXT stringValue];
    if ([Filedidentifier isEqualToString:@"TextForAddress"]){
        [_AddressTEXT setStringValue:[_delegate AddressTextClicked]];
        return;
    };
    NSCharacterSet*ChS=[NSCharacterSet characterSetWithCharactersInString:@" "];
    [A stringByTrimmingCharactersInSet:ChS];
    if ([A isEqualToString:@""]) A=nil;
    NSString *U=[_UserTEXT stringValue];
    [U stringByTrimmingCharactersInSet:ChS];
    if ([U isEqualToString:@""] ) U=nil;
    NSString *P=[_PWTEXT stringValue];
    [P stringByTrimmingCharactersInSet:ChS];
    if ([P isEqualToString:@""]) P=nil;
    if ([Filedidentifier isEqualToString:@"TextForDatabase"]){
        _ListInTable=[_delegate getListForShowDatabaseFromAddress:A byUser:U WithPassWord:P];
        _WhichContentNeedList=CDEditorNeedListDataBase;
        if (_ListInTable==nil | [_ListInTable count]==0) {
            _ListInTable =[NSArray arrayWithObjects:@"没有提到数据库",@"可能地址错误",nil];
            _WhichContentNeedList=CDEditorNeedListnothing;
        }
        [_TableViewForList reloadData];
        return;
    };//doubleClicked;
    NSString *D=[_DatabaseTEXT stringValue];
    [D stringByTrimmingCharactersInSet:ChS];
    if ([D isEqualToString:@""])
                D=nil;
    if ([Filedidentifier isEqualToString:@"TextForTableName"]){
        _ListInTable=[_delegate getListForShowTableNameFromDatabase:D Address:A];
        _WhichContentNeedList=CDEditorNeedListTablesName;
        if (_ListInTable==nil | [_ListInTable count]==0) {
            _ListInTable =[NSArray arrayWithObjects:@"没有提到数据库",@"可能地址错误",nil];
            _WhichContentNeedList=CDEditorNeedListnothing;
        }
        [_TableViewForList reloadData];
        return;
    };//doubleClicked TextForTableName;
    //only 5 case.
    NSString *T=[_TableTEXT stringValue];
    [T stringByTrimmingCharactersInSet:ChS];
    _ListInTable=[_delegate getListForShowFieldsFromTable:T Database:D Address:A];
    if (_ListInTable==nil | [_ListInTable count]==0) {
        _ListInTable =[NSArray arrayWithObjects:@"没有提到数据库",@"可能地址错误",nil];
        _WhichContentNeedList=CDEditorNeedListnothing;
    };
    if ([Filedidentifier isEqualToString:@"TextForP_key"]) _WhichContentNeedList=CDEditorNeedListFieldsForP_Key;
    if ([Filedidentifier isEqualToString:@"TextForWhereAS"]) _WhichContentNeedList=CDEditorNeedListFieldsForSelect;
    if ([Filedidentifier isEqualToString:@"TextForOrder"]) _WhichContentNeedList=CDEditorNeedListFieldsForOrder;
        [_TableViewForList reloadData];
        return;
};

-(void)CDTextFieldBecomeFirstResponer:(CDTextField *)textField{}

;
- (void)CDTextFieldClickedWithCommand:(CDTextField *)textField {
    int i=0;
    return;
}


- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    int i=0;
    return;
}

- (IBAction)PlusButtonClicked:(id)sender {
    //获取字体的名字测试
    //NSString * N=[[[[_WhereAsBox textStorage] fontAttributesInRange:NSMakeRange(0, [[_WhereAsBox textStorage] length])] objectForKey:@"NSFont"] fontName];
    //@"HannotateSC-W5"
    //PingFangSC-Regular, @"PingFangSC-Ultralight",@"PingFangSC-Thin",@"PingFangSC-Light",@"PingFangSC-Medium",@"PingFangSC-Semibold"
    NSDictionary * FontOfData=@{NSForegroundColorAttributeName:[NSColor blueColor],NSFontAttributeName:[NSFont fontWithName:@"PingFangSC-Light" size:14.0]};
    NSDictionary * FontOfValue=@{NSForegroundColorAttributeName:[NSColor redColor],NSFontAttributeName:[NSFont fontWithName:@"PingFangSC-Light" size:14.0]};
    NSDictionary * FontofKeyWord=@{NSForegroundColorAttributeName:[NSColor blackColor],NSFontAttributeName:[NSFont fontWithName:@"PingFangSC-Semibold" size:14.0]};
    if ([[[_WhereAsBox textStorage] string] length]>0)
    {
        _isFirstLine=NO;
    }else {
        _isFirstLine=YES;};
    NSMutableAttributedString* A = [NSMutableAttributedString new];
    NSCharacterSet*ChS=[NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString * Tand;
    if (!_isFirstLine) {
        Tand =[[_WhereasAndCombox stringValue] stringByTrimmingCharactersInSet:ChS];
        if (![Tand isEqualToString:@""] && Tand!=nil) {
            [A appendAttributedString:[[NSAttributedString alloc] initWithString:Tand attributes:FontofKeyWord]];
        }else{
            [A appendAttributedString:[[NSAttributedString alloc] initWithString:@"and" attributes:FontofKeyWord]];
        };
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:FontOfData]];
    }
        Tand =[[_WhereasNotCombox stringValue] stringByTrimmingCharactersInSet:ChS];
    if (![Tand isEqualToString:@""] && Tand!=nil) {
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:Tand attributes:FontofKeyWord]];
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:FontOfData]];
    };
    Tand =[[_WhereASTEXT stringValue] stringByTrimmingCharactersInSet:ChS];
    if (![Tand isEqualToString:@""] && Tand!=nil) {
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:Tand attributes:FontOfData]];
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:FontOfData]];
    }else {
        NSBeep();
        [_WhereASTEXT becomeFirstResponder];
        return;
    };
    Tand =[[_WhereasIsLikeComBox stringValue] stringByTrimmingCharactersInSet:ChS];
    if (![Tand isEqualToString:@""] && Tand!=nil) {
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:Tand attributes:FontofKeyWord]];
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:FontOfData]];
    }else {
        [NSException raise:@"CDEditorForWhereas_connect" format:@"WhereasIsLikeComBox  Emppty"];
    };
    Tand =[[_WhereasValueText stringValue] stringByTrimmingCharactersInSet:ChS];
    if (![Tand isEqualToString:@""] && Tand!=nil) {
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:Tand attributes:FontOfValue]];
        [A appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:FontOfData]];
    }else {
        NSBeep();
        [_WhereasValueText becomeFirstResponder];
        return;
    };
    [[_WhereAsBox textStorage] appendAttributedString:A];
}
    
 
- (IBAction)TryButtonClicked:(id)sender {
    // 检查编辑有效，查询但不关闭窗口
    //    CDAddress_A       =0,
    //    CDDatabase_D      =1,
    //    CDTableName_N     =2,
    //    CDP_Key_K         =3,
    //    CDUser_U          =4,
    //    CDPassword_P      =5,
    //    CDWhereas_W       =6,
    //    CDOrder_O         =7,
    if ([_WantsParameters objectForKey:@"CDAddress_A"]!=nil) {
        if (![self isReadyForneed:_AddressTEXT Key:@"CDAddress_A"]) return ; };
    if ([_WantsParameters objectForKey:@"CDDatabase_D"]!=nil) {
        if (![self isReadyForneed:_DatabaseTEXT Key:@"CDDatabase_D"]) return ; };
    if ([_WantsParameters objectForKey:@"CDTableName_N"]!=nil) {
        if (![self isReadyForneed:_TableTEXT Key:@"CDTableName_N"]) return ;};;
    if ([_WantsParameters objectForKey:@"CDP_Key_K"]!=nil){
        if (![self isReadyForneed:_P_KeyTEXT Key:@"CDP_Key_K"]) return ;};;
    if ([_WantsParameters objectForKey:@"CDUser_U"]!=nil){
        if (![self isReadyForneed:_UserTEXT Key:@"CDUser_U"]) return ;};;
    if ([_WantsParameters objectForKey:@"CDPassword_P"]!=nil){
        if (![self isReadyForneed:_PWTEXT Key:@"CDPassword_P"]) return ;};;
    if ([_WantsParameters objectForKey:@"CDWhereas_W"]!=nil) [_WantsParameters setValue:[NSString stringWithString: [[_WhereAsBox textStorage] string]] forKey:@"CDWhereas_W"];
    if ([_WantsParameters objectForKey:@"CDOrder_O"]!=nil){
        if (![self isReadyForneed:_OrderTEXT Key:@"CDOrder_O"]) return ;};
}

-(BOOL)isReadyForneed:(NSTextField*)TheTextField Key:(NSString*)K{
    NSString *S;
    if ([_WantsParameters objectForKey:K]!=nil) {
        S=[TheTextField stringValue];
        if (S!=nil&[S length]!=0) {
            [_WantsParameters setValue:S forKey:K];
            return YES;
        }
    };
    NSBeep();
    [TheTextField becomeFirstResponder];
    return NO;
};

- (IBAction)OKButtonClicked:(id)sender {
    //执行查询同时关闭窗口
    //[[self window] orderOut:nil];
    [self TryButtonClicked:nil];
    [self CancelButtonClicked:nil];
}

- (IBAction)CancelButtonClicked:(id)sender {
    //停止编辑，关闭窗口
    if ([NSApp modalWindow]==[self window])
        [NSApp  stopModal];// 从这里退回到 NSInteger retval=[NSApp runModalForWindow:myEditor]; //一旦设定runModalForWindowm模式那么就必须要等到
     [[self window] orderOut:nil];
}

-(NSMutableDictionary*)setParameters:(NSArray<NSArray*>*)ADNKUPWOL
{
    //NSArray with (项目，动作，内容 )
//    CDWantsEdinting                       =201,
//    CDEditableButNotWants                 =202,
//    CDEditorReadOnly                      =203,
//    CDAddress_A       =0,
//    CDDatabase_D      =1,
//    CDTableName_N     =2,
//    CDP_Key_K         =3,
//    CDUser_U          =4,
//    CDPassword_P      =5,
//    CDWhereas_W       =6,
//    CDOrder_O         =7,
//    CDListInTable_L   =8,
  
    [[self window] orderFront:nil];
    [_WantsParameters removeAllObjects];
    NSString * Key=@"ADNKUPWOL";
    NSString * D=nil;
    int N=0;
    for (NSArray *Subjt in ADNKUPWOL) {
        
        N=[[Subjt objectAtIndex:1] intValue];
        switch ([Key rangeOfString:[Subjt objectAtIndex:0]].location) {
            case CDAddress_A:
                [self setEditBox:_AddressTEXT Value:[Subjt objectAtIndex:2] option:N key:@"CDAddress_A"];
                 break;
            case CDDatabase_D:
                [self setEditBox:_DatabaseTEXT Value:[Subjt objectAtIndex:2] option:N key:@"CDDatabase_D"];
                break;
            case CDTableName_N:
                [self setEditBox:_TableTEXT Value:[Subjt objectAtIndex:2] option:N key:@"CDTableName_N"];
                break;
            case CDP_Key_K:
                [self setEditBox:_P_KeyTEXT Value:[Subjt objectAtIndex:2] option:N key:@"CDP_Key_K"];
                break;
            case CDUser_U:
                [self setEditBox:_UserTEXT Value:[Subjt objectAtIndex:2] option:N key:@"CDUser_U"];
                break;
            case CDPassword_P:
                [self setEditBox:_PWTEXT Value:[Subjt objectAtIndex:2] option:N key:@"CDPassword_P"];
                break;
            case CDWhereas_W:
                D=[Subjt objectAtIndex:2];
                if (D!=nil) [ _WhereAsBox setString:D];
                if (N==CDWantsEdinting) [_WantsParameters setValue:D forKey:@"CDWhereas_W"];
                break;
            case CDOrder_O:
                [self setEditBox:_OrderTEXT Value:[Subjt objectAtIndex:2] option:N key:@"CDOrder_O"];
                break;
            case CDListInTable_L:
                _WhichContentNeedList=N;
                _ListInTable=[Subjt objectAtIndex:2];
                [_TableViewForList reloadData];
                break;

            default:
                [NSException raise:@"CDEditorForWhereas_connect" format:@"setParametersNow Subject character is wrang!"];
                break;
        }
    };
    
    NSWindow *myEditor=[self window];
    [myEditor makeKeyWindow];
    NSInteger retval=[NSApp runModalForWindow:myEditor]; //一旦设定runModalForWindowm模式那么就必须要等到  [NSApp  stopModal]; 结束之后。
   // [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    return _WantsParameters;
};

-(void) setEditBox:(NSTextField *)_TextBox Value:(NSString*)D option:(int)N key:(NSString*)K {
    if (D!=nil)  [_TextBox setStringValue:D];
    if (N==CDWantsEdinting) [_WantsParameters setValue:D forKey:K];
    if (N==CDEditorReadOnly) {
        [_TextBox setEditable:NO];
    }else {
        [_TextBox setEditable:YES];
    }
};


//-(void)windowDidBecomeKey:(NSNotification *)notification{
//    NSWindow *W=[notification object];
//    if ([[W identifier] isEqualToString:@"DatabaseEditor"]){
//        if (_windowisLoaded==1) {
//            _windowisLoaded=2;
//            if ([_Adnkupwol count]>0) [self setParametersNow:_Adnkupwol];
//        };
//    }
//};
@end
