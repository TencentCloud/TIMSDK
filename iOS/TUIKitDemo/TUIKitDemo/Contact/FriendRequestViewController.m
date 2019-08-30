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
#import "MMLayout/UIView+MMLayout.h"
#import "TUIProfileCardCell.h"
#import "THeader.h"
#import "TIMUserProfile+DataProvider.h"
#import "Toast/Toast.h"
#import <ReactiveObjC.h>
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"
#import "TCommonSwitchCell.h"
#import "THelper.h"
#import "TUIAvatarViewController.h"

@interface FriendRequestViewController () <UITableViewDataSource, UITableViewDelegate>
@property UITableView *tableView;
@property UITextView  *addWordTextView;
@property UITextField *nickTextField;
@property UILabel *groupNameLabel;
@property BOOL keyboardShown;
@property TUIProfileCardCellData *cardCellData;
@property TCommonSwitchCellData *singleSwitchData;
@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化视图内的组件
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;


    self.addWordTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.addWordTextView.font = [UIFont systemFontOfSize:14];
    [[TIMFriendshipManager sharedInstance] getSelfProfile:^(TIMUserProfile *profile) {
        self.addWordTextView.text = [NSString stringWithFormat:@"我是%@", profile.nickname.length?profile.nickname:profile.identifier];
    } fail:^(int code, NSString *msg) {

    }];

    self.nickTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nickTextField.textAlignment = NSTextAlignmentRight;


    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(onSend)];
    self.title = @"填写信息";

    TUIProfileCardCellData *data = [TUIProfileCardCellData new];
    data.name = [self.profile showName];
    data.genderString = [self.profile showGender];
    data.identifier = self.profile.identifier;
    data.signature =  [self.profile showSignature];
    data.avatarImage = DefaultAvatarImage;
    data.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    self.cardCellData = data;


    self.singleSwitchData = [TCommonSwitchCellData new];
    self.singleSwitchData.title = @"单向好友";


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

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return @"填写验证信息";
    if (section == 2)
        return @"填写备注与分组";
    return nil;
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
            cell.textLabel.text = @"备注";
            [cell.contentView addSubview:self.nickTextField];
            self.nickTextField.mm_width(cell.contentView.mm_w/2).mm_height(cell.contentView.mm_h).mm_right(20);
            self.nickTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GroupName"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"分组";
            cell.detailTextLabel.text = @"我的朋友";
            self.groupNameLabel = cell.detailTextLabel;
            return cell;
        }
    }
    if (indexPath.section == 3) {
        TCommonSwitchCell *cell = [[TCommonSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"];
        [cell fillWithData:self.singleSwitchData];
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
    [self.view makeToastActivity:CSToastPositionCenter];

    TIMFriendRequest *req = [[TIMFriendRequest alloc] init];
    req.addWording = self.addWordTextView.text;
    req.remark = self.nickTextField.text;
    req.group = self.groupNameLabel.text;
    req.identifier = self.profile.identifier;
    req.addSource = @"iOS";
    if (self.singleSwitchData.on) {
        req.addType = TIM_FRIEND_ADD_TYPE_SINGLE;
    } else {
        req.addType = TIM_FRIEND_ADD_TYPE_BOTH;
    }
    [[TIMFriendshipManager sharedInstance] addFriend:req succ:^(TIMFriendResult *result) {
        NSString *msg = [NSString stringWithFormat:@"%ld", (long)result.result_code];
        //根据回调类型向用户展示添加结果
        if (result.result_code == TIM_ADD_FRIEND_STATUS_PENDING) {
            msg = @"发送成功,等待审核同意";
        }
        if (result.result_code == TIM_ADD_FRIEND_STATUS_FRIEND_SIDE_FORBID_ADD) {
            msg = @"对方禁止添加";
        }
        if (result.result_code == 0) {
            msg = @"已添加到好友列表";
        }
        if (result.result_code == TIM_FRIEND_PARAM_INVALID) {
            msg = @"好友已存在";
        }

        [self.view hideToastActivity];
        [self.view makeToast:msg
                    duration:3.0
                    position:CSToastPositionBottom];

    } fail:^(int code, NSString *msg) {
        [self.view hideToastActivity];
        [THelper makeToastError:code msg:msg];
    }];
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
