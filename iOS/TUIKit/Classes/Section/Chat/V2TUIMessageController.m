//
//  V2TUIMessageController.m
//  Pods
//
//  Created by harvy on 2020/12/30.
//

#import "ReactiveObjC.h"
#import <MMLayout/UIView+MMLayout.h>
#import "V2TUIMessageController.h"
#import "THeader.h"
#import "TUIConversationCellData.h"
#import "TUITextMessageCell.h"

#define MSG_GET_COUNT 20

@interface V2TUIMessageController ()

@property (nonatomic, strong) V2TIMMessage *msgForOlderGet;
@property (nonatomic, strong) V2TIMMessage *msgForNewerGet;

@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL olderNoMoreMsg;
@property (nonatomic, assign) BOOL newerNoMoreMsg;

@property (nonatomic, assign) BOOL currentDataIsFromLocateMsg;

@end

@implementation V2TUIMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

// 加载定位消息
- (void)loadLocateMessages
{
    self.indicatorView.mm_h = 0;
    self.currentDataIsFromLocateMsg = YES;
    dispatch_group_t group = dispatch_group_create();
    __block NSArray *olders = @[];
    __block NSArray *newers = @[];
    
    // 以定位消息为起点，加载最旧的10条消息
    {
        dispatch_group_enter(group);
        V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
        option.getType = V2TIM_GET_LOCAL_OLDER_MSG;
        option.count = MSG_GET_COUNT / 2;
        option.groupID = self.conversationData.groupID;
        option.userID = self.conversationData.userID;
        option.lastMsg = self.locateMessage;
        [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
            msgs = msgs.reverseObjectEnumerator.allObjects;
            olders = msgs?:@[];
            dispatch_group_leave(group);
        } fail:^(int code, NSString *desc) {
            dispatch_group_leave(group);
        }];
    }
    // 以定位消息为起点，加载最新的10条消息
    {
        dispatch_group_enter(group);
        V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
        option.getType = V2TIM_GET_LOCAL_NEWER_MSG;
        option.count = MSG_GET_COUNT / 2;
        option.groupID = self.conversationData.groupID;
        option.userID = self.conversationData.userID;
        option.lastMsg = self.locateMessage;
        [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
            newers = msgs?:@[];
            dispatch_group_leave(group);
        } fail:^(int code, NSString *desc) {
            dispatch_group_leave(group);
        }];
    }
    @weakify(self)
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        @strongify(self)
        self.firstLoad = NO;
        [self.indicatorView stopAnimating];
        NSMutableArray *results = [NSMutableArray array];
        [results addObjectsFromArray:olders];
        [results addObject:self.locateMessage];
        [results addObjectsFromArray:newers];
        self.msgForOlderGet = results.firstObject;
        self.msgForNewerGet = results.lastObject;
        
        [self.uiMsgs removeAllObjects];
        NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:results.reverseObjectEnumerator.allObjects];
        self.uiMsgs = [NSMutableArray arrayWithArray:uiMsgs];
        [self.heightCache removeAllObjects];
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            // 滚动到指定位置
            [self scrollLocateMessage];
            // 关键字高亮
            [self highlightKeyword];
        });
    });
}

- (void)scrollLocateMessage
{
    // 先找到 locateMsg 的坐标偏移
    CGFloat offsetY = 0;
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.innerMessage.msgID isEqualToString:self.locateMessage.msgID]) {
            break;
        }
        offsetY += [uiMsg heightOfWidth:Screen_Width];
    }
    
    // 再偏移半个 tableview 的高度
    offsetY -= self.tableView.frame.size.height / 2.0;
    if (offsetY <= TMessageController_Header_Height) {
        offsetY = TMessageController_Header_Height + 0.1;
    }

    if (offsetY > TMessageController_Header_Height + 0.1) {
        [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y + offsetY, Screen_Width, self.tableView.bounds.size.height) animated:NO];
    }
}

- (void)highlightKeyword
{
    TUIMessageCellData *cellData = nil;
    for (TUIMessageCellData *tmp in self.uiMsgs) {
        if ([tmp.msgID isEqualToString:self.locateMessage.msgID]) {
            cellData = tmp;
            break;
        }
    }
    if (cellData == nil) {
        return;
    }
    
    CGFloat time = 0.5;
    UITableViewRowAnimation animation = UITableViewRowAnimationFade;
    if ([cellData isKindOfClass:TUITextMessageCellData.class]) {
        time = 2;
        animation = UITableViewRowAnimationNone;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        cellData.highlightKeyword = weakSelf.hightlightKeyword;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.uiMsgs indexOfObject:cellData] inSection:0]] withRowAnimation:animation];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellData.highlightKeyword = nil;
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.uiMsgs indexOfObject:cellData] inSection:0]] withRowAnimation:animation];
    });
}

