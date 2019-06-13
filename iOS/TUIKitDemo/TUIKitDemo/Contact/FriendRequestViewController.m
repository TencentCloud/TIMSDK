//
//  FriendRequestViewController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/4/18.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "FriendRequestViewController.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIProfileCardCell.h"
#import "THeader.h"
#import "TIMUserProfile+DataProvider.h"
#import "Toast/Toast.h"
#import <ReactiveObjC.h>
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"

@interface FriendRequestViewController () <UITableViewDataSource, UITableViewDelegate>
@property UITableView *tableView;
@property UITextView  *addWordTextView;
@property UITextField *nickTextField;
@property UILabel *groupNameLabel;
@property BOOL keyboardShown;
@property TUIProfileCardCellData *cardCellData;
@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    data.identifier = self.profile.identifier;
    data.signature =  [self.profile showSignature];
    data.avatarImage = DefaultAvatarImage;
    self.cardCellData = data;
    
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
    if (indexPath.section == 2) {
        return 44;
    }
    return 0.;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 3;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TUIProfileCardCell *cell = [[TUIProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TPersonalCommonCell_ReuseId"];
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
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

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
    [[TIMFriendshipManager sharedInstance] addFriend:req succ:^(TIMFriendResult *result) {
        NSString *msg = [NSString stringWithFormat:@"%ld", (long)result.result_code];
        if (result.result_code == TIM_ADD_FRIEND_STATUS_PENDING) {
            msg = @"发送成功";
        }
        if (result.result_code == TIM_ADD_FRIEND_STATUS_FRIEND_SIDE_FORBID_ADD) {
            msg = @"对方禁止添加";
        }
        if (result.result_code == 0) {
            msg = @"添加成功";
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
        [self.view makeToast:msg
                    duration:3.0
                    position:CSToastPositionBottom];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
@end
