//
//  TUIFriendController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/29.
//  Copyright © 2019 kennethmiao. All rights reserved.
//

#import "TUIFriendProfileController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUICommonContactSwitchCell.h"
#import "TUICommonContactSwitchCell_Minimalist.h"
#import "TUICommonContactTextCell.h"
#import "TUICommonContactTextCell_Minimalist.h"
#import "TUIContactAvatarViewController_Minimalist.h"
#import "TUIContactButtonCellData_Minimalist.h"
#import "TUIContactButtonCell_Minimalist.h"
#import "TUIContactConversationCellData.h"
#import "TUIFriendProfileHeaderView_Minimalist.h"
#import "TUITextEditController_Minimalist.h"
#import "TUIContactConfig.h"

@interface TUIFriendProfileController_Minimalist () <UITableViewDelegate, UITableViewDataSource>
@property NSArray<NSArray *> *dataList;
@property BOOL modified;
@property V2TIMUserFullInfo *userFullInfo;
@property TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) TUIFriendProfileHeaderView_Minimalist *headerView;
@end

@implementation TUIFriendProfileController_Minimalist
@synthesize friendProfile;

- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (parent == nil) {
        if (self.modified) {
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLongPressGesture];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    self.userFullInfo = self.friendProfile.userFullInfo;
    self.tableView = [[UITableView alloc] initWithFrame:self.scrollView.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview:self.tableView];
    self.scrollView.contentSize = self.tableView.bounds.size;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.backgroundColor = TIMCommonDynamicColor(@"", @"#FFFFFF");

    [self.tableView registerClass:[TUICommonContactTextCell_Minimalist class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TUICommonContactSwitchCell_Minimalist class] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerClass:[TUIContactButtonCell_Minimalist class] forCellReuseIdentifier:@"ButtonCell"];
    self.tableView.delaysContentTouches = NO;
    [self.tableView setSeparatorColor:[UIColor clearColor]];

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(ProfileDetails)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    [self setupHeaderViewData];

    [self loadData];
}
- (void)setupHeaderViewData {
    self.headerView = [[TUIFriendProfileHeaderView_Minimalist alloc] init];
    [self.headerView.headImg sd_setImageWithURL:[NSURL URLWithString:self.userFullInfo.faceURL] placeholderImage:DefaultAvatarImage];
    self.headerView.descriptionLabel.text = [self.userFullInfo showName];
    self.tableView.tableHeaderView = self.headerView;

    // Banner extension
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (self.userFullInfo.userID.length > 0) {
        param[TUICore_TUIContactExtension_FriendProfileActionMenu_UserID] = self.userFullInfo.userID;
    }
    if (self.userFullInfo.showName.length > 0) {
        param[TUICore_TUIContactExtension_FriendProfileActionMenu_UserName] = self.userFullInfo.showName;
    }
    if (self.headerView.headImg.image) {
        param[TUICore_TUIContactExtension_FriendProfileActionMenu_UserIcon] = self.headerView.headImg.image;
    }
    
    BOOL isAIConversation = [self.friendProfile.userID containsString:@"@RBT#"] ;

    if (isAIConversation ) {
        param[TUICore_TUIContactExtension_FriendProfileActionMenu_FilterVideoCall] = @(YES);
        param[TUICore_TUIContactExtension_FriendProfileActionMenu_FilterAudioCall] = @(YES);
    }
    else {
        param[TUICore_TUIContactExtension_FriendProfileActionMenu_FilterVideoCall] = @(NO);
        param[TUICore_TUIContactExtension_FriendProfileActionMenu_FilterAudioCall] = @(NO);
    }
    
    if (self.navigationController) {
        param[TUICore_TUIContactExtension_FriendProfileActionMenu_PushVC] = self.navigationController;
    }
    NSMutableArray<TUIFriendProfileHeaderItemView *> *itemViewList = [NSMutableArray array];
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID
                                                                     param:param];
    for (TUIExtensionInfo *info in extensionList) {
        if (info.text && info.icon && info.onClicked) {
            TUIFriendProfileHeaderItemView *itemView = [[TUIFriendProfileHeaderItemView alloc] init];
            itemView.textLabel.text = info.text;
            itemView.iconView.image = info.icon;
            itemView.messageBtnClickBlock = ^{
              info.onClicked(param);
            };
            [itemViewList addObject:itemView];
        }
    }
    if (itemViewList.count > 0) {
        [self.headerView setItemViewList:itemViewList];
        self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, kScale390(355));
    } else {
        self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, kScale390(257));
    }
}
- (void)loadData {
    NSMutableArray *list = @[].mutableCopy;

    if (![[TUIContactConfig sharedConfig] isItemHiddenInContactConfig:TUIContactConfigItem_Alias]) {
        [list addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TUICommonContactTextCellData_Minimalist *data = TUICommonContactTextCellData_Minimalist.new;
                data.key = TIMCommonLocalizableString(ProfileAlia);
                data.value = self.friendProfile.friendRemark;
                if (data.value.length == 0) {
                  data.value = TIMCommonLocalizableString(None);
                }
                data.showAccessory = YES;
                data.cselector = @selector(onChangeRemark:);
                data.reuseId = @"TextCell";
                data;
            })];
            inlist;
        })];
    }

    if (![[TUIContactConfig sharedConfig] isItemHiddenInContactConfig:TUIContactConfigItem_MuteAndPin]) {
        [list addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TUICommonContactSwitchCellData_Minimalist *data = TUICommonContactSwitchCellData_Minimalist.new;
                data.title = TIMCommonLocalizableString(ProfileMessageDoNotDisturb);
                data.cswitchSelector = @selector(onMessageDoNotDisturb:);
                data.reuseId = @"SwitchCell";
                __weak typeof(self) weakSelf = self;
                [[V2TIMManager sharedInstance] getC2CReceiveMessageOpt:@[ self.friendProfile.userID ]
                                                                  succ:^(NSArray<V2TIMUserReceiveMessageOptInfo *> *optList) {
                    for (V2TIMReceiveMessageOptInfo *info in optList) {
                        if ([info.userID isEqual:self.friendProfile.userID]) {
                          data.on = (info.receiveOpt == V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE);
                          [weakSelf.tableView reloadData];
                          break;
                        }
                    }
                }
                                                                  fail:nil];
                data;
            })];

            [inlist addObject:({
                TUICommonContactSwitchCellData_Minimalist *data = TUICommonContactSwitchCellData_Minimalist.new;
                data.title = TIMCommonLocalizableString(ProfileStickyonTop);
                data.on = NO;
                #ifndef SDKPlaceTop
                #define SDKPlaceTop
                #endif
                #ifdef SDKPlaceTop
                __weak typeof(self) weakSelf = self;
                [V2TIMManager.sharedInstance getConversation:[NSString stringWithFormat:@"c2c_%@", self.friendProfile.userID]
                                                        succ:^(V2TIMConversation *conv) {
                    data.on = conv.isPinned;
                    [weakSelf.tableView reloadData];}
                                                        fail:^(int code, NSString *desc) {
                    
                }];
                #else
                if ([[[TUIConversationPin sharedInstance] topConversationList]
                      containsObject:[NSString stringWithFormat:@"c2c_%@", self.friendProfile.userID]]) {
                  data.on = YES;
                }
                #endif
                data.cswitchSelector = @selector(onTopMostChat:);
                data.reuseId = @"SwitchCell";
                data;
            })];
            inlist;
        })];
    }

    if (![[TUIContactConfig sharedConfig] isItemHiddenInContactConfig:TUIContactConfigItem_Background]) {
        [list addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TUICommonContactTextCellData_Minimalist *data = TUICommonContactTextCellData_Minimalist.new;
                data.key = TIMCommonLocalizableString(ProfileSetBackgroundImage);
                data.showAccessory = YES;
                data.cselector = @selector(onChangeBackgroundImage:);
                data.reuseId = @"TextCell";
                data;
            })];
            inlist;
        })];
    }

    if (![[TUIContactConfig sharedConfig] isItemHiddenInContactConfig:TUIContactConfigItem_Block]) {
        [list addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TUICommonContactSwitchCellData_Minimalist *data = TUICommonContactSwitchCellData_Minimalist.new;
                data.title = TIMCommonLocalizableString(ProfileBlocked);
                data.cswitchSelector = @selector(onChangeBlackList:);
                data.reuseId = @"SwitchCell";
                __weak typeof(self) weakSelf = self;
                [[V2TIMManager sharedInstance] getBlackList:^(NSArray<V2TIMFriendInfo *> *infoList) {
                    for (V2TIMFriendInfo *friend in infoList) {
                        if ([friend.userID isEqualToString:self.friendProfile.userID]) {
                            data.on = true;
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
    }

   
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        if (![[TUIContactConfig sharedConfig] isItemHiddenInContactConfig:TUIContactConfigItem_ClearChatHistory]) {
            [inlist addObject:({
                TUIContactButtonCellData_Minimalist *data = TUIContactButtonCellData_Minimalist.new;
                data.title = TIMCommonLocalizableString(TUIKitClearAllChatHistory);
                data.style = ButtonRedText;
                data.cbuttonSelector = @selector(onClearHistoryChatMessage:);
                data.reuseId = @"ButtonCell";
                data;
            })];
        }
        
        if (![[TUIContactConfig sharedConfig] isItemHiddenInContactConfig:TUIContactConfigItem_Delete]) {
            [inlist addObject:({
                TUIContactButtonCellData_Minimalist *data = TUIContactButtonCellData_Minimalist.new;
                data.title = TIMCommonLocalizableString(ProfileDeleteFirend);
                data.style = ButtonRedText;
                data.cbuttonSelector = @selector(onDeleteFriend:);
                data.reuseId = @"ButtonCell";
                data;
            })];
        }

        TUIContactButtonCellData_Minimalist *lastdata = [inlist lastObject];
        lastdata.hideSeparatorLine = YES;
        inlist;
    })];

    self.dataList = list;
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (void)onChangeBlackList:(TUICommonContactSwitchCell *)cell {
    if (cell.switcher.on) {
        [[V2TIMManager sharedInstance] addToBlackList:@[ self.friendProfile.userID ] succ:nil fail:nil];
    } else {
        [[V2TIMManager sharedInstance] deleteFromBlackList:@[ self.friendProfile.userID ] succ:nil fail:nil];
    }
}

- (void)onChangeRemark:(TUICommonContactTextCell *)cell {
    TUITextEditController_Minimalist *vc = [[TUITextEditController_Minimalist alloc] initWithText:self.friendProfile.friendRemark];
    vc.title = TIMCommonLocalizableString(ProfileEditAlia);  // @"";
    vc.textValue = self.friendProfile.friendRemark;
    [self.navigationController pushViewController:vc animated:YES];

    @weakify(self);
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *value) {
      @strongify(self);
      self.modified = YES;
      self.friendProfile.friendRemark = value;
      [[V2TIMManager sharedInstance] setFriendInfo:self.friendProfile
                                              succ:^{
                                                [self loadData];
                                                [NSNotificationCenter.defaultCenter postNotificationName:@"FriendInfoChangedNotification"
                                                                                                  object:self.friendProfile];
                                              }
                                              fail:nil];
    }];
}

