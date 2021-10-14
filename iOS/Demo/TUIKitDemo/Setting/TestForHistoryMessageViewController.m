//
//  TestForHistoryMessageViewController.m
//  TUIKitDemo
//
//  Created by harvy on 2021/5/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TestForHistoryMessageViewController.h"
#import <TUIDefine.h>

@interface TestForHistoryMessageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *groupTextField;
@property (weak, nonatomic) IBOutlet UITextField *beginTimeField;
@property (weak, nonatomic) IBOutlet UITextField *periodTimeField;
@property (weak, nonatomic) IBOutlet UITextField *lastMessageField;
@property (weak, nonatomic) IBOutlet UITextField *lastMsgSeqTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *fetchCloudSwitch;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) V2TIMMessage *lastMessage;
@property (nonatomic, assign) NSUInteger lastMsgSeq;

@end

@implementation TestForHistoryMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.dataSource = [NSMutableArray array];
    self.lastMessage = nil;
    self.lastMsgSeq = 0;
    
}

- (void)setupViews {
    self.userIdTextField.placeholder = @"userId";
    self.groupTextField.placeholder = @"groupId";
    self.beginTimeField.placeholder = @"from, 时间戳";
    self.periodTimeField.placeholder = @"period, 时间范围，秒";
    self.lastMessageField.placeholder = @"不可填写，在tableView中选中某个cell";
    self.lastMessageField.enabled = YES;
    self.lastMsgSeqTextField.placeholder = @"seq,数值类型";
    self.countTextField.placeholder = @"拉取的消息个数，数值类型, 默认20";
    self.navigationItem.title = @"历史消息测试页面";
    
}

- (IBAction)actionForClear:(id)sender {
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)actionForOld:(id)sender {
    __weak typeof(self) weakSelf  = self;
    NSString *userID = self.userIdTextField.text;
    NSString *groupID = self.groupTextField.text;
    V2TIMMessageGetType getType = V2TIM_GET_LOCAL_OLDER_MSG;    // 默认本地更新
    if (self.fetchCloudSwitch.isOn) {
        getType = V2TIM_GET_CLOUD_OLDER_MSG;                    // 云端更新
    }
    NSUInteger lastMsgSeq = 0;
    lastMsgSeq = [self.lastMsgSeqTextField.text integerValue];
    
    NSUInteger begin = [self.beginTimeField.text integerValue];
    NSUInteger period = [self.periodTimeField.text integerValue];
    
    V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
    option.getType = getType;
    option.userID = userID;
    option.groupID = groupID;
    option.count = self.countTextField.text.length?self.countTextField.text.integerValue:20;
    option.lastMsg = self.lastMessageField.text.length?self.lastMessage:nil;
    option.lastMsgSeq = lastMsgSeq;
    option.getTimeBegin = begin;
    option.getTimePeriod = period;
    [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
        NSMutableArray *arrayM = [NSMutableArray arrayWithArray:msgs.reverseObjectEnumerator.allObjects];   // 倒叙
        [arrayM addObjectsFromArray:weakSelf.dataSource];
        weakSelf.dataSource = [NSMutableArray arrayWithArray:arrayM];
        [weakSelf.tableView reloadData];
        weakSelf.tipsLabel.text = [NSString stringWithFormat:@"本次拉取:%zd, 总数:%zd", msgs.count, weakSelf.dataSource.count];
    } fail:^(int code, NSString *desc) {
        weakSelf.tipsLabel.text = @"没有更多消息了";
    }];
}