- (void)loadMessages:(BOOL)order
{
    self.currentDataIsFromLocateMsg = NO;
    if(_isLoadingMsg){
        return;
    }
    if (order && self.olderNoMoreMsg) {
        [self.indicatorView stopAnimating];
        return;
    }
    if (!order && self.newerNoMoreMsg) {
        return;
    }
    
    _isLoadingMsg = YES;
    
    V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
    option.userID = self.conversationData.userID;
    option.groupID = self.conversationData.groupID;
    option.getType = order ? V2TIM_GET_LOCAL_OLDER_MSG : V2TIM_GET_LOCAL_NEWER_MSG;
    option.count = MSG_GET_COUNT;
    option.lastMsg = order ? self.msgForOlderGet : self.msgForNewerGet;
    @weakify(self)
    [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
        @strongify(self)
        if (!order) {
            // 逆序
            msgs = msgs.reverseObjectEnumerator.allObjects;
        }
        [self getMessages:msgs msgCount:option.count older:order];
    } fail:^(int code, NSString *desc) {
        
    }];
}

- (void)getMessages:(NSArray *)msgs msgCount:(int)msgCount older:(BOOL)older
{
    if(msgs.count != 0){
        if (older) {
            self.msgForOlderGet = msgs.lastObject;
            if (self.msgForNewerGet == nil) {
                self.msgForNewerGet = msgs.firstObject;
            }
        }else {
            if (self.msgForOlderGet == nil) {
                self.msgForOlderGet = msgs.lastObject;
            }
            self.msgForNewerGet = msgs.firstObject;
        }
    }
    @weakify(self)
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        if(msgs.count < msgCount){
            if (older) {
                self.olderNoMoreMsg = YES;
                self.noMoreMsg = YES; // 将父类的标志位置为YES, 父类不在加载
                self.indicatorView.mm_h = 0;
            } else {
                self.newerNoMoreMsg = YES;
            }
        }
        if(uiMsgs.count != 0){
            if (older) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                [self.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
            }else {
                [self.uiMsgs addObjectsFromArray:uiMsgs];
            }
            [self.heightCache removeAllObjects];
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            if(!self.firstLoad){
                if (older) {
                    CGFloat visibleHeight = 0;
                    for (NSInteger i = 0; i < uiMsgs.count; ++i) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        visibleHeight += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                    }
                    if(self.olderNoMoreMsg){
                        visibleHeight -= TMessageController_Header_Height;
                    }
                    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y + visibleHeight, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];
                } else {
                    if (uiMsgs.firstObject) {
                        NSInteger index = [self.uiMsgs indexOfObject:uiMsgs.firstObject];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        CGFloat newOneHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                        if (self.newerNoMoreMsg) {
                            newOneHeight -= TMessageController_Header_Height;
                        }
                        [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y + newOneHeight, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];
                    }
                }
            }
        }
        self.isLoadingMsg = NO;
        [self.indicatorView stopAnimating];
        self.firstLoad = NO;
    });
}

- (void)keyboardWillShow
{
    if (!self.currentDataIsFromLocateMsg) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.msgForNewerGet = nil;
        self.msgForOlderGet = nil;
        self.msgForDate = nil;
        [self.uiMsgs removeAllObjects];
        [self.tableView reloadData];
        [self loadMessages:YES];
    });
}

- (void)setConversation:(TUIConversationCellData *)conversationData
{
    self.conversationData = conversationData;
    if (self.locateMessage) {
        [self loadLocateMessages];
    }else{
        self.msgForOlderGet = nil;
        [self loadMessages:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.currentDataIsFromLocateMsg) {
        return;
    }
    [super scrollViewDidScroll:scrollView];
}

- (void)scrollToBottom:(BOOL)animate
{
    if (self.currentDataIsFromLocateMsg) {
        return;
    }
    [super scrollToBottom:animate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y <= TMessageController_Header_Height){
        // 拉取旧消息
        [self loadMessages:YES];
    }else {
        // 拉取新消息
        [self loadMessages:NO];
    }
}

@end
