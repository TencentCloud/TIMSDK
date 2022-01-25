//
//  FriendRequestViewController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/4/18.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
/** 腾讯云IM Demo 添加好友视图
 *  本文件实现了添加好友时的视图，在您想要添加其他用户为好友时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import "FriendRequestViewController.h"
#import "UIView+TUILayout.h"
#import "TUIProfileCardCell.h"
#import "TUICommonModel.h"
#import "TUICommonSwitchCell.h"
#import "TUIAvatarViewController.h"
#import <ReactiveObjC.h>
#import "TUIKit.h"
#import "TCUtil.h"
#import "TUIDefine.h"
#import "TUINaviBarIndicatorView.h"
#import "TUIThemeManager.h"

@interface FriendRequestViewController () <UITableViewDataSource, UITableViewDelegate>
@property UITableView *tableView;
@property UITextView  *addWordTextView;
@property UITextField *nickTextField;
@property UILabel *groupNameLabel;
@property BOOL keyboardShown;
@property TUIProfileCardCellData *cardCellData;
@property TUICommonSwitchCellData *singleSwitchData;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化视图内的组件
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    self.addWordTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.addWordTextView.font = [UIFont systemFontOfSize:14];

    NSString * selfUserID = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[selfUserID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            if (infoList && infoList.count > 0) {
                V2TIMUserFullInfo * userInfo = [infoList firstObject];
                if (userInfo) {
                    self.addWordTextView.text = [NSString stringWithFormat:NSLocalizedString(@"FriendRequestFormat", nil), userInfo.nickName?userInfo.nickName:userInfo.userID];
                }
            }
        } fail:^(int code, NSString *desc) {
            
        }];

    self.nickTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nickTextField.textAlignment = NSTextAlignmentRight;


    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"FriendRequestFillInfo", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    TUIProfileCardCellData *data = [TUIProfileCardCellData new];
    data.name = [self.profile showName];
    data.genderString = [self.profile showGender];
    data.identifier = self.profile.userID;
    data.signature =  [self.profile showSignature];
    data.avatarImage = DefaultAvatarImage;
    data.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    data.showSignature = YES;
    self.cardCellData = data;


    self.singleSwitchData = [TUICommonSwitchCellData new];
    self.singleSwitchData.title = NSLocalizedString(@"FriendOneWay", nil);


    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      filter:^BOOL(NSNotification *value) {
          @strongify(self);
          return !self.keyboardShown;
      }]
     subscribeNext:^(NSNotification *x) {
         @strongify(self);
         self.keyboardShown = YES;
         [self adjustContentOffsetDuringKeyboardAppear:YES withNotification:x];
     }];

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
      filter:^BOOL(NSNotification *value) {
          @strongify(self);
          return self.keyboardShown;
      }]
     subscribeNext:^(NSNotification *x) {
         @strongify(self);
         self.keyboardShown = NO;
         [self adjustContentOffsetDuringKeyboardAppear:NO withNotification:x];
     }];
}

#pragma mark - Keyboard
/**
 *根据键盘的上浮与下沉，使组件一起浮动，保证视图不被键盘遮挡
 */
- (void)adjustContentOffsetDuringKeyboardAppear:(BOOL)appear withNotification:(NSNotification *)notification {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrame);


    CGSize contentSize = self.tableView.contentSize;
    contentSize.height += appear? -keyboardHeight : keyboardHeight;

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.tableView.contentSize = contentSize;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        return [self.cardCellData heightOfWidth:Screen_Width];
    }
    if (indexPath.section == 1) {
        return 120;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
    label.font = [UIFont systemFontOfSize:14.0];
    if (section == 1) {
        label.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"please_fill_in_verification_information", nil)];
    } else if (section == 2) {
        label.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"please_fill_in_remarks_group_info", nil)];// @"填写备注与分组";
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0 : 38;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    }
    return 1;
}