- (IBAction)actionForNew:(id)sender {
    __weak typeof(self) weakSelf  = self;
    
    NSString *userID = self.userIdTextField.text;
    NSString *groupID = self.groupTextField.text;
    V2TIMMessageGetType getType = V2TIM_GET_LOCAL_NEWER_MSG;    // 默认本地更新
    if (self.fetchCloudSwitch.isOn) {
        getType = V2TIM_GET_CLOUD_NEWER_MSG;                    // 云端更新
    }
    NSUInteger lastMsgSeq = 0;
    lastMsgSeq = [self.lastMsgSeqTextField.text integerValue];
    
    NSUInteger begin = [self.beginTimeField.text integerValue];
    NSUInteger period = [self.periodTimeField.text integerValue];
    
    V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
    option.getType = getType;
    option.userID = userID;
    option.groupID = groupID;
    option.count = self.countTextField.text.length?self.countTextField.text.integerValue:20;
    option.lastMsg = self.lastMessageField.text.length?self.lastMessage:nil;
    option.lastMsgSeq = lastMsgSeq;
    option.getTimeBegin = begin;
    option.getTimePeriod = period;
    [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
        [weakSelf.dataSource addObjectsFromArray:msgs];
        [weakSelf.tableView reloadData];
        weakSelf.tipsLabel.text = [NSString stringWithFormat:@"本次拉取:%zd, 总数:%zd", msgs.count, weakSelf.dataSource.count];
    } fail:^(int code, NSString *desc) {
        weakSelf.tipsLabel.text = @"没有更多消息了";
    }];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    V2TIMMessage *message = self.dataSource[indexPath.row];
    cell.textLabel.text = [self getDisplayString:message];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"time:%0.0f, seq:%llu, rand:%llu", [message.timestamp timeIntervalSince1970], message.seq, message.random];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *rowActions = [NSMutableArray array];
    V2TIMMessage *message = self.dataSource[indexPath.row];
    __weak typeof(self) weakSelf = self;
    {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"设置lastMsg" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            weakSelf.lastMessage = message;
            weakSelf.lastMessageField.text = [NSString stringWithFormat:@"time:%0.0f, seq:%llu, rand:%llu", [message.timestamp timeIntervalSince1970], message.seq, message.random];;
        }];
        [rowActions addObject:action];
    }
    
    {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"设置lastMsgSeq" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            weakSelf.lastMsgSeq = message.seq;
            weakSelf.lastMsgSeqTextField.text = [NSString stringWithFormat:@"%zd", weakSelf.lastMsgSeq];
        }];
        [rowActions addObject:action];
    }
    
    
    return rowActions;
}

- (NSString *)getDisplayString:(V2TIMMessage *)msg
{
    NSString *str;
    if(msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED){
        if(msg.isSelf){
            str = @"你撤回了一条消息";
        }
        else if(msg.groupID != nil){
            //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
            NSString *userString = msg.nameCard;;
            if(userString.length == 0){
                userString = msg.nickName;
            }
            if (userString.length == 0) {
                userString = msg.sender;
            }
            str = [NSString stringWithFormat:@"\"%@\"撤回了一条消息", userString];
        }
        else if(msg.userID != nil){
            str = @"对方撤回了一条消息";
        }
    } else {
        switch (msg.elemType) {
            case V2TIM_ELEM_TYPE_TEXT:
            {
                // 处理表情的国际化
                NSString *content = msg.textElem.text;
                str = content;
            }
                break;
            case V2TIM_ELEM_TYPE_CUSTOM:
            {
                str = @"自定义消息";
            }
                break;
            case V2TIM_ELEM_TYPE_IMAGE:
            {
                str = @"[图片]";
            }
                break;
            case V2TIM_ELEM_TYPE_SOUND:
            {
                str = @"[语音]";
            }
                break;
            case V2TIM_ELEM_TYPE_VIDEO:
            {
                str = @"[视频]";
            }
                break;
            case V2TIM_ELEM_TYPE_FILE:
            {
                str = @"[文件]";
            }
                break;
            case V2TIM_ELEM_TYPE_FACE:
            {
                str = @"[动画表情]";
            }
                break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS:
            {
                str = @"[group tips]";
            }
                break;
            case V2TIM_ELEM_TYPE_MERGER:
            {
                str = @"合并消息";
            }
                break;
            default:
                break;
        }
    }
    return str;
}



@end
