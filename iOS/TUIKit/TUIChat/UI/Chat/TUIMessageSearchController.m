
#import "TUIMessageSearchController.h"
#import "TUIMessageController+ProtectedAPI.h"
#import "ReactiveObjC.h"
#import "UIView+TUILayout.h"
#import "TUIDefine.h"
#import "TUITextMessageCell.h"
#import "TUIMessageSearchDataProvider.h"
#import "TUIReplyMessageCellData.h"
#import "TUIReplyMessageCell.h"
#import "TUIGlobalization.h"

#define MSG_GET_COUNT 20

@interface  TUIMessageSearchController()

@property (nonatomic) UIActivityIndicatorView *bottomIndicatorView;

@end

@implementation TUIMessageSearchController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bottomIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    self.bottomIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableFooterView = self.bottomIndicatorView;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Notification

- (void)keyboardWillShow
{
    if (![self messageSearchDataProvider].isNewerNoMoreMsg) {
        [[self messageSearchDataProvider] removeAllSearchData];
        [self.tableView reloadData];
        [self loadMessages:YES];
    }
}

#pragma mark - Overrider

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= TMessageController_Header_Height
       && ![self messageSearchDataProvider].isOlderNoMoreMsg) {
        // 显示下拉刷新
        if (!self.indicatorView.isAnimating) {
            [self.indicatorView startAnimating];
        }
    }
    else if ([self isScrollToBottomIndicatorViewY:scrollView]
             && ![self messageSearchDataProvider].isNewerNoMoreMsg
             ) {
        // 显示上拉加载
        if (!self.bottomIndicatorView.isAnimating) {
            [self.bottomIndicatorView startAnimating];
        }
    }
    else {
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
        if (self.bottomIndicatorView.isAnimating) {
            [self.bottomIndicatorView stopAnimating];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= TMessageController_Header_Height
       && ![self messageSearchDataProvider].isOlderNoMoreMsg) {
        // 拉取旧消息
        [self loadMessages:YES];
    }
    else if ([self isScrollToBottomIndicatorViewY:scrollView]
             && ![self messageSearchDataProvider].isNewerNoMoreMsg
             ) {
        // 加载新的消息
        [self loadMessages:NO];
    }
}

- (BOOL)isScrollToBottomIndicatorViewY:(UIScrollView *)scrollView {
    return (scrollView.contentOffset.y + self.tableView.mm_h + 2) > (scrollView.contentSize.height - self.indicatorView.mm_h);
    // 滚到临界点,再+2像素
}

#pragma mark - Getters & Setters
- (void)setConversation:(TUIChatConversationModel *)conversationData
{
    self.conversationData = conversationData;
    self.messageDataProvider = [[TUIMessageSearchDataProvider alloc] initWithConversationModel:self.conversationData];
    self.messageDataProvider.dataSource = self;
    if (self.locateMessage) {
        [self loadLocateMessages:YES];
    } else {
        [[self messageSearchDataProvider] removeAllSearchData];
        [self loadMessages:YES];
    }
}

#pragma mark - Private Methods
- (TUIMessageSearchDataProvider *)messageSearchDataProvider {
    return (TUIMessageSearchDataProvider *)self.messageDataProvider;
}

// 加载定位消息
- (void)loadLocateMessages:(BOOL)firstLoad
{
    @weakify(self);
    [[self messageSearchDataProvider] loadMessageWithSearchMsg:self.locateMessage
                                              ConversationInfo:self.conversationData
                                                  SucceedBlock:^(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, NSArray<TUIMessageCellData *> * _Nonnull newMsgs) {
        [self.indicatorView stopAnimating];
        self.indicatorView.mm_h = 0;
        self.bottomIndicatorView.mm_h = 0;
        [self.tableView reloadData];
        if (!firstLoad) {
            // 在消息回复等跳转场景中，先将 tableview 滚动到最底部，再结合 scrollLocateMessage 来实现滚动定位效果
            NSInteger index = self.messageDataProvider.uiMsgs.count > 0 ? self.messageDataProvider.uiMsgs.count - 1 : 0;
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:NO];
        }
        [self.tableView layoutIfNeeded];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            // 滚动到指定位置
            [self scrollLocateMessage:firstLoad];
            // 关键字高亮
            [self highlightKeyword];
        });
        
    } FailBlock:^(int code, NSString *desc) {
    }];
}

- (void)scrollLocateMessage:(BOOL)firstLoad
{
    // 先找到 locateMsg 的坐标偏移
    CGFloat offsetY = 0;
    NSInteger index = 0;
    for (TUIMessageCellData *uiMsg in [self messageSearchDataProvider].uiMsgs) {
        if ([uiMsg.innerMessage.msgID isEqualToString:self.locateMessage.msgID]) {
            break;
        }
        offsetY += [uiMsg heightOfWidth:Screen_Width];
        index++;
    }
    
    // 再偏移半个 tableview 的高度
    offsetY -= self.tableView.frame.size.height / 2.0;
    if (offsetY <= TMessageController_Header_Height) {
        offsetY = TMessageController_Header_Height + 0.1;
    }

    if (offsetY > TMessageController_Header_Height) {
        if (firstLoad) {
            [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y + offsetY, Screen_Width, self.tableView.bounds.size.height) animated:NO];
        } else {
            if (self.tableView.contentOffset.y > offsetY) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
    }
}