/**
 *初始化tableView的信息单元
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TUIProfileCardCell *cell = [[TUIProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TPersonalCommonCell_ReuseId"];
        //设置 profileCard 的委托
        cell.delegate = self;
        [cell fillWithData:self.cardCellData];
        return cell;
    }
    if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddWord"];
        [cell.contentView addSubview:self.addWordTextView];
        self.addWordTextView.mm_width(Screen_Width).mm_height(120);
        return cell;
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NickName"];
            cell.textLabel.text = NSLocalizedString(@"Alia", nil); // @"备注";
            [cell.contentView addSubview:self.nickTextField];
            
            UIView *separtor = [[UIView alloc] init];
            separtor.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [cell.contentView addSubview:separtor];
            separtor.mm_width(tableView.mm_w).mm_bottom(0).mm_left(0).mm_height(1);
            
            self.nickTextField.mm_width(cell.contentView.mm_w/2).mm_height(cell.contentView.mm_h).mm_right(20);
            self.nickTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            
            
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GroupName"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"Group", nil); // @"分组";
            cell.detailTextLabel.text = NSLocalizedString(@"my_friend", nil); // @"我的朋友";
            self.groupNameLabel = cell.detailTextLabel;
            
            UIView *separtor = [[UIView alloc] init];
            separtor.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [cell.contentView addSubview:separtor];
            separtor.mm_width(tableView.mm_w).mm_bottom(0).mm_left(0).mm_height(1);
            
            return cell;
        }
    }
    if (indexPath.section == 3) {
        TUIButtonCell *cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"send"];
        TUIButtonCellData *data = [[TUIButtonCellData alloc] init];
        data.style = ButtonWhite;
        data.title = NSLocalizedString(@"Send", nil);
        data.cselector = @selector(onSend);
        data.textColor = TUICoreDynamicColor(@"primary_theme_color", @"147AFF"); //[UIColor colorWithRed:20/255.0 green:122/255.0 blue:255/255.0 alpha:1/1.0];
        [cell fillWithData:data];
        
        return cell;
    }

    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/**
 *发送好友请求，包含请求后的回调
 */
- (void)onSend
{
    [self.view endEditing:YES];
    // display toast with an activity spinner
    [TUITool makeToastActivity];
    
    V2TIMFriendAddApplication *application = [[V2TIMFriendAddApplication alloc] init];
    application.addWording = self.addWordTextView.text;
    application.friendRemark = self.nickTextField.text;
    //application.group = self.groupNameLabel.text;
    application.userID = self.profile.userID;
    application.addSource = @"iOS";
    if (self.singleSwitchData.on) {
        application.addType = V2TIM_FRIEND_TYPE_SINGLE;
    } else {
        application.addType = V2TIM_FRIEND_TYPE_BOTH;
    }
    
    [[V2TIMManager sharedInstance] addFriend:application succ:^(V2TIMFriendOperationResult *result) {
        NSString *msg = [NSString stringWithFormat:@"%ld", (long)result.resultCode];
        //根据回调类型向用户展示添加结果
        if (result.resultCode == ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM) {
            msg = NSLocalizedString(@"FriendAddResultSuccessWait", nil); // @"发送成功,等待审核同意";
        }
        if (result.resultCode == ERR_SVR_FRIENDSHIP_ALLOW_TYPE_DENY_ANY) {
            msg = NSLocalizedString(@"FriendAddResultForbid", nil); // @"对方禁止添加";
        }
        if (result.resultCode == 0) {
            msg = NSLocalizedString(@"FriendAddResultSuccess", nil); // @"已添加到好友列表";
        }
        if (result.resultCode == ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS) {
            msg = NSLocalizedString(@"FriendAddResultExists", nil); // @"好友已存在";
        }

        [TUITool hideToastActivity];
        [TUITool makeToast:msg duration:3.0 idposition:TUICSToastPositionBottom];
    } fail:^(int code, NSString *desc) {
        [TUITool hideToastActivity];
        [TUITool makeToastError:code msg:desc];
    }];

    [TCUtil report:Action_Addfriend actionSub:@"" code:@(0) msg:@"addfriend"];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


/**
 *  点击头像查看大图的委托实现。
 */
-(void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

@end