- (void)onClearHistoryChatMessage:(TUICommonContactTextCell *)cell {
    if (IS_NOT_EMPTY_NSSTRING(self.friendProfile.userID)) {
        NSString *userID = self.friendProfile.userID;
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

- (void)onChangeBackgroundImage:(TUICommonContactTextCell *)cell {
    @weakify(self);
    NSString *conversationID = [NSString stringWithFormat:@"c2c_%@", self.friendProfile.userID];
    TUISelectAvatarController *vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeConversationBackGroundCover;
    vc.profilFaceURL = [self getBackgroundImageUrlByConversationID:conversationID];
    [self.navigationController pushViewController:vc animated:YES];
    vc.selectCallBack = ^(NSString *_Nonnull urlStr) {
      @strongify(self);
      [self appendBackgroundImage:urlStr conversationID:conversationID];
      if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
          [TUICore notifyEvent:TUICore_TUIContactNotify
                        subKey:TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey
                        object:self
                         param:@{TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey_ConversationID : conversationID}];
      }
    };
}

- (NSString *)getBackgroundImageUrlByConversationID:(NSString *)targerConversationID {
    if (targerConversationID.length == 0) {
        return nil;
    }
    NSDictionary *dict = [NSUserDefaults.standardUserDefaults objectForKey:@"conversation_backgroundImage_map"];
    if (dict == nil) {
        dict = @{};
    }
    NSString *conversationID_UserID = [NSString stringWithFormat:@"%@_%@", targerConversationID, [TUILogin getUserID]];
    if (![dict isKindOfClass:NSDictionary.class] || ![dict.allKeys containsObject:conversationID_UserID]) {
        return nil;
    }
    return [dict objectForKey:conversationID_UserID];
}

- (void)appendBackgroundImage:(NSString *)imgUrl conversationID:(NSString *)conversationID {
    if (conversationID.length == 0) {
        return;
    }
    NSDictionary *dict = [NSUserDefaults.standardUserDefaults objectForKey:@"conversation_backgroundImage_map"];
    if (dict == nil) {
        dict = @{};
    }
    if (![dict isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSString *conversationID_UserID = [NSString stringWithFormat:@"%@_%@", conversationID, [TUILogin getUserID]];
    NSMutableDictionary *originDataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (imgUrl.length == 0) {
        [originDataDict removeObjectForKey:conversationID_UserID];
    } else {
        [originDataDict setObject:imgUrl forKey:conversationID_UserID];
    }

    [NSUserDefaults.standardUserDefaults setObject:originDataDict forKey:@"conversation_backgroundImage_map"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = TIMCommonDynamicColor(@"", @"#FFFFFF");
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = TIMCommonDynamicColor(@"", @"#FFFFFF");
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

    if ([data isKindOfClass:[TUIContactButtonCellData_Minimalist class]]) {
        TUIContactButtonCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        if (!cell) {
            cell = [[TUIContactButtonCell_Minimalist alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
        }
        [cell fillWithData:(TUIContactButtonCellData_Minimalist *)data];
        cell.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
        return cell;

    } else if ([data isKindOfClass:[TUICommonContactTextCellData_Minimalist class]]) {
        TUICommonContactTextCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonContactTextCellData_Minimalist *)data];
        return cell;

    } else if ([data isKindOfClass:[TUICommonContactSwitchCellData_Minimalist class]]) {
        TUICommonContactSwitchCell_Minimalist *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonContactSwitchCellData_Minimalist *)data];
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TUICommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)onVoiceCall:(id)sender {
    NSDictionary *param = @{
        TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[ self.userFullInfo.userID ?: @"" ],
        TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey : @"0"
    };
    [TUICore callService:TUICore_TUICallingService method:TUICore_TUICallingService_ShowCallingViewMethod param:param];
}

- (void)onVideoCall:(id)sender {
    NSDictionary *param = @{
        TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[ self.userFullInfo.userID ?: @"" ],
        TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey : @"1"
    };
    [TUICore callService:TUICore_TUICallingService method:TUICore_TUICallingService_ShowCallingViewMethod param:param];
}

- (void)onDeleteFriend:(id)sender {
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance]
        deleteFromFriendList:@[ self.friendProfile.userID ]
                  deleteType:V2TIM_FRIEND_TYPE_BOTH
                        succ:^(NSArray<V2TIMFriendOperationResult *> *resultList) {
                          weakSelf.modified = YES;
                          [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"c2c_%@", weakSelf.friendProfile.userID]
                                                                            callback:nil];
                          NSString *conversationID = [NSString stringWithFormat:@"c2c_%@", weakSelf.friendProfile.userID];
                          if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
                              [TUICore notifyEvent:TUICore_TUIConversationNotify
                                            subKey:TUICore_TUIConversationNotify_RemoveConversationSubKey
                                            object:self
                                             param:@{TUICore_TUIConversationNotify_RemoveConversationSubKey_ConversationID : conversationID}];
                          }
                          [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        }
                        fail:nil];
}

