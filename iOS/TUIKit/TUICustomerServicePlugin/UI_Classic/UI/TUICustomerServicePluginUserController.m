//
//  TUICustomerServicePluginUserController.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/7/6.
//

#import "TUICustomerServicePluginUserController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TUIContact/TUICommonContactTextCell.h>
#import <TUIContact/TUICommonContactSwitchCell.h>
#import <TUIContact/TUICommonContactProfileCardCell.h>
#import <TUICore/TUICore.h>

@interface TUICustomerServicePluginUserController ()

@property (nonatomic, copy) NSArray<NSArray *> *dataList;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) V2TIMUserInfo *userInfo;

@end

@implementation TUICustomerServicePluginUserController

- (instancetype)initWithUserInfo:(V2TIMUserInfo *)userInfo {
    self = [super init];
    if (self) {
        self.userInfo = userInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLongPressGesture];

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    [self.tableView registerClass:[TUICommonContactTextCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TUICommonContactSwitchCell class] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerClass:[TUICommonContactProfileCardCell class] forCellReuseIdentifier:@"CardCell"];
    self.tableView.delaysContentTouches = NO;
    
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(ProfileDetails)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    [self loadData];
}

- (void)loadData {
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUICommonContactProfileCardCellData *personal = [[TUICommonContactProfileCardCellData alloc] init];
            personal.identifier = self.userInfo.userID;
            personal.avatarImage = DefaultAvatarImage;
            personal.avatarUrl = [NSURL URLWithString:self.userInfo.faceURL];
            personal.name = self.userInfo.nickName;
            personal.signature = TIMCommonLocalizableString(no_personal_signature);
            personal.reuseId = @"CardCell";
            personal.showSignature = YES;
            personal;
        })];
        inlist;
    })];

    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUICommonContactSwitchCellData *data = TUICommonContactSwitchCellData.new;
            data.title = TIMCommonLocalizableString(ProfileMessageDoNotDisturb);
            data.cswitchSelector = @selector(onMessageDoNotDisturb:);
            data.reuseId = @"SwitchCell";
            __weak typeof(self) weakSelf = self;
            [[V2TIMManager sharedInstance] getC2CReceiveMessageOpt:@[ self.userInfo.userID ]
                                                            succ:^(NSArray<V2TIMUserReceiveMessageOptInfo *> *optList) {
                                                              for (V2TIMReceiveMessageOptInfo *info in optList) {
                                                                  if ([info.userID isEqual:self.userInfo.userID]) {
                                                                      data.on = (info.receiveOpt == V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE);
                                                                      [weakSelf.tableView reloadData];
                                                                      break;
                                                                  }
                                                              }
                                                            }
                                                            fail:nil];
            data;
        })];
        inlist;
    })];

    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUICommonContactTextCellData *data = TUICommonContactTextCellData.new;
            data.key = TIMCommonLocalizableString(TUIKitClearAllChatHistory);
            data.showAccessory = YES;
            data.cselector = @selector(onClearHistoryChatMessage:);
            data.reuseId = @"TextCell";
            data;
        })];
        inlist;
    })];

    self.dataList = list;
    [self.tableView reloadData];
}

- (void)onClearHistoryChatMessage:(TUICommonContactTextCell *)cell {
    if (IS_NOT_EMPTY_NSSTRING(self.userInfo.userID)) {
        NSString *userID = self.userInfo.userID;
        @weakify(self);
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                    message:TIMCommonLocalizableString(TUIKitClearAllChatHistoryTips)
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *_Nonnull action) {
            @strongify(self);
            [V2TIMManager.sharedInstance clearC2CHistoryMessage:userID
                succ:^{
                  [TUICore notifyEvent:TUICore_TUIConversationNotify
                                subKey:TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey
                                object:self
                                 param:nil];
                  [TUITool makeToast:@"success"];
                }
                fail:^(int code, NSString *desc) {
                  [TUITool makeToastError:code msg:desc];
                }];
          }]];
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

#pragma mark - TableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0 : 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *data = self.dataList[indexPath.section][indexPath.row];
    if ([data isKindOfClass:[TUICommonContactProfileCardCellData class]]) {
        TUICommonContactProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell fillWithData:(TUICommonContactProfileCardCellData *)data];
        return cell;

    } else if ([data isKindOfClass:[TUICommonContactTextCellData class]]) {
        TUICommonContactTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonContactTextCellData *)data];
        return cell;

    } else if ([data isKindOfClass:[TUICommonContactSwitchCellData class]]) {
        TUICommonContactSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonContactSwitchCellData *)data];
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TUICommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

- (void)onMessageDoNotDisturb:(TUICommonContactSwitchCell *)cell {
    V2TIMReceiveMessageOpt opt;
    if (cell.switcher.on) {
        opt = V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
    } else {
        opt = V2TIM_RECEIVE_MESSAGE;
    }
    [[V2TIMManager sharedInstance] setC2CReceiveMessageOpt:@[ self.userInfo.userID ] opt:opt succ:nil fail:nil];
}

- (void)addLongPressGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAtCell:)];
    [self.tableView addGestureRecognizer:longPress];
}

- (void)didLongPressAtCell:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath *pathAtView = [self.tableView indexPathForRowAtPoint:point];
        NSObject *data = [self.tableView cellForRowAtIndexPath:pathAtView];

        if ([data isKindOfClass:[TUICommonContactTextCell class]]) {
            TUICommonContactTextCell *textCell = (TUICommonContactTextCell *)data;
            if (textCell.textData.value && ![textCell.textData.value isEqualToString:@"未设置"]) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = textCell.textData.value;
                NSString *toastString = [NSString stringWithFormat:@"已将 %@ 复制到粘贴板", textCell.textData.key];
                [TUITool makeToast:toastString];
            }
        } else if ([data isKindOfClass:[TUICommonContactProfileCardCell class]]) {
            TUICommonContactProfileCardCell *profileCard = (TUICommonContactProfileCardCell *)data;
            if (profileCard.cardData.identifier) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileCard.cardData.identifier;
                NSString *toastString = [NSString stringWithFormat:@"已将该用户账号复制到粘贴板"];
                [TUITool makeToast:toastString];
            }
        }
    }
}

@end
