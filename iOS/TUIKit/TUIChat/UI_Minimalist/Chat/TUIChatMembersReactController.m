//
//  TUIChatMembersReactController.m
//  TUIChat
//
//  Created by wyl on 2022/10/31.
//

#import "TUIChatMembersReactController.h"
#import "TUIChatMembersSegementScrollView.h"
#import "TUIEmojiCellData.h"
#import "TUIEmojiCell.h"
#import "TUILogin.h"
#import "TUIChatModifyMessageHelper.h"
#import "TUIMessageDataProvider_Minimalist.h" //-->provier
#import "TUIMessageCell.h"

@implementation TUIChatMembersReactSubController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configTableView];
    }
    return self;
}

- (void)configTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TUIEmojiCell class] forCellReuseIdentifier:@"TUIEmojiCell"];

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    @weakify(self);

    [RACObserve(self.view, frame) subscribeNext:^(id  _Nullable frame) {
        @strongify(self);
        self.tableView.frame = self.view.bounds;
    }];
}

- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray arrayWithCapacity:3];
    }
    return _data;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    TUIEmojiCellData *data = self.data[indexPath.section];
    return data.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TUIEmojiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUIEmojiCell"];
    if (cell == nil) {
        cell = [[TUIEmojiCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TUIEmojiCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [cell fillWithData:self.data[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIEmojiCellData * data =  self.data[indexPath.row];
    if (data.isCurrentUser) {
        V2TIMMessage *originData = self.originData.innerMessage;
        [[TUIChatModifyMessageHelper defaultHelper] modifyMessage:originData reactEmoji:data.emojiName];
    }
}

@end

@interface TUIChatMembersReactController () <V2TIMAdvancedMsgListener,TUIMessageBaseDataProviderDataSource>

@property (nonatomic,strong)TUIChatMembersSegementScrollView *scrollview;

@property (nonatomic,strong) TUIMessageDataProvider_Minimalist *provider;

@property (nonatomic,strong) NSMutableArray *tabItems;

@property (nonatomic,strong) NSMutableArray *tabPageVCArray;

@end

@implementation TUIChatMembersReactController

- (instancetype)initWithChatConversationModel:(TUIChatConversationModel *) conversationData {
    if (self = [super init]) {
        [self setConversation:conversationData];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNormalBottom];
    [self registerTUIKitNotification];
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    [self dealData];
    
    [self reloadData];
}

- (void)updateSubContainerView {
    [super updateSubContainerView];
    
    self.scrollview.frame = CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height - self.topGestureView.frame.size.height);
    
    [self.scrollview updateContainerView];
    
}

- (void)setConversation:(TUIChatConversationModel *)conversationData
{
    self.conversationData = conversationData;
    if (!self.provider) {
        self.provider = [[TUIMessageDataProvider_Minimalist alloc] initWithConversationModel:conversationData];
        self.provider.dataSource = self;
    }
}

- (void)dealData {
    NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:3];
    self.tabItems = tabItems;
    TUIChatMembersSegementItem * summaryItem = [[TUIChatMembersSegementItem alloc] init];
    [tabItems addObject:summaryItem];
    int summaryCount = 0;
    
    //config tabItems
    for (TUITagsModel *tagsModel in _tagsArray) {
        TUIChatMembersSegementItem * item = [[TUIChatMembersSegementItem alloc] init];
        item.title = [NSString stringWithFormat:@"%ld",tagsModel.followUserModels.count];
        item.facePath = tagsModel.emojiPath;
        [tabItems addObject:item];
        summaryCount += tagsModel.followUserModels.count;
    }
    summaryItem.title = [NSString stringWithFormat:@"ALL %d",summaryCount];

    //config cellData
    NSMutableArray *pageTabCellDatasArray = [NSMutableArray arrayWithCapacity:3];

    NSMutableArray<TUIEmojiCellData *> *summaryEmojiCellDatas = [NSMutableArray arrayWithCapacity:3];
    
    for (TUITagsModel *tagsModel in _tagsArray) {
        NSMutableArray<TUIEmojiCellData *> *emojiCellDatas = [NSMutableArray arrayWithCapacity:3];
        //config each tag
        NSMutableArray<TUITagsUserModel *> *followUserModels = tagsModel.followUserModels;
        for (TUITagsUserModel * userModel in followUserModels) {
            TUIEmojiCellData * cellData = [[TUIEmojiCellData alloc] init];
            cellData.emojiName = tagsModel.emojiKey;
            cellData.emojiPath = tagsModel.emojiPath;
            cellData.faceURL = userModel.faceURL;
            cellData.friendRemark = userModel.friendRemark;
            cellData.nickName = userModel.nickName;
            cellData.userID = userModel.userID;
            NSString * userID = userModel.userID;
            if ([userID  isEqualToString:[TUILogin getUserID]]) {
                cellData.isCurrentUser = YES;
            }
            
            [summaryEmojiCellDatas addObject:cellData];
            [emojiCellDatas addObject:cellData];
        }
        [pageTabCellDatasArray addObject:emojiCellDatas];
    }
        
    [pageTabCellDatasArray insertObject:summaryEmojiCellDatas atIndex:0];
    //config subViews
    NSMutableArray *tabPageVCArray = [NSMutableArray arrayWithCapacity:3];
    self.tabPageVCArray = tabPageVCArray;
    
    for (int i = 0; i < tabItems.count; i++) {
        TUIChatMembersReactSubController *subController = [[TUIChatMembersReactSubController alloc] init];
        subController.data = pageTabCellDatasArray[i];
        subController.originData = self.originData;
        [tabPageVCArray addObject:subController];
    }
    
}
- (void)reloadData {
    if (self.scrollview) {
        [self.scrollview removeFromSuperview];
    }
    self.scrollview = [[TUIChatMembersSegementScrollView alloc] initWithFrame:CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height - self.topGestureView.frame.size.height) SegementItems:self.tabItems viewArray:self.tabPageVCArray];
    
    [self.containerView addSubview:self.scrollview];

}

- (void)registerTUIKitNotification {
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
}

- (void)onRecvMessageModified:(V2TIMMessage *)msg {

    NSString *msgID = msg.msgID;

    if ([msgID isEqualToString:self.originData.msgID] ) {
        TUIMessageCellData *data = [TUIMessageDataProvider_Minimalist getCellData:msg];
        @weakify(self)

        [self.provider preProcessMessage:@[data] callback:^{
            
            @strongify(self)
            @weakify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                NSDictionary * messageModifyReacts = data.messageModifyReacts;
                NSLog(@"%@",messageModifyReacts);
                TUIMessageCell * cell = [[TUIMessageCell alloc] init];
                [cell fillWithData:data];
                NSArray *reactlistArr = cell.reactlistArr;
                NSLog(@"%@",reactlistArr);
                if (reactlistArr.count == 0) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return;
                }
                self.tagsArray = reactlistArr;
                [self dealData];
                [self reloadData];
            });
        }];
    }
    
}

#pragma  mark -TUIMessageBaseDataProviderDataSource

- (void)dataProviderDataSourceWillChange:(TUIMessageBaseDataProvider *)dataProvider {
    
}

- (void)dataProviderDataSourceChange:(TUIMessageBaseDataProvider *)dataProvider
                            withType:(TUIMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
    
}
- (void)dataProviderDataSourceDidChange:(TUIMessageBaseDataProvider *)dataProvider {
    
}

@end