- (void)highlightKeyword
{
    TUIMessageCellData *cellData = nil;
    for (TUIMessageCellData *tmp in [self messageSearchDataProvider].uiMsgs) {
        if ([tmp.msgID isEqualToString:self.locateMessage.msgID]) {
            cellData = tmp;
            break;
        }
    }
    if (cellData == nil) {
        return;
    }
    
    
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self messageDataProvider].uiMsgs indexOfObject:cellData] inSection:0];
        cellData.highlightKeyword = self.hightlightKeyword.length?self.hightlightKeyword:@"hightlight";
        TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell fillWithData:cellData];
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self messageDataProvider].uiMsgs indexOfObject:cellData] inSection:0];
            cellData.highlightKeyword = nil;
            TUIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell fillWithData:cellData];
        });
    });
}


/// @param order order=YES, 代表获取旧消息; order=NO, 代表获取新消息
- (void)loadMessages:(BOOL)order
{
    // 加载中case
    if ([self messageSearchDataProvider].isLoadingData) {
        return;
    }
    
    // 无数据case
    if (order && [self messageSearchDataProvider].isOlderNoMoreMsg) {
        [self.indicatorView stopAnimating];
        return;
    }
    if (!order && [self messageSearchDataProvider].isNewerNoMoreMsg) {
        [self.bottomIndicatorView stopAnimating];
        return;
    }
    
    @weakify(self);
    [[self messageSearchDataProvider] loadMessageWithIsRequestOlderMsg:order
                                                      ConversationInfo:self.conversationData
                                                          SucceedBlock:^(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, BOOL isFirstLoad, NSArray<TUIMessageCellData *> * _Nonnull newUIMsgs) {
        @strongify(self);
        
        [self.indicatorView stopAnimating];
        [self.bottomIndicatorView stopAnimating];
        if (isOlderNoMoreMsg) {
            self.indicatorView.mm_h = 0;
        } else {
            self.indicatorView.mm_h = TMessageController_Header_Height;
        }
        if (isNewerNoMoreMsg) {
            self.bottomIndicatorView.mm_h = 0;
        } else {
            self.bottomIndicatorView.mm_h = TMessageController_Header_Height;
        }
                
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        
        if (isFirstLoad) {
            [self scrollToBottom:NO];
        } else {
            if (order) {
                CGFloat visibleHeight = 0;
                for (NSInteger i = 0; i < newUIMsgs.count; ++i) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    visibleHeight += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                }
                if (isOlderNoMoreMsg) {
                    visibleHeight -= TMessageController_Header_Height;
                }
                [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + visibleHeight)
                                        animated:NO];
            }
        }
        
    } FailBlock:^(int code, NSString *desc) {
        
    }];
}

- (void)showReplyMessage:(TUIReplyMessageCell *)cell
{
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    TUIReplyMessageCellData *cellData = cell.replyData;
    // 查询原始消息 - 在数据源里头调用
    [(TUIMessageSearchDataProvider *)self.messageDataProvider findMessages:@[cellData.originMsgID?:@""] callback:^(BOOL success, NSString * _Nonnull desc, NSArray<V2TIMMessage *> * _Nonnull msgs) {
        if (!success) {
            [TUITool makeToast:TUIKitLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
            return;
        }
        V2TIMMessage *message = msgs.firstObject;
        if (message == nil) {
            [TUITool makeToast:TUIKitLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
            return;
        }
        
        // 判断消息是否被删除或者撤回
        if (message.status == V2TIM_MSG_STATUS_HAS_DELETED || message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
            [TUITool makeToast:TUIKitLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
            return;
        }
        [self locateAssignMessage:message matchKeyWord:cellData.msgAbstract];
    }];
}


- (void)locateAssignMessage:(V2TIMMessage *)message matchKeyWord:(NSString *)keyword
{
    if (message == nil) {
        return;
    }
    self.locateMessage = message;
    self.hightlightKeyword = keyword;
    
    // 当前消息已经处于加载状态
    BOOL memoryExist = NO;
    for (TUIMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
        if ([cellData.innerMessage.msgID isEqual:message.msgID]) {
            memoryExist = YES;
            break;
        }
    }
    if (memoryExist) {
        // 直接滚动
        [self scrollLocateMessage:NO];
        // 高亮
        [self highlightKeyword];
        return;
    }
    
    // 滚动
    TUIMessageSearchDataProvider *provider = (TUIMessageSearchDataProvider *)self.messageDataProvider;
    provider.isNewerNoMoreMsg = NO;
    provider.isOlderNoMoreMsg = NO;
    [self loadLocateMessages:NO];
}


@end
