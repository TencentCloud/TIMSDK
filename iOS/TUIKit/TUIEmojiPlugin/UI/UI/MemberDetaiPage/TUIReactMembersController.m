//
//  TUIReactMembersController.m
//  TUIChat
//
//  Created by wyl on 2022/10/31.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReactMembersController.h"
#import <TIMCommon/TUIMessageCell.h>
#import <TUICore/TUILogin.h>
#import "TUIReactMembersSegementScrollView.h"
#import "TUIReactMemberCell.h"
#import "TUIReactMemberCellData.h"
#import "TUIEmojiReactDataProvider.h"

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
    [self.tableView registerClass:[TUIReactMemberCell class] forCellReuseIdentifier:@"TUIReactMemberCell"];

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    @weakify(self);

    [RACObserve(self.view, frame) subscribeNext:^(id _Nullable frame) {
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
    TUIReactMemberCellData *data = self.data[indexPath.section];
    return data.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{ return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIReactMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUIReactMemberCell"];
    if (cell == nil) {
        cell = [[TUIReactMemberCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TUIReactMemberCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [cell fillWithData:self.data[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIReactMemberCellData *data = self.data[indexPath.row];
    if (data.isCurrentUser) {
        if (self.emojiClickCallback) {
            self.emojiClickCallback(data.tagModel);
        }
    }
}

@end

@interface TUIReactMembersController () <V2TIMAdvancedMsgListener>

@property(nonatomic, strong) TUIReactMembersSegementScrollView *scrollview;

@property(nonatomic, strong) TUIEmojiReactDataProvider *provider;

@property(nonatomic, strong) NSMutableArray *tabItems;

@property(nonatomic, strong) NSMutableArray *tabPageVCArray;

@end

@implementation TUIReactMembersController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNormalBottom];
    self.provider = [[TUIEmojiReactDataProvider alloc] init];
    [self loadList];
    [self registerTUIKitNotification];
    self.containerView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");

    [self dealData];

    [self reloadData];
}

- (void)updateSubContainerView {
    [super updateSubContainerView];

    self.scrollview.frame = CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width,
                                       self.containerView.frame.size.height - self.topGestureView.frame.size.height);

    [self.scrollview updateContainerView];
}


- (void)loadList {
    
    if (!self.provider) {
        self.provider = [[TUIEmojiReactDataProvider alloc] init];
    }
    self.provider.msgId = self.originData.innerMessage.msgID;

    __weak typeof(self)weakSelf = self;
    [self.provider  getMessageReactions:@[self.originData.innerMessage] maxUserCountPerReaction:5 succ:^(NSArray<TUIReactModel *> * _Nonnull tagsArray, NSMutableDictionary * _Nonnull tagsMap) {
        weakSelf.tagsArray = tagsArray;
        [weakSelf dealData];
        [weakSelf reloadData];
    } fail:^(int code, NSString *desc) {

    }];
    
    self.provider.changed = ^(NSArray<TUIReactModel *> * _Nonnull tagsArray, NSMutableDictionary * _Nonnull tagsMap) {
        weakSelf.tagsArray = tagsArray;
        [weakSelf dealData];
        [weakSelf reloadData];
        if (tagsArray.count <= 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }
    };
}
- (void)dealData {
    NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:3];
    self.tabItems = tabItems;
    int summaryCount = 0;

    // config tabItems
    for (TUIReactModel *tagsModel in _tagsArray) {
        TUIReactMembersSegementItem *item = [[TUIReactMembersSegementItem alloc] init];
        item.title = [NSString stringWithFormat:@"%ld", tagsModel.followUserModels.count];
        item.facePath = tagsModel.emojiPath;
        [tabItems addObject:item];
        summaryCount += tagsModel.followUserModels.count;
    }

    // config cellData
    NSMutableArray *pageTabCellDatasArray = [NSMutableArray arrayWithCapacity:3];

    for (TUIReactModel *tagsModel in _tagsArray) {
        NSMutableArray<TUIReactMemberCellData *> *emojiCellDatas = [NSMutableArray arrayWithCapacity:3];
        // config each tag
        NSMutableArray<TUIReactUserModel *> *followUserModels = tagsModel.followUserModels;
        for (TUIReactUserModel *userModel in followUserModels) {
            TUIReactMemberCellData *cellData = [[TUIReactMemberCellData alloc] init];
            cellData.tagModel = tagsModel;
            cellData.emojiName = tagsModel.emojiKey;
            cellData.emojiPath = tagsModel.emojiPath;
            cellData.faceURL = userModel.faceURL;
            cellData.friendRemark = userModel.friendRemark;
            cellData.nickName = userModel.nickName;
            cellData.userID = userModel.userID;
            NSString *userID = userModel.userID;
            if ([userID isEqualToString:[TUILogin getUserID]]) {
                cellData.isCurrentUser = YES;
            }
            [emojiCellDatas addObject:cellData];
        }
        [pageTabCellDatasArray addObject:emojiCellDatas];
    }

    // config subViews
    NSMutableArray *tabPageVCArray = [NSMutableArray arrayWithCapacity:3];
    self.tabPageVCArray = tabPageVCArray;

    for (int i = 0; i < tabItems.count; i++) {
        TUIChatMembersReactSubController *subController = [[TUIChatMembersReactSubController alloc] init];
        subController.data = pageTabCellDatasArray[i];
        subController.originData = self.originData;
        __weak typeof(self)weakSelf = self;
        subController.emojiClickCallback = ^(TUIReactModel * _Nonnull model) {
            [weakSelf.provider removeMessageReaction:weakSelf.originData.innerMessage reactionID:model.emojiKey succ:^{
                
            } fail:^(int code, NSString *desc) {
                
            }];
        };
        [tabPageVCArray addObject:subController];
    }
}
- (void)reloadData {
    if (self.scrollview) {
        [self.scrollview removeFromSuperview];
    }
    self.scrollview =
        [[TUIReactMembersSegementScrollView alloc] initWithFrame:CGRectMake(0, self.topGestureView.frame.size.height, self.containerView.frame.size.width,
                                                                           self.containerView.frame.size.height - self.topGestureView.frame.size.height)
                                                  SegementItems:self.tabItems
                                                      viewArray:self.tabPageVCArray];

    [self.containerView addSubview:self.scrollview];
}

- (void)registerTUIKitNotification {
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
}

@end
