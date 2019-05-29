//
//  QuickContactsTestViewController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/9.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "QuickContactsTestViewController.h"
#import "UIView+MMLayout.h"
#import "TIMFriendshipManager.h"
#import "THeader.h"

@interface QuickContactsTestViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property UITextField *idInputField;
@property UITextField *propField;
@property UITextField *valueField;
@property UITextView *msgLabel;
@property UIPickerView *agreeFriendPicker;
@property UIPickerView *changeFriendPicker;
@end

@implementation QuickContactsTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.msgLabel = [[UITextView alloc] initWithFrame:CGRectZero];
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    self.msgLabel.backgroundColor = [UIColor lightGrayColor];
    self.msgLabel.editable = NO;
    [self.view addSubview:self.msgLabel];
    self.msgLabel.mm_width(self.view.mm_w).mm_height(120).mm_bottom(60);
    
    self.idInputField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.idInputField];
    self.idInputField.borderStyle = UITextBorderStyleLine;
    self.idInputField.mm_top(80).mm_left(8).mm_width(100).mm_height(40);
    
    self.propField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.propField];
    self.propField.borderStyle = UITextBorderStyleLine;
    self.propField.mm_width(100).mm_height(40).mm_hstack(8);
    
    self.valueField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.valueField];
    self.valueField.borderStyle = UITextBorderStyleLine;
    self.valueField.mm_width(100).mm_height(40).mm_hstack(8);
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [addBtn setTitle:@"加好友" forState:UIControlStateNormal];
    [self.view addSubview:addBtn];
    [addBtn sizeToFit];
    addBtn.mm_sizeToFit().mm_vstack(8).mm_left(8);
    [addBtn addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *getBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [getBtn setTitle:@"拉好友" forState:UIControlStateNormal];
    [self.view addSubview:getBtn];
    getBtn.mm_sizeToFit().mm_hstack(8);
    [getBtn addTarget:self action:@selector(getFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [agreeBtn setTitle:@"同意好友" forState:UIControlStateNormal];
    [self.view addSubview:agreeBtn];
    agreeBtn.mm_sizeToFit().mm_hstack(8);
    [agreeBtn addTarget:self action:@selector(agreeFriend:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [changeBtn setTitle:@"修改好友" forState:UIControlStateNormal];
    [self.view addSubview:changeBtn];
    changeBtn.mm_sizeToFit().mm_hstack(8);
    [changeBtn addTarget:self action:@selector(changeFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteBtn setTitle:@"删好友" forState:UIControlStateNormal];
    [self.view addSubview:deleteBtn];
    deleteBtn.mm_sizeToFit().mm_hstack(8);
    [deleteBtn addTarget:self action:@selector(deleteFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addBlackListBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [addBlackListBtn setTitle:@"加黑名单" forState:UIControlStateNormal];
    [self.view addSubview:addBlackListBtn];
    addBlackListBtn.mm_sizeToFit().mm_vstack(8).mm_left(8);
    [addBlackListBtn addTarget:self action:@selector(addBlackList:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *delBlackListBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [delBlackListBtn setTitle:@"删黑名单" forState:UIControlStateNormal];
    [self.view addSubview:delBlackListBtn];
    delBlackListBtn.mm_sizeToFit().mm_hstack(8);
    [delBlackListBtn addTarget:self action:@selector(delBlackList:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *getBlackListBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [getBlackListBtn setTitle:@"获取黑名单" forState:UIControlStateNormal];
    [self.view addSubview:getBlackListBtn];
    getBlackListBtn.mm_sizeToFit().mm_hstack(8);
    [getBlackListBtn addTarget:self action:@selector(getBlackList:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *getPendencyListBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [getPendencyListBtn setTitle:@"获取未决列表" forState:UIControlStateNormal];
    [self.view addSubview:getPendencyListBtn];
    getPendencyListBtn.mm_sizeToFit().mm_vstack(8).mm_left(8);
    [getPendencyListBtn addTarget:self action:@selector(getPendencyList:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *pendencyReportBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [pendencyReportBtn setTitle:@"未决已读上报" forState:UIControlStateNormal];
    [self.view addSubview:pendencyReportBtn];
    pendencyReportBtn.mm_sizeToFit().mm_hstack(8);
    [pendencyReportBtn addTarget:self action:@selector(pendencyReport:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *deletePendencyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [deletePendencyBtn setTitle:@"未决删除" forState:UIControlStateNormal];
    [self.view addSubview:deletePendencyBtn];
    deletePendencyBtn.mm_sizeToFit().mm_hstack(8);
    [deletePendencyBtn addTarget:self action:@selector(deletePendency:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *createGroupBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [createGroupBtn setTitle:@"新建分组" forState:UIControlStateNormal];
    [self.view addSubview:createGroupBtn];
    createGroupBtn.mm_sizeToFit().mm_vstack(8).mm_left(8);
    [createGroupBtn addTarget:self action:@selector(createGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *getGroupBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [getGroupBtn setTitle:@"拉取分组" forState:UIControlStateNormal];
    [self.view addSubview:getGroupBtn];
    getGroupBtn.mm_sizeToFit().mm_hstack(8);
    [getGroupBtn addTarget:self action:@selector(getGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteGroupBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteGroupBtn setTitle:@"删分组" forState:UIControlStateNormal];
    [self.view addSubview:deleteGroupBtn];
    deleteGroupBtn.mm_sizeToFit().mm_hstack(8);
    [deleteGroupBtn addTarget:self action:@selector(deleteGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *renameGroupBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [renameGroupBtn setTitle:@"分组改名" forState:UIControlStateNormal];
    [self.view addSubview:renameGroupBtn];
    renameGroupBtn.mm_sizeToFit().mm_hstack(8);
    [renameGroupBtn addTarget:self action:@selector(renameGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addFriendGroupBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [addFriendGroupBtn setTitle:@"添加分组用户" forState:UIControlStateNormal];
    [self.view addSubview:addFriendGroupBtn];
    addFriendGroupBtn.mm_sizeToFit().mm_vstack(8).mm_left(8);
    [addFriendGroupBtn addTarget:self action:@selector(addFriendsToFriendGroup:) forControlEvents:UIControlEventTouchUpInside];
  
    UIButton *deleteFriendGroupBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteFriendGroupBtn setTitle:@"移除分组用户" forState:UIControlStateNormal];
    [self.view addSubview:deleteFriendGroupBtn];
    deleteFriendGroupBtn.mm_sizeToFit().mm_hstack(8);
    [deleteFriendGroupBtn addTarget:self action:@selector(delFriendsFromFriendGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddFriends:) name:TUIKitNotification_onAddFriends object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDelFriends:) name:TUIKitNotification_onDelFriends object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddFriendReqs:) name:TUIKitNotification_onAddFriendReqs object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendProfileUpdate:) name:TUIKitNotification_onFriendProfileUpdate object:nil];

}

- (NSArray<NSString *> *)getIds
{
    NSString *text = self.idInputField.text;
    NSArray *ret = [text componentsSeparatedByString:@","];
    if (ret.count == 0)
        return @[];
    return ret;
}

- (id)getProp
{
    NSString *text = self.propField.text;
    if ([text containsString:@","]) {
        return [text componentsSeparatedByString:@","];
    }
    return text;
}

- (NSArray *)getProps
{
    return [self.propField.text componentsSeparatedByString:@","];
}

- (id)getValue
{
    NSString *text = self.valueField.text;
    if ([text containsString:@","]) {
        return [text componentsSeparatedByString:@","];
    }
    return text;
}

- (int)getPropInt
{
    NSString *text = self.idInputField.text;
    return [text intValue];
}

- (void)addFriend:(id)sender
{
    TIMFriendRequest *q = [TIMFriendRequest new];
    q.identifier = [self getIds][0];
    q.addWording = @"求通过";
    q.addSource = @"AddSource_Type_iOS";
    q.remark = @"JJJ";
    [[TIMFriendshipManager sharedInstance] addFriend:q succ:^(TIMFriendResult *result) {
        if (result.result_code == 0)
            self.msgLabel.text = @"OK";
        else
            self.msgLabel.text = [NSString stringWithFormat:@"异常：%@, %ld, %@", result.identifier, (long)result.result_code, result.result_info];
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)getFriend:(id)sender
{

    [[TIMFriendshipManager sharedInstance] getFriendList:^(NSArray<TIMFriend *> *friends) {
        NSMutableString *msg = [NSMutableString new];
        [msg appendString:@"好友列表: "];
        for (TIMFriend *friend in friends) {
            [msg appendFormat:@"[%@,%@,%llu,%@,%@,%@]", friend.identifier, friend.remark, friend.addTime, friend.addSource, friend.addWording, friend.groups];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
       self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)onAddFriendReqs:(NSNotification *)notification
{
    NSArray<TIMFriendPendencyInfo *> *reqs = notification.object;
    NSMutableString *msg = [NSMutableString new];
    [msg appendString:@"好友请求: "];
    for (TIMFriendPendencyInfo *req in reqs) {
        [msg appendFormat:@"[%@: %@]", req.identifier, req.addWording];
    }
    self.msgLabel.text = msg;
}

- (void)onDelFriends:(NSNotification *)notification
{
    NSArray *identifiers = notification.object;
    self.msgLabel.text = [NSString stringWithFormat:@"已删除好友:%@",identifiers];
}

- (void)onAddFriends:(NSNotification *)notification
{
    NSArray *identifiers = notification.object;
    self.msgLabel.text = [NSString stringWithFormat:@"已添加好友:%@",identifiers];
}

- (void)onFriendProfileUpdate:(NSNotification *)notification
{
    NSArray<TIMSNSChangeInfo *> *profiles = notification.object;
    NSMutableString *msg = [NSMutableString new];
    [msg appendString:@"好友数据更新: "];
    for (TIMSNSChangeInfo *profile in profiles) {
        [msg appendFormat:@"[%@: %@]", profile.identifier, profile.remark];
    }
    self.msgLabel.text = msg;
}

- (void)addBlackList:(id)sender
{
    [[TIMFriendshipManager sharedInstance] addBlackList:[self getIds] succ:^(NSArray<TIMFriendResult *> *results) {
        NSMutableString *msg = [NSMutableString new];
        for (TIMFriendResult *result in results) {
            if (result.result_code == 0)
                [msg appendFormat:@"成功：%@", result.identifier];
            else
                [msg appendFormat:@"异常：%@, %ld, %@", result.identifier, (long)result.result_code, result.result_info];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)getBlackList:(id)sender
{
    [[TIMFriendshipManager sharedInstance] getBlackList:^(NSArray<TIMFriend *> *friends) {
        NSMutableString *msg = [NSMutableString new];
        [msg appendString:@"黑名单: "];
        for (TIMFriend *friend in friends) {
            [msg appendFormat:@"[%@,%@]", friend.identifier, friend.profile.nickname];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = msg;
    }];
}

- (void)delBlackList:(id)sender
{
    [[TIMFriendshipManager sharedInstance] deleteBlackList:[self getIds] succ:^(NSArray<TIMFriendResult *> *results) {
        NSMutableString *msg = [NSMutableString new];
        for (TIMFriendResult *result in results) {
            if (result.result_code == 0)
                [msg appendFormat:@"成功：%@", result.identifier];
            else
                [msg appendFormat:@"异常：%@, %ld, %@", result.identifier, (long)result.result_code, result.result_info];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)getPendencyList:(id)sender
{
    TIMFriendPendencyRequest *req = [TIMFriendPendencyRequest new];
    req.numPerPage = 100;
    req.type = TIM_PENDENCY_COME_IN;
    
    [[TIMFriendshipManager sharedInstance] getPendencyList:req succ:^(TIMFriendPendencyResponse *pendencyResponse) {
        NSMutableString *msg = [NSMutableString new];
        [msg appendString:@"未决消息: "];
        [msg appendFormat:@"未读数量 %llu ", pendencyResponse.unreadCnt];
        for (TIMFriendPendencyItem *pd in pendencyResponse.pendencies) {
            [msg appendFormat:@"[%@,%llu,%@,%@,%@]", pd.identifier, pd.addTime, pd.addWording, pd.addSource, pd.nickname];
        }
        self.msgLabel.text = msg;
        
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)pendencyReport:(id)sender
{
    [[TIMFriendshipManager sharedInstance] pendencyReport:[self getPropInt] succ:^{
        self.msgLabel.text = @"OK";
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)deletePendency:(id)sender
{
    [[TIMFriendshipManager sharedInstance] deletePendency:TIM_PENDENCY_COME_IN users:[self getIds] succ:^{
        self.msgLabel.text = @"OK";
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)agreeFriend:(UIButton *)sender
{
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:picker];
    picker.mm_top(sender.mm_maxY).mm_width(self.view.mm_w).mm_height(200);
    picker.delegate = self;
    picker.dataSource = self;
    self.agreeFriendPicker = picker;
}

- (void)changeFriend:(UIButton *)sender
{
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:picker];
    picker.mm_top(sender.mm_maxY).mm_width(self.view.mm_w).mm_height(200);
    picker.delegate = self;
    picker.dataSource = self;
    self.changeFriendPicker = picker;
}

- (void)deleteFriend:(id)sender
{
    [[TIMFriendshipManager sharedInstance] deleteFriends:[self getIds] delType:TIM_FRIEND_DEL_BOTH succ:^(NSArray<TIMFriendResult *> *results) {
        
        NSMutableString *msg = [NSMutableString new];
        for (TIMFriendResult *result in results) {
            if (result.result_code == 0)
                [msg appendFormat:@"成功：%@", result.identifier];
            else
                [msg appendFormat:@"异常：%@, %ld, %@", result.identifier, (long)result.result_code, result.result_info];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)createGroup:(id)sender
{
    [[TIMFriendshipManager sharedInstance] createFriendGroup:[self getProps] users:[self getIds] succ:^(NSArray<TIMFriendResult *> *results) {
        NSMutableString *msg = [NSMutableString new];
        for (TIMFriendResult *result in results) {
            if (result.result_code == 0)
                [msg appendFormat:@"成功：%@", result.identifier];
            else
                [msg appendFormat:@"异常：%@, %ld, %@", result.identifier, (long)result.result_code, result.result_info];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)getGroup:(id)sender
{
    [[TIMFriendshipManager sharedInstance] getFriendGroups:[self getProps] succ:^(NSArray<TIMFriendGroup *> *arr) {
        NSMutableString *msg = [NSMutableString new];
        [msg appendString:@"分组列表: "];
        for (TIMFriendGroup *group in arr) {
            [msg appendFormat:@"[%@,%lld,%@],", group.name, group.userCnt, group.friends];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)deleteGroup:(id)sender
{
    [[TIMFriendshipManager sharedInstance] deleteFriendGroup:[self getProps] succ:^() {
        self.msgLabel.text = @"OK";
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)renameGroup:(id)sender
{
    [[TIMFriendshipManager sharedInstance] renameFriendGroup:[self getProp] newName:[self getValue] succ:^() {
        self.msgLabel.text = @"OK";
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)addFriendsToFriendGroup:(id)sender
{
    [[TIMFriendshipManager sharedInstance] addFriendsToFriendGroup:[self getProp] users:[self getIds] succ:^(NSArray<TIMFriendResult *> *results) {
        NSMutableString *msg = [NSMutableString new];
        for (TIMFriendResult *result in results) {
            if (result.result_code == 0)
                [msg appendFormat:@"成功：%@", result.identifier];
            else
                [msg appendFormat:@"异常：%@, %ld, %@", result.identifier, (long)result.result_code, result.result_info];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

- (void)delFriendsFromFriendGroup:(id)sender
{
    [[TIMFriendshipManager sharedInstance] deleteFriendsFromFriendGroup:[self getProp] users:[self getIds] succ:^(NSArray<TIMFriendResult *> *results) {
        NSMutableString *msg = [NSMutableString new];
        for (TIMFriendResult *result in results) {
            if (result.result_code == 0)
                [msg appendFormat:@"成功：%@", result.identifier];
            else
                [msg appendFormat:@"异常：%@, %ld, %@", result.identifier, (long)result.result_code, result.result_info];
        }
        self.msgLabel.text = msg;
    } fail:^(int code, NSString *msg) {
        self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
    }];
}

//设置列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//设置每列行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView == self.agreeFriendPicker){
        return 3;
    }
    
    if(pickerView == self.changeFriendPicker){
        return 2;
    }
    return 1;
}

#pragma mark - 代理
// 返回第component列第row行的内容（标题）
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.agreeFriendPicker) {
        return @[@"TIM_FRIEND_RESPONSE_AGREE",@"TIM_FRIEND_RESPONSE_AGREE_AND_ADD",@"TIM_FRIEND_RESPONSE_REJECT"][row];
    }
    if (pickerView == self.changeFriendPicker) {
        return @[TIMFriendTypeKey_Remark, TIMFriendTypeKey_Group][row];
    }
    return @"";
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *str = [self pickerView:pickerView titleForRow:row forComponent:component];
    if (pickerView == self.agreeFriendPicker) {
        TIMFriendResponse *rsp = [TIMFriendResponse new];
        rsp.identifier = [self getIds][0];
        rsp.remark = self.propField.text;
        
        if ([str isEqualToString:@"TIM_FRIEND_RESPONSE_AGREE"])
        {
            rsp.responseType = TIM_FRIEND_RESPONSE_AGREE;
        }
        if ([str isEqualToString:@"TIM_FRIEND_RESPONSE_AGREE_AND_ADD"])
        {
            rsp.responseType = TIM_FRIEND_RESPONSE_AGREE_AND_ADD;
        }
        if ([str isEqualToString:@"TIM_FRIEND_RESPONSE_REJECT"])
        {
            rsp.responseType = TIM_FRIEND_RESPONSE_REJECT;
        }
        [[TIMFriendshipManager sharedInstance] doResponse:rsp succ:^(TIMFriendResult *result){
            if (result.result_code == 0)
                self.msgLabel.text = @"OK";
            else
                self.msgLabel.text = [NSString stringWithFormat:@"异常：%@, %ld, %@", result.identifier, (long)result.result_code, result.result_info];
        } fail:^(int code, NSString *msg) {
            self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
        }];
    }
    if (pickerView == self.changeFriendPicker) {
        [[TIMFriendshipManager sharedInstance] modifyFriend:[self getIds][0] values:@{str: [self getProp]} succ:^{
            self.msgLabel.text = @"OK";
        } fail:^(int code, NSString *msg) {
            self.msgLabel.text = [NSString stringWithFormat:@"失败：%d, %@", code, msg];
        }];
    }
    [pickerView removeFromSuperview];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.changeFriendPicker removeFromSuperview];
    [self.agreeFriendPicker removeFromSuperview];
}

@end