- (void)onSendMessage:(id)sender {
    UIImage *avataImage = [UIImage new];
    if (self.headerView.headImg.image) {
        avataImage = self.headerView.headImg.image;
    }

    NSString *title = [self.friendProfile.userFullInfo showName];
    if (IS_NOT_EMPTY_NSSTRING(self.friendProfile.friendRemark)) {
        title = self.friendProfile.friendRemark;
    }

    NSDictionary *param = @{
        TUICore_TUIChatObjectFactory_ChatViewController_Title : title ?: @"",
        TUICore_TUIChatObjectFactory_ChatViewController_UserID : self.friendProfile.userID,
        TUICore_TUIChatObjectFactory_ChatViewController_ConversationID : [NSString stringWithFormat:@"c2c_%@", self.userFullInfo.userID],
        TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : avataImage
    };
    [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Minimalist param:param forResult:nil];
}

- (void)onMessageDoNotDisturb:(TUICommonContactSwitchCell *)cell {
    V2TIMReceiveMessageOpt opt;
    if (cell.switcher.on) {
        opt = V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
    } else {
        opt = V2TIM_RECEIVE_MESSAGE;
    }
    [[V2TIMManager sharedInstance] setC2CReceiveMessageOpt:@[ self.friendProfile.userID ] opt:opt succ:nil fail:nil];
}

