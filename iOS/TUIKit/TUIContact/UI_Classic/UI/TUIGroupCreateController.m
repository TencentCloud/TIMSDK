//
//  TUIGroupCreateController.m
//  TUIContact
//
//  Created by wyl on 2022/8/22.
//

#import "TUIGroupCreateController.h"
#import "TUIGroupTypeListController.h"
#import <TUICore/UIView+TUILayout.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUILogin.h>

@interface TUIGroupCreateController () <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *groupNameTextField;
@property (nonatomic, strong) UITextField *groupIDTextField;
@property (nonatomic, assign) BOOL keyboardShown;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UITextView *describeTextView;
@property (nonatomic, assign) CGRect describeTextViewRect;
@property (nonatomic, strong) TUIContactListPicker *pickerView;

@property (nonatomic, strong) UIImage * cacheGroupGridAvatarImage;

@end


@implementation TUIGroupCreateController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _pickerView.mm_width(self.view.mm_w).mm_height(60+_pickerView.mm_safeAreaBottomGap).mm_bottom(0);
    _tableView.mm_width(self.view.mm_w).mm_flexToBottom(_pickerView.mm_h);
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
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

    self.groupNameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.groupNameTextField.textAlignment = NSTextAlignmentRight;
    self.groupNameTextField.placeholder = TIMCommonLocalizableString(TUIKitCreatGroupNamed_Placeholder);
    self.groupNameTextField.delegate = self;
    if (IS_NOT_EMPTY_NSSTRING(self.createGroupInfo.groupName)) {
        self.groupNameTextField.text = self.createGroupInfo.groupName;
    }
    self.groupIDTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.groupIDTextField.textAlignment = NSTextAlignmentRight;
    self.groupIDTextField.keyboardType =  UIKeyboardTypeDefault;
    self.groupIDTextField.placeholder = TIMCommonLocalizableString(TUIKitCreatGroupID_Placeholder);
    self.groupIDTextField.delegate = self;
    
    [self updateRectAndTextForDescribeTextView:self.describeTextView];
    
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(ChatsNewGroupText)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    _pickerView = [[TUIContactListPicker alloc] initWithFrame:CGRectZero];
    [_pickerView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.view addSubview:_pickerView];
    _pickerView.accessoryBtn.enabled = YES;
    [_pickerView.accessoryBtn addTarget:self action:@selector(finishTask) forControlEvents:UIControlEventTouchUpInside];

    [self creatGroupAvatarImage];

}

- (UITextView *)describeTextView {
    if (!_describeTextView) {
       _describeTextView = [[UITextView alloc] init];
       _describeTextView.backgroundColor = [UIColor clearColor];
       _describeTextView.editable = NO;
       _describeTextView.scrollEnabled = NO;
       _describeTextView.textContainerInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    }
    return  _describeTextView;
}
- (void)creatGroupAvatarImage {
    
    if (!TUIConfig.defaultConfig.enableGroupGridAvatar) {
        return;
    }
    if (_cacheGroupGridAvatarImage) {
        return ;
    }
    NSMutableArray *muArray = [NSMutableArray array];
    for (TUICommonContactSelectCellData *cellData in self.createContactArray) {
        if (cellData.avatarUrl.absoluteString.length > 0) {
            [muArray addObject:cellData.avatarUrl.absoluteString];
        }
        else {
            [muArray addObject:@"about:blank"];
        }
        
    }
    //currentUser
    [muArray addObject:[TUILogin getFaceUrl]?:@""];
    
    @weakify(self)
    [TUIGroupAvatar createGroupAvatar:muArray finished:^(UIImage *groupAvatar) {
        @strongify(self)
        self.cacheGroupGridAvatarImage = groupAvatar;
        [self.tableView reloadData];
    }];
}

- (void)updateRectAndTextForDescribeTextView:(UITextView *)describeTextView {
    
    __block NSString *descStr = @"";
    [self.class getfomatDescribeType:self.createGroupInfo.groupType completion:^(NSString *groupTypeStr, NSString *groupTypeDescribeStr) {
        descStr = groupTypeDescribeStr;
    }];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 18;
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    NSDictionary * dictionary = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName:[UIColor tui_colorWithHex:@"#888888"],
                                  NSParagraphStyleAttributeName : paragraphStyle
    };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:descStr attributes:dictionary];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [descStr length])];
    NSString * inviteTipstring = TIMCommonLocalizableString(TUIKitCreatGroupType_Desc_Highlight);
    [attributedString addAttribute:NSLinkAttributeName value:@"https://cloud.tencent.com/product/im" range:[descStr rangeOfString:inviteTipstring]];
    self.describeTextView.attributedText = attributedString;
    
    CGRect rect = [self.describeTextView.text boundingRectWithSize:CGSizeMake(self.view.mm_w - 32, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                               NSParagraphStyleAttributeName : paragraphStyle
                                                            }
                                                    context:nil];
    self.describeTextViewRect = rect;
}

