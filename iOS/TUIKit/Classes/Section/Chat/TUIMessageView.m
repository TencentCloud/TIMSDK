//
//  TUIMessageView.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIMessageView.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIImageMessageCell.h"
#import "TUIFaceMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "THeader.h"
#import "TUIKIT.h"
@import ImSDK;

@interface TUIMessageView () <UITableViewDelegate, UITableViewDataSource, TIMMessageListener>
@property (nonatomic, strong) NSMutableArray *msgs;
@property (nonatomic, strong) NSMutableArray *heightCache;
@property (nonatomic, strong) NSDate *lastMsgTimestamp;
@property (nonatomic, assign) BOOL isScrollBottom;
@end

@implementation TUIMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self setupData];
    }
    return self;
}

- (void)setupViews
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 0;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.backgroundColor = TMessageController_Background_Color;
    [self addSubview:_tableView];
    
    _heightCache = [NSMutableArray array];
    
    _msgs = [[NSMutableArray alloc] init];

}

- (void)setupData
{
    TIMManager *manager = [TIMManager sharedInstance];
    [manager addMessageListener:self];
}

- (void)onNewMessage:(NSArray *)msgs
{
    [self parseMessage:msgs];
}

- (void)parseMessage:(NSArray *)msgs
{
    for (NSInteger k = msgs.count - 1; k >= 0; --k) {
        TIMMessage *msg = msgs[k];
        if(_lastMsgTimestamp == nil || [self shouldShowDate:msg.timestamp]){
            TUISystemMessageCellData *system = [[TUISystemMessageCellData alloc] initWithDirection:msg.isSelf?MsgDirectionOutgoing:MsgDirectionIncoming];
            system.content = [msg.timestamp tk_messageString];
            [_msgs addObject:system];
            _lastMsgTimestamp = msg.timestamp;
        }
        for (int i = 0; i < msg.elemCount; ++i) {
            TIMElem *elem = [msg getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:(msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                data.content = text.text;
                [_msgs addObject:data];
            }
            else if([elem isKindOfClass:[TIMImageElem class]]){
            }
            else if([elem isKindOfClass:[TIMSoundElem class]]){
            }
            else if([elem isKindOfClass:[TIMVideoElem class]]){
            }
            else{
            }
        }
    }
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.tableView reloadData];
        [ws scrollToBottom:YES];
    });
}
#pragma mark - Table view data source

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isScrollBottom == NO) {
        [self scrollToBottom:NO];
        if (indexPath.row == _msgs.count-1) {
            _isScrollBottom = YES;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if(_heightCache.count < indexPath.row){
        return [_heightCache[indexPath.row] floatValue];
    }
    TUIMessageCellData *data = _msgs[indexPath.row];
    height = [data heightOfWidth:Screen_Width];
    [_heightCache addObject:[NSNumber numberWithFloat:height]];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *data = _msgs[indexPath.row];
    if([data isKindOfClass:[TUITextMessageCellData class]]){
        TUITextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:TTextMessageCell_ReuseId];
        if(!cell){
            cell = [[TUITextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TTextMessageCell_ReuseId];
        }
        [cell fillWithData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TUIVoiceMessageCellData class]]){
        TUIVoiceMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:TVoiceMessageCell_ReuseId];
        if(!cell){
            cell = [[TUIVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TVoiceMessageCell_ReuseId];
        }
        [cell fillWithData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TUIImageMessageCellData class]]){
        static NSString *imageReuseId = @"imageCell";
        TUIImageMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:imageReuseId];
        if(!cell){
            cell = [[TUIImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageReuseId];
        }
        [cell fillWithData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TUISystemMessageCellData class]]){
        TUISystemMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:TSystemMessageCell_ReuseId];
        if(!cell){
            cell = [[TUISystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSystemMessageCell_ReuseId];
        }
        [cell fillWithData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TUIFaceMessageCellData class]]){
        TUIFaceMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:TFaceMessageCell_ReuseId];
        if(!cell){
            cell = [[TUIFaceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TFaceMessageCell_ReuseId];
        }
        [cell fillWithData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TUIVideoMessageCellData class]]){
        static NSString *videoReuseId = @"videoCell";
        TUIVideoMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:videoReuseId];
        if(!cell){
            cell = [[TUIVideoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoReuseId];
        }
        [cell fillWithData:_msgs[indexPath.row]];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollToBottom:(BOOL)animate
{
    if (_msgs.count > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_msgs.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    }
}

- (void)sendMessage:(TUIMessageCellData *)msg
{
    [_msgs addObject:msg];
    [self.tableView reloadData];
    [self scrollToBottom:YES];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _tableView.frame = self.bounds;
}

- (BOOL)shouldShowDate:(NSDate *)big
{
    if([big timeIntervalSinceDate:_lastMsgTimestamp] > 3 * 60){
        return YES;
    }
    return NO;
}

@end
