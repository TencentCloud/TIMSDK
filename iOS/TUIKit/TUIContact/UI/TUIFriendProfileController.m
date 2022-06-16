//
//  TUIFriendController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/29.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TUIFriendProfileController.h"
#import "TUICommonContactTextCell.h"
#import "TUICommonContactSwitchCell.h"
#import "UIView+TUILayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUITextEditController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIContactAvatarViewController.h"
#import "TUIContactConversationCellData.h"
#import "TUICommonModel.h"
#import "TUICore.h"
#import "TUIThemeManager.h"
#import "TUICommonModel.h"

@interface TUIFriendProfileController ()
@property NSArray<NSArray *> *dataList;
@property BOOL modified;
@property V2TIMUserFullInfo *userFullInfo;
@property TUINaviBarIndicatorView *titleView;
@end

@implementation TUIFriendProfileController
@synthesize friendProfile;

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];

    return self;
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if (parent == nil) {
        if (self.modified) {
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLongPressGesture];

    self.userFullInfo = self.friendProfile.userFullInfo;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");

    [self.tableView registerClass:[TUICommonContactTextCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TUICommonContactSwitchCell class] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerClass:[TUICommonContactProfileCardCell class] forCellReuseIdentifier:@"CardCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"ButtonCell"];

    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    self.tableView.delaysContentTouches = NO;
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TUIKitLocalizableString(ProfileDetails)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    [self loadData];
}
/**
 *初始化视图显示数据
 */
- (void)loadData
{
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUICommonContactProfileCardCellData *personal = [[TUICommonContactProfileCardCellData alloc] init];
            personal.identifier = self.userFullInfo.userID;
            personal.avatarImage = DefaultAvatarImage;
            personal.avatarUrl = [NSURL URLWithString:self.userFullInfo.faceURL];
            personal.name = [self.userFullInfo showName];
            personal.genderString = [self.userFullInfo showGender];
            personal.signature = self.userFullInfo.selfSignature.length ? [NSString stringWithFormat:TUIKitLocalizableString(SignatureFormat), self.userFullInfo.selfSignature] : TUIKitLocalizableString(no_personal_signature);
            personal.reuseId = @"CardCell";
            personal.showSignature = YES;
            personal;
        })];
        inlist;
    })];

    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUICommonContactTextCellData *data = TUICommonContactTextCellData.new;
            data.key = TUIKitLocalizableString(ProfileAlia); // @"备注名";
            data.value = self.friendProfile.friendRemark;
            if (data.value.length == 0)
            {
                data.value = TUIKitLocalizableString(None); // @"无";
            }
            data.showAccessory = YES;
            data.cselector = @selector(onChangeRemark:);
            data.reuseId = @"TextCell";
            data;
        })];
        inlist;
    })];

    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUICommonContactSwitchCellData *data = TUICommonContactSwitchCellData.new;
            data.title = TUIKitLocalizableString(ProfileMessageDoNotDisturb); // @"消息免打扰";
            data.cswitchSelector =  @selector(onMessageDoNotDisturb:);
            data.reuseId = @"SwitchCell";
            __weak typeof(self) weakSelf = self;
            [[V2TIMManager sharedInstance] getC2CReceiveMessageOpt:@[self.friendProfile.userID]
                                                              succ:^(NSArray<V2TIMUserReceiveMessageOptInfo *> *optList) {
                for (V2TIMReceiveMessageOptInfo *info in optList) {
                    if ([info.userID isEqual:self.friendProfile.userID]) {
                        data.on = (info.receiveOpt == V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE);
                        [weakSelf.tableView reloadData];
                        break;
                    }
                }
            } fail:nil];
            data;
        })];
        
        [inlist addObject:({
            TUICommonContactSwitchCellData *data = TUICommonContactSwitchCellData.new;
            data.title = TUIKitLocalizableString(ProfileStickyonTop); // @"置顶聊天";
            data.on = NO;
#ifndef SDKPlaceTop
#define SDKPlaceTop
#endif
#ifdef SDKPlaceTop
            __weak typeof(self) weakSelf = self;
            [V2TIMManager.sharedInstance getConversation:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID] succ:^(V2TIMConversation *conv) {
                data.on = conv.isPinned;
                [weakSelf.tableView reloadData];
            } fail:^(int code, NSString *desc) {
                
            }];
#else
            if ([[[TUIConversationPin sharedInstance] topConversationList] containsObject:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID]]) {
                data.on = YES;
            }
#endif
            data.cswitchSelector =  @selector(onTopMostChat:);
            data.reuseId = @"SwitchCell";
            data;
        })];
        inlist;
    })];
    
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUICommonContactSwitchCellData *data = TUICommonContactSwitchCellData.new;
            data.title = TUIKitLocalizableString(ProfileBlocked); // @"加入黑名单";
            data.cswitchSelector =  @selector(onChangeBlackList:);
            data.reuseId = @"SwitchCell";
            __weak typeof(self) weakSelf = self;
            [[V2TIMManager sharedInstance] getBlackList:^(NSArray<V2TIMFriendInfo *> *infoList) {
                for (V2TIMFriendInfo *friend in infoList) {
                    if ([friend.userID isEqualToString:self.friendProfile.userID])
                    {
                        data.on = true;
                        [weakSelf.tableView reloadData];
                        break;
                    }
                }
            } fail:nil];
            data;
        })];
        inlist;
    })];

    
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TUIButtonCellData *data = TUIButtonCellData.new;
            data.title = TUIKitLocalizableString(ProfileSendMessages); // @"发送消息";
            data.style = ButtonWhite;
            data.textColor = TUICoreDynamicColor(@"primary_theme_color", @"147AFF");
            data.cbuttonSelector = @selector(onSendMessage:);
            data.reuseId = @"ButtonCell";
            data;
        })];
        NSString *groupID = nil;
        NSString *userID = self.userFullInfo.userID;
        NSDictionary *param = @{TUICore_TUIChatExtension_GetMoreCellInfo_GroupID : groupID ? groupID : @"",TUICore_TUIChatExtension_GetMoreCellInfo_UserID : userID ? userID : @""};
        NSDictionary *videoExtentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall param:param];
        NSDictionary *audioExtentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall param:param];
        if (audioExtentionInfo) {
            // 集成了 音频
            [inlist addObject:({
                TUIButtonCellData *data = TUIButtonCellData.new;
                data.title = TUIKitLocalizableString(TUIKitMoreVoiceCall); // @"语音通话";
                data.style = ButtonWhite;
                data.textColor = TUICoreDynamicColor(@"primary_theme_color", @"147AFF");
                data.cbuttonSelector = @selector(onVoiceCall:);
                data.reuseId = @"ButtonCell";
                data;
            })];
        }
        if (videoExtentionInfo) {
            [inlist addObject:({
                TUIButtonCellData *data = TUIButtonCellData.new;
                data.title = TUIKitLocalizableString(TUIKitMoreVideoCall); // @"视频通话";
                data.style = ButtonWhite;
                data.textColor = TUICoreDynamicColor(@"primary_theme_color", @"147AFF");
                data.cbuttonSelector = @selector(onVideoCall:);
                data.reuseId = @"ButtonCell";
                data;
            })];
        }
        [inlist addObject:({
            TUIButtonCellData *data = TUIButtonCellData.new;
            data.title = TUIKitLocalizableString(ProfileDeleteFirend); // @"删除好友";
            data.style = ButtonRedText;
            data.cbuttonSelector =  @selector(onDeleteFriend:);
            data.reuseId = @"ButtonCell";
            data;
        })];
        TUIButtonCellData *lastdata = [inlist lastObject];
        lastdata.hideSeparatorLine = YES;
        inlist;
    })];

    self.dataList = list;
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (void)onChangeBlackList:(TUICommonContactSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[V2TIMManager sharedInstance] addToBlackList:@[self.friendProfile.userID] succ:nil fail:nil];
    } else {
        [[V2TIMManager sharedInstance] deleteFromBlackList:@[self.friendProfile.userID] succ:nil fail:nil];
    }
}