#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 2) {
        return 88;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    if (section == 2) {
        [view addSubview:self.describeTextView];
        _describeTextView
            .mm_width(_describeTextViewRect.size.width)
            .mm_height(_describeTextViewRect.size.height)
            .mm_top(10)
            .mm_left(15);
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 2 ? _describeTextViewRect.size.height + 20 : 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([self.createGroupInfo.groupType isEqualToString:@"Community"]) {
            self.groupIDTextField.text = @"";
            return 1;
        }
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"groupName"];
            cell.textLabel.text = TIMCommonLocalizableString(TUIKitCreatGroupNamed);
            [cell.contentView addSubview:self.groupNameTextField];
            cell.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
            self.groupNameTextField.mm_width(cell.contentView.mm_w/2).mm_height(cell.contentView.mm_h).mm_right(16);
            self.groupNameTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"groupID"];
            cell.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
            cell.textLabel.text = TIMCommonLocalizableString(TUIKitCreatGroupID);
            [cell.contentView addSubview:self.groupIDTextField];
            self.groupIDTextField.mm_width(cell.contentView.mm_w/2).mm_height(cell.contentView.mm_h).mm_right(16);
            self.groupIDTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            return cell;
        }
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GroupType"];
        cell.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = TIMCommonLocalizableString(TUIKitCreatGroupType);
        [self.class getfomatDescribeType:self.createGroupInfo.groupType completion:^(NSString *groupTypeStr, NSString *groupTypeDescribeStr) {
            cell.detailTextLabel.text = groupTypeStr;
        }];
    
        return cell;
    }
    else if (indexPath.section == 2) {
    
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GroupType"];
        cell.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = TIMCommonLocalizableString(TUIKitCreatGroupAvatar);
        UIImageView *headImage = [[UIImageView alloc] initWithImage:DefaultGroupAvatarImageByGroupType(self.createGroupInfo.groupType)];
        [cell.contentView addSubview:headImage];
        if (TUIConfig.defaultConfig.enableGroupGridAvatar && self.cacheGroupGridAvatarImage) {
            [headImage sd_setImageWithURL:[NSURL URLWithString:self.createGroupInfo.faceURL] placeholderImage:self.cacheGroupGridAvatarImage];
        }
        CGFloat margin =  5 ;
        headImage.frame = CGRectMake((cell.mm_w  - 48 - margin), (88 - 48)/2, 48, 48);
        headImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        return cell;
    }


    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.section == 1) {
        TUIGroupTypeListController *vc = [[TUIGroupTypeListController alloc] init];
        vc.title = @"";
        [self.navigationController pushViewController:vc animated:YES];
        @weakify(self)
        vc.selectCallBack = ^(NSString * _Nonnull groupType) {
            @strongify(self)
            self.createGroupInfo.groupType = groupType;
            [self updateRectAndTextForDescribeTextView:self.describeTextView];
            [self.tableView reloadData];
        };
        
    }
    else if (indexPath.section == 2) {
        [self didTapToChooseAvatar];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - textField
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.groupNameTextField) {
        if (textField.text.length > 10) {
             textField.text = [textField.text substringToIndex: 10];
         }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Check for total length
   if (textField == self.groupIDTextField) {
        NSUInteger lengthOfString = string.length;
        for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
            unichar character = [string characterAtIndex:loopIndex];
            if (character < 48) return NO; // 48 unichar for 0
            if (character > 57 && character < 65) return NO;
            if (character > 90 && character < 97) return NO;
            if (character > 122) return NO;
        }
        // Check for total length
        NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
        if (proposedNewLength > 10) {
            return NO;
        }
        return YES;

    }
    return YES;
}