- (void)onTopMostChat:(TUICommonContactSwitchCell *)cell {
    if (cell.switcher.on) {
        [[TUIConversationPin sharedInstance] addTopConversation:[NSString stringWithFormat:@"c2c_%@", self.friendProfile.userID]
                                                       callback:^(BOOL success, NSString *_Nonnull errorMessage) {
                                                         if (success) {
                                                             return;
                                                         }
                                                         cell.switcher.on = !cell.switcher.isOn;
                                                         [TUITool makeToast:errorMessage];
                                                       }];
    } else {
        [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"c2c_%@", self.friendProfile.userID]
                                                          callback:^(BOOL success, NSString *_Nonnull errorMessage) {
                                                            if (success) {
                                                                return;
                                                            }
                                                            cell.switcher.on = !cell.switcher.isOn;
                                                            [TUITool makeToast:errorMessage];
                                                          }];
    }
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
        } else if ([data isKindOfClass:[TUICommonContactProfileCardCell_Minimalist class]]) {
            TUICommonContactProfileCardCell_Minimalist *profileCard = (TUICommonContactProfileCardCell_Minimalist *)data;
            if (profileCard.cardData.identifier) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileCard.cardData.identifier;
                NSString *toastString = [NSString stringWithFormat:@"已将该用户账号复制到粘贴板"];
                [TUITool makeToast:toastString];
            }
        }
    }
}

- (void)didTapOnAvatar:(TUICommonContactProfileCardCell_Minimalist *)cell {
    TUIContactAvatarViewController_Minimalist *image = [[TUIContactAvatarViewController_Minimalist alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

+ (BOOL)isMarkedByHideType:(NSArray *)markList {
    for (NSNumber *num in markList) {
        if (num.unsignedLongValue == V2TIM_CONVERSATION_MARK_TYPE_HIDE) {
            return YES;
        }
    }
    return NO;
}
@end