/**
 *点击 修改备注 按钮后所执行的函数。包含数据的获取与请求回调
 */
- (void)onChangeRemark:(TUICommonContactTextCell *)cell
{
    TUITextEditController *vc = [[TUITextEditController alloc] initWithText:self.friendProfile.friendRemark];
    vc.title = TUIKitLocalizableString(ProfileEditAlia); // @"修改备注";
    vc.textValue = self.friendProfile.friendRemark;
    [self.navigationController pushViewController:vc animated:YES];

    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *value) {
        @strongify(self)
        self.modified = YES;
        self.friendProfile.friendRemark = value;
        [[V2TIMManager sharedInstance] setFriendInfo:self.friendProfile succ:^{
            [self loadData];
            [NSNotificationCenter.defaultCenter postNotificationName:@"FriendInfoChangedNotification" object:self.friendProfile];
        } fail:nil];
    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0 : 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSObject *data = self.dataList[indexPath.section][indexPath.row];
    //原本的写法会使得子类重写的方法无法被调用，所以此处使用了“我”界面的写法。
    if([data isKindOfClass:[TUICommonContactProfileCardCellData class]]){
        TUICommonContactProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
        //设置 profileCard 的委托
        cell.delegate = self;
        [cell fillWithData:(TUICommonContactProfileCardCellData *)data];
        return cell;

    }   else if([data isKindOfClass:[TUIButtonCellData class]]){
        TUIButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        if(!cell){
            cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
        }
        [cell fillWithData:(TUIButtonCellData *)data];
        return cell;

    }  else if([data isKindOfClass:[TUICommonContactTextCellData class]]) {
        TUICommonContactTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonContactTextCellData *)data];
        return cell;

    }  else if([data isKindOfClass:[TUICommonContactSwitchCellData class]]) {
        TUICommonContactSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        [cell fillWithData:(TUICommonContactSwitchCellData *)data];
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    TUICommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (void)onVoiceCall:(id)sender
{
    NSDictionary *param = @{
        TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[self.userFullInfo.userID?:@""],
        TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey : @"0"
    };
    [TUICore callService:TUICore_TUICallingService
                  method:TUICore_TUICallingService_ShowCallingViewMethod
                   param:param];
}

- (void)onVideoCall:(id)sender
{
    NSDictionary *param = @{
        TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[self.userFullInfo.userID?:@""],
        TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey : @"1"
    };
    [TUICore callService:TUICore_TUICallingService
                  method:TUICore_TUICallingService_ShowCallingViewMethod
                   param:param];
}

/**
 *点击 删除好友 后执行的函数，包括好友信息获取和请求回调
 */
- (void)onDeleteFriend:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] deleteFromFriendList:@[self.friendProfile.userID] deleteType:V2TIM_FRIEND_TYPE_BOTH succ:^(NSArray<V2TIMFriendOperationResult *> *resultList) {
        weakSelf.modified = YES;
        [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"c2c_%@",weakSelf.friendProfile.userID] callback:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } fail:nil];
}

