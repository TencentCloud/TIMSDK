//
//  ConversationController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/14.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TConversationController.h"
#import "TConversationCell.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "IMMessageExt.h"
#import "TUIKit.h"
#import "TNaviBarIndicatorView.h"


@interface TConversationController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) TNaviBarIndicatorView *titleView;
@end

@implementation TConversationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];
    [self setupViews];
}

- (void)setupNavigation
{
    _titleView = [[TNaviBarIndicatorView alloc] init];
    [_titleView setTitle:@"消息"];
    self.navigationItem.titleView = _titleView;
    self.parentViewController.navigationItem.titleView = _titleView;
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:[UIImage imageNamed:TUIKitResource(@"more")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
    self.parentViewController.navigationItem.rightBarButtonItem = moreItem;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}


- (void)setupViews
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = TConversationController_Background_Color;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshConversations:) name:TUIKitNotification_TIMRefreshListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChanged:) name:TUIKitNotification_TIMConnListener object:nil];
    [self updateConversations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateConversations
{
    _data = [NSMutableArray array];
    TIMManager *manager = [TIMManager sharedInstance];
    NSArray *convs = [manager getConversationList];
    for (TIMConversation *conv in convs) {
        if([conv getType] == TIM_SYSTEM){
            continue;
        }
        //[conv getMessage:[[TUIKit sharedInstance] getConfig].msgCountPerRequest last:nil succ:nil fail:nil];
        TIMMessage *msg = [conv getLastMsg];
        TConversationCellData *data = [[TConversationCellData alloc] init];
        data.unRead = [conv getUnReadMessageNum];
        data.time = [self getDateDisplayString:msg.timestamp];
        data.subTitle = [self getLastDisplayString:conv];
        if([conv getType] == TIM_C2C){
            data.head = TUIKitResource(@"default_head");
        }
        else if([conv getType] == TIM_GROUP){
            data.head = TUIKitResource(@"default_group");
        }
        data.convId = [conv getReceiver];
        data.convType = (TConvType)[conv getType];
        
        if(data.convType == TConv_Type_C2C){
            data.title = data.convId;
        }
        else if(data.convType == TConv_Type_Group){
            data.title = [conv getGroupName];
        }
        [_data addObject:data];
    }
    [_tableView reloadData];
}

- (void)onRefreshConversations:(NSNotification *)notification
{
    [self updateConversations];
}

- (void)onNetworkChanged:(NSNotification *)notification
{
    TNetStatus status = (TNetStatus)[notification.object intValue];
    switch (status) {
        case TNet_Status_Succ:
            [_titleView setTitle:@"消息"];
            [_titleView stopAnimating];
            break;
        case TNet_Status_Connecting:
            [_titleView setTitle:@"连接中..."];
            [_titleView startAnimating];
            break;
        case TNet_Status_Disconnect:
            [_titleView setTitle:@"消息(未连接)"];
            [_titleView stopAnimating];
            break;
        case TNet_Status_ConnFailed:
            [_titleView setTitle:@"消息(未连接)"];
            [_titleView stopAnimating];
            break;
            
        default:
            break;
    }
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TConversationCell getSize].height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TConversationCellData *conv = _data[indexPath.row];
    [_data removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    TIMConversationType type = TIM_C2C;
    if(conv.convType == TConv_Type_Group){
        type = TIM_GROUP;
    }
    else if(conv.convType == TConv_Type_C2C){
        type = TIM_C2C;
    }
    [[TIMManager sharedInstance] deleteConversation:type receiver:conv.convId];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(_delegate && [_delegate respondsToSelector:@selector(conversationController:didSelectConversation:)]){
        [_delegate conversationController:self didSelectConversation:_data[indexPath.row]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TConversationCell *cell  = [tableView dequeueReusableCellWithIdentifier:TConversationCell_ReuseId];
    if(!cell){
        cell = [[TConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TConversationCell_ReuseId];
    }
    [cell setData:[_data objectAtIndex:indexPath.row]];
    return cell;
}

- (void)setData:(NSMutableArray *)data
{
    _data = data;
    [_tableView reloadData];
}

- (void)rightBarButtonClick:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(conversationController:DidClickRightBarButton:)]){
        [_delegate conversationController:self DidClickRightBarButton:sender];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

//- (UIModalPresentationStyle)

- (NSString *)getLastDisplayString:(TIMConversation *)conv
{
    NSString *str = @"";
    TIMMessageDraft *draft = [conv getDraft];
    if(draft){
        for (int i = 0; i < draft.elemCount; ++i) {
            TIMElem *elem = [draft getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                str = [NSString stringWithFormat:@"[草稿]%@", text.text];
                break;
            }
            else{
                continue;
            }
        }
        return str;
    }
    
    TIMMessage *msg = [conv getLastMsg];
    if(msg.status == TIM_MSG_STATUS_LOCAL_REVOKED){
        if(msg.isSelf){
            return @"你撤回了一条消息";
        }
        else{
            return [NSString stringWithFormat:@"\"%@\"撤回了一条消息", msg.sender];
        }
    }
    for (int i = 0; i < msg.elemCount; ++i) {
        TIMElem *elem = [msg getElem:i];
        if([elem isKindOfClass:[TIMTextElem class]]){
            TIMTextElem *text = (TIMTextElem *)elem;
            str = text.text;
            break;
        }
        else if([elem isKindOfClass:[TIMCustomElem class]]){
            TIMCustomElem *custom = (TIMCustomElem *)elem;
            str = custom.ext;
            break;
        }
        else if([elem isKindOfClass:[TIMImageElem class]]){
            str = @"[图片]";
            break;
        }
        else if([elem isKindOfClass:[TIMSoundElem class]]){
            str = @"[语音]";
            break;
        }
        else if([elem isKindOfClass:[TIMVideoElem class]]){
            str = @"[视频]";
            break;
        }
        else if([elem isKindOfClass:[TIMFaceElem class]]){
            str = @"[动画表情]";
            break;
        }
        else if([elem isKindOfClass:[TIMFileElem class]]){
            str = @"[文件]";
            break;
        }
        else if([elem isKindOfClass:[TIMGroupTipsElem class]]){
            TIMGroupTipsElem *tips = (TIMGroupTipsElem *)elem;
            switch (tips.type) {
                case TIM_GROUP_TIPS_TYPE_INFO_CHANGE:
                {
                    for (TIMGroupTipsElemGroupInfo *info in tips.groupChangeList) {
                        switch (info.type) {
                            case TIM_GROUP_INFO_CHANGE_GROUP_NAME:
                            {
                                str = [NSString stringWithFormat:@"\"%@\"修改群名为\"%@\"", tips.opUser, info.value];
                            }
                                break;
                            case TIM_GROUP_INFO_CHANGE_GROUP_INTRODUCTION:
                            {
                                str = [NSString stringWithFormat:@"\"%@\"修改群简介为\"%@\"", tips.opUser, info.value];
                            }
                                break;
                            case TIM_GROUP_INFO_CHANGE_GROUP_NOTIFICATION:
                            {
                                str = [NSString stringWithFormat:@"\"%@\"修改群公告为\"%@\"", tips.opUser, info.value];
                            }
                                break;
                            case TIM_GROUP_INFO_CHANGE_GROUP_OWNER:
                            {
                                str = [NSString stringWithFormat:@"\"%@\"修改群主为\"%@\"", tips.opUser, info.value];
                            }
                                break;
                            default:
                                break;
                        }
                    }
                }
                    break;
                case TIM_GROUP_TIPS_TYPE_KICKED:
                {
                    NSString *users = [tips.userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:@"\"%@\"将\"%@\"剔出群组", tips.opUser, users];
                }
                    break;
                case TIM_GROUP_TIPS_TYPE_INVITE:
                {
                    NSString *users = [tips.userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入群组", tips.opUser, users];
                }
                    break;
                default:
                    break;
            }
        }
        else{
            continue;
        }
    }
    return str;
}

- (NSString *)getDateDisplayString:(NSDate *)date
{
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:date];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    
    NSDateComponents *comp =  [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy/MM/dd";
    }
    else{
        if (nowCmps.day==myCmps.day) {
            dateFmt.AMSymbol = @"上午";
            dateFmt.PMSymbol = @"下午";
            dateFmt.dateFormat = @"aaa hh:mm";
        } else if((nowCmps.day-myCmps.day)==1) {
            dateFmt.AMSymbol = @"上午";
            dateFmt.PMSymbol = @"下午";
            dateFmt.dateFormat = @"昨天";
        } else {
            if ((nowCmps.day-myCmps.day) <=7) {
                switch (comp.weekday) {
                    case 1:
                        dateFmt.dateFormat = @"星期日";
                        break;
                    case 2:
                        dateFmt.dateFormat = @"星期一";
                        break;
                    case 3:
                        dateFmt.dateFormat = @"星期二";
                        break;
                    case 4:
                        dateFmt.dateFormat = @"星期三";
                        break;
                    case 5:
                        dateFmt.dateFormat = @"星期四";
                        break;
                    case 6:
                        dateFmt.dateFormat = @"星期五";
                        break;
                    case 7:
                        dateFmt.dateFormat = @"星期六";
                        break;
                    default:
                        break;
                }
            }else {
                dateFmt.dateFormat = @"yyyy/MM/dd";
            }
        }
    }
    return [dateFmt stringFromDate:date];
}

@end