#pragma mark - format
+ (void)getfomatDescribeType:(NSString*) groupType completion:(void (^)(NSString *groupTypeStr,NSString *groupTypeDescribeStr))completion {
    
    if (!completion) {
        return;
    }
    NSString *desc = @"";
    if ([groupType isEqualToString:@"Work"]) {
        desc = [NSString stringWithFormat:@"%@\n%@",TIMCommonLocalizableString(TUIKitCreatGroupType_Work_Desc) ,TIMCommonLocalizableString(TUIKitCreatGroupType_See_Doc)];
        completion(TIMCommonLocalizableString(TUIKitCreatGroupType_Work),desc);
    }
    else if ([groupType isEqualToString:@"Public"]) {
        desc = [NSString stringWithFormat:@"%@\n%@",TIMCommonLocalizableString(TUIKitCreatGroupType_Public_Desc) ,TIMCommonLocalizableString(TUIKitCreatGroupType_See_Doc)];
        completion(TIMCommonLocalizableString(TUIKitCreatGroupType_Public),desc);
    }
    else if ([groupType isEqualToString:@"Meeting"]) {
        desc = [NSString stringWithFormat:@"%@\n%@",TIMCommonLocalizableString(TUIKitCreatGroupType_Meeting_Desc) ,TIMCommonLocalizableString(TUIKitCreatGroupType_See_Doc)];
        completion(TIMCommonLocalizableString(TUIKitCreatGroupType_Meeting),desc);
    }
    else if ([groupType isEqualToString:@"Community"]) {
        desc = [NSString stringWithFormat:@"%@\n%@",TIMCommonLocalizableString(TUIKitCreatGroupType_Community_Desc) ,TIMCommonLocalizableString(TUIKitCreatGroupType_See_Doc)];
        completion(TIMCommonLocalizableString(TUIKitCreatGroupType_Community),desc);
    }
    else {
        completion(groupType,groupType);
    }
}
#pragma mark - action

- (void)didTapToChooseAvatar {
    TUISelectAvatarController * vc = [[TUISelectAvatarController alloc] init];
    vc.selectAvatarType = TUISelectAvatarTypeGroupAvatar;
    vc.createGroupType = self.createGroupInfo.groupType;
    vc.cacheGroupGridAvatarImage = self.cacheGroupGridAvatarImage;
    vc.profilFaceURL = self.createGroupInfo.faceURL;
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    vc.selectCallBack = ^(NSString * _Nonnull urlStr) {
        if (urlStr.length > 0) {
            @strongify(self)
            self.createGroupInfo.faceURL = urlStr;
        }
        else {
            self.createGroupInfo.faceURL = nil;
        }
        [self.tableView reloadData];
    };
}
- (void)finishTask {

    self.createGroupInfo.groupName = self.groupNameTextField.text;
    self.createGroupInfo.groupID = self.groupIDTextField.text ;

    V2TIMGroupInfo* info = self.createGroupInfo;
    if (!info) {
        return;
    }
    if (!self.createContactArray) {
        return;
    }
    
    NSMutableArray *members = [NSMutableArray array];
    for (TUICommonContactSelectCellData *item in self.createContactArray) {
        V2TIMCreateGroupMemberInfo *member = [[V2TIMCreateGroupMemberInfo alloc] init];
        member.userID = item.identifier;
        member.role = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
        [members addObject:member];
    }
    
    NSString *showName = [TUILogin getNickName]?:[TUILogin getUserID];

    @weakify(self)
    [[V2TIMManager sharedInstance] createGroup:info memberList:members succ:^(NSString *groupID) {
        @strongify(self)
        NSString *content = nil;
        if([info.groupType isEqualToString:GroupType_Work]) {
            content = TIMCommonLocalizableString(ChatsCreatePrivateGroupTips);
        } else if([info.groupType isEqualToString:GroupType_Public]){
            content = TIMCommonLocalizableString(ChatsCreateGroupTips);
        } else if([info.groupType isEqualToString:GroupType_Meeting]) {
            content = TIMCommonLocalizableString(ChatsCreateChatRoomTips);
        } else if([info.groupType isEqualToString:GroupType_Community]) {
            content = TIMCommonLocalizableString(ChatsCreateCommunityTips);
        } else {
            content = TIMCommonLocalizableString(ChatsCreateDefaultTips);
        }
        NSDictionary *dic = @{@"version": @(GroupCreate_Version),
                              BussinessID: BussinessID_GroupCreate,
                              @"opUser": showName,
                              @"content": content
        };
        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:data];
        [[V2TIMManager sharedInstance] sendMessage:msg receiver:nil groupID:groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:nil progress:nil succ:nil fail:nil];
        self.createGroupInfo.groupID = groupID;
        // wait for a second to ensure the group created message arrives first
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.submitCallback) {
                self.submitCallback(YES,self.createGroupInfo);
            }
        });
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
            [TUITool postUnsupportNotificationOfService:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunity) serviceDesc:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunityDesc) debugOnly:YES];
        }
        else {
            NSString *toastMsg = nil;
            toastMsg = [TUITool convertIMError:code msg:msg];
            if (toastMsg.length == 0) {
                toastMsg = [NSString stringWithFormat:@"%ld", (long)code];
            }
            [TUITool hideToastActivity];
            [TUITool makeToast:toastMsg duration:3.0 idposition:TUICSToastPositionBottom];
        }
        if (self.submitCallback) {
            self.submitCallback(NO,self.createGroupInfo);
        }
    }];
}


@end