/**
 *点击 发送消息 后执行的函数，默认跳转到对应好友的聊天界面
 */
- (void)onSendMessage:(id)sender
{
    NSDictionary *param = @{
        TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey : [self.friendProfile.userFullInfo showName],
        TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey : self.friendProfile.userID,
        TUICore_TUIChatService_GetChatViewControllerMethod_ConversationIDKey: [NSString stringWithFormat:@"c2c_%@",self.userFullInfo.userID]
    };
    UIViewController *chatVC = [TUICore callService:TUICore_TUIChatService
                                             method:TUICore_TUIChatService_GetChatViewControllerMethod
                                              param:param];
    
    [self.navigationController pushViewController:chatVC animated:YES];
}

/**
 *操作 消息免打扰 开关后执行的函数
 */
- (void)onMessageDoNotDisturb:(TUICommonContactSwitchCell *)cell
{
    V2TIMReceiveMessageOpt opt;
    if (cell.switcher.on) {
        opt = V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
    } else {
        opt = V2TIM_RECEIVE_MESSAGE;
    }
    [[V2TIMManager sharedInstance] setC2CReceiveMessageOpt:@[self.friendProfile.userID] opt:opt succ:nil fail:nil];
}

/**
 *操作 置顶 开关后执行的函数，将对应好友添加/移除置顶队列
 */
- (void)onTopMostChat:(TUICommonContactSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUIConversationPin sharedInstance] addTopConversation:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            // 操作失败，还原
            cell.switcher.on = !cell.switcher.isOn;
            [TUITool makeToast:errorMessage];
        }];
    } else {
        [[TUIConversationPin sharedInstance] removeTopConversation:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID] callback:^(BOOL success, NSString * _Nonnull errorMessage) {
            if (success) {
                return;
            }
            // 操作失败，还原
            cell.switcher.on = !cell.switcher.isOn;
            [TUITool makeToast:errorMessage];
        }];
    }
}

/**
 *  以下两个函数实现了在好友界面长按的复制功能。
 */
- (void)addLongPressGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAtCell:)];
    [self.tableView addGestureRecognizer:longPress];
}

-(void) didLongPressAtCell:(UILongPressGestureRecognizer *)longPress {
    if(longPress.state == UIGestureRecognizerStateBegan){
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath *pathAtView = [self.tableView indexPathForRowAtPoint:point];
        NSObject *data = [self.tableView cellForRowAtIndexPath:pathAtView];

        //长按 TUIContactCommonTextCell，可以复制 cell 内的字符串。
        if([data isKindOfClass:[TUICommonContactTextCell class]]){
            TUICommonContactTextCell *textCell = (TUICommonContactTextCell *)data;
            if(textCell.textData.value && ![textCell.textData.value isEqualToString:@"未设置"]){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = textCell.textData.value;
                NSString *toastString = [NSString stringWithFormat:@"已将 %@ 复制到粘贴板",textCell.textData.key];
                [TUITool makeToast:toastString];
            }
        }else if([data isKindOfClass:[TUICommonContactProfileCardCell class]]){
            //长按 profileCard，复制好友的账号。
            TUICommonContactProfileCardCell *profileCard = (TUICommonContactProfileCardCell *)data;
            if(profileCard.cardData.identifier){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileCard.cardData.identifier;
                NSString *toastString = [NSString stringWithFormat:@"已将该用户账号复制到粘贴板"];
                [TUITool makeToast:toastString];
            }

        }
    }
}
/**
 *  点击头像查看大图的委托实现
 */
-(void)didTapOnAvatar:(TUICommonContactProfileCardCell *)cell{
    TUIContactAvatarViewController *image = [[TUIContactAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

@end
