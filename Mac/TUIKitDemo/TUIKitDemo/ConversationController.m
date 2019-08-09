//
//  ConversationController.m
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/23.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import "ConversationController.h"
#import "LoginViewController.h"
#import "ChatViewController.h"
#import "AddChatViewController.h"
#import "MsgTableCellView.h"
#import "ImSDK.h"
#import "TIMManager+MsgExt.h"
#import "TIMConversation+MsgExt.h"

@implementation TConversationCellData

@end


@interface ConversationController ()<TIMRefreshListener,NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation ConversationController
{
    NSMutableArray *_datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _msgTableView.delegate = self;
    _msgTableView.dataSource = self;
    
    TIMUserConfig *userConfig = [[TIMUserConfig alloc] init];
    userConfig.refreshListener = self;
    [[TIMManager sharedInstance] setUserConfig:userConfig];
    
    [self updateConversations];
    // Do view setup here.
}

- (IBAction)addChat:(id)sender {
    AddChatViewController *vc = [[AddChatViewController alloc] initWithNibName:@"AddChatViewController" bundle:nil];
    [self presentViewControllerAsSheet:vc];
}

- (void)updateConversations
{
    _datas = [NSMutableArray array];
    TIMManager *manager = [TIMManager sharedInstance];
    NSArray *convs = [manager getConversationList];
    for (TIMConversation *conv in convs) {
        if([conv getType] == TIM_SYSTEM){
            continue;
        }

        TIMMessage *msg = [conv getLastMsg];
        TConversationCellData *data = [[TConversationCellData alloc] init];
        data.unRead = [conv getUnReadMessageNum];
        data.convId = [conv getReceiver];
        data.convType = (TConvType)[conv getType];
        data.subTitle = [self getLastDisplayString:conv];
        data.time = [self getDateDisplayString:msg.timestamp];
        if(data.convType == TConv_Type_C2C){
            data.title = data.convId;
        }
        else if(data.convType == TConv_Type_Group){
            data.title = [conv getGroupName];
        }
        [_datas addObject:data];
    }
    [_msgTableView reloadData];
}

- (void)onRefreshConversations:(NSArray*)conversations
{
    [self updateConversations];
}

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
    if (date == nil) {
        return @"";
    }
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

#pragma mark - table view delegate
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _datas.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 50;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    MsgTableCellView * cellView = (MsgTableCellView *)[tableView makeViewWithIdentifier:@"MsgTableCellViewId" owner:self];
    if (cellView==nil) {
        cellView = [[MsgTableCellView alloc]initWithFrame:CGRectMake(0, 0, _msgTableView.bounds.size.width, 50)];
        cellView.identifier = @"MsgTableCellViewId";
    }
    TConversationCellData *data = _datas[row];
    NSImage *headImage = nil;
    if(data.convType == TIM_C2C){
        headImage = [NSImage imageNamed:@"default_head"];
    }
    else if(data.convType == TIM_GROUP){
         headImage = [NSImage imageNamed:@"default_group"];
    }
    [cellView setHeader:headImage msg:data.title subMsg:data.subTitle time:data.time];
    return cellView;
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return nil;
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    return YES;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    ChatViewController *vc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    vc.conversation = (TConversationCellData *)_datas[row];
    [self presentViewControllerAsModalWindow:vc];
    return YES;
}
@end
