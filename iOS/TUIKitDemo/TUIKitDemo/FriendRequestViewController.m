//
//  FriendRequestViewController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/4/18.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "FriendRequestViewController.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TPersonalCommonCell.h"
#import "THeader.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "TIMUserProfile+DataProvider.h"
#import <ReactiveObjC.h>

@interface FriendRequestViewController () <UITableViewDataSource, UITableViewDelegate>
@property UITableView *tableView;
@property UITextView  *addWordTextView;
@property UITextField *nickTextField;
@property UILabel *groupNameLabel;
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.title = @"添加好友";
    
    
    __block BOOL keyboardShown = NO;
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      filter:^BOOL(NSNotification *value) {
          return !keyboardShown;
      }]
     subscribeNext:^(NSNotification *x) {
         @strongify(self);
         keyboardShown = YES;
         [self adjustContentOffsetDuringKeyboardAppear:YES withNotification:x];
     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
      filter:^BOOL(NSNotification *value) {
          return keyboardShown;
      }]
     subscribeNext:^(NSNotification *x) {
         @strongify(self);
         keyboardShown = NO;
         [self adjustContentOffsetDuringKeyboardAppear:NO withNotification:x];
     }];
}

#pragma mark - Keyboard
- (void)adjustContentOffsetDuringKeyboardAppear:(BOOL)appear withNotification:(NSNotification *)notification {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrame);
    
    CGPoint offset = self.tableView.contentOffset;
    
    if (appear) {
        offset.y += keyboardHeight;
    } else {
        offset.y -= keyboardHeight;
    }
    CGFloat frameHeight = self.tableView.frame.size.height;
    frameHeight += appear? -keyboardHeight : keyboardHeight;
    CGSize contentSize = self.tableView.contentSize;
    contentSize.height += appear? -keyboardHeight : keyboardHeight;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.tableView.contentSize = contentSize;
        self.tableView.contentOffset = offset;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        return [TPersonalCommonCell getHeight];
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
        TPersonalCommonCell *cell = [[TPersonalCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TPersonalCommonCell_ReuseId"];
        TPersonalCommonCellData *data = [TPersonalCommonCellData new];
        data.name = [self.profile showName];
        data.identifier = self.profile.identifier;
        data.signature =  [self.profile showSignature];
        data.head = TUIKitResource(@"default_head");
        [cell setData:data];
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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"发送请求";
    
    TIMFriendRequest *req = [[TIMFriendRequest alloc] init];
    req.addWording = self.addWordTextView.text;
    req.remark = self.nickTextField.text;
    req.group = self.groupNameLabel.text;
    req.identifier = self.profile.identifier;
    req.addSource = @"iOS";
    [[TIMFriendshipManager sharedInstance] addFriend:req succ:^(TIMFriendResult *result) {
        hud.mode = MBProgressHUDModeText;
        if (result.result_code == 0) {
            hud.label.text = @"发送成功";
        } else {
            hud.label.text = [NSString stringWithFormat:@"%ld:%@", (long)result.result_code, result.result_info];
        }
        [hud hideAnimated:YES afterDelay:3];
    } fail:^(int code, NSString *msg) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = msg;
        [hud hideAnimated:YES afterDelay:3];
    }];
}

- (void)onCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
