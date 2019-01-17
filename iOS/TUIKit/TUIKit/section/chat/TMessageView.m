//
//  TMessageView.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TMessageView.h"
#import "TTextMessageCell.h"
#import "TSystemMessageCell.h"
#import "TVoiceMessageCell.h"
#import "TImageMessageCell.h"
#import "TFaceMessageCell.h"
#import "TVideoMessageCell.h"
#import "THeader.h"
#import "IMMessageExt.h"

@interface TMessageView () <UITableViewDelegate, UITableViewDataSource, TIMMessageListener>
@property (nonatomic, strong) NSMutableArray *msgs;
@property (nonatomic, strong) NSMutableArray *heightCache;
@property (nonatomic, strong) NSDate *lastMsgTimestamp;
@property (nonatomic, assign) BOOL isScrollBottom;
@end

@implementation TMessageView

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView)];
    [self addGestureRecognizer:tap];
    
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 0;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.backgroundColor = TMessageController_Background_Color;
    [self addSubview:_tableView];
    
    _heightCache = [NSMutableArray array];
    
    _msgs = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 30; i++) {
//        if(i % 5 == 0){
//            TSystemMessageCellData *data = [[TSystemMessageCellData alloc] init];
//            data.content = @"9月21日 下午3:18";
//            [_msgs addObject:data];
//        }
//        else if(i % 5 == 1){
//            TVoiceMessageCellData *data = [[TVoiceMessageCellData alloc] init];
//            data.duration = rand() % 60 + 1;
//            data.isSelf = (rand() % 2 == 1);
//            NSString *head = [NSString stringWithFormat:@"%d", i % 6];
//            data.head = TUIKitResource(head);
//            [_msgs addObject:data];
//        }
//        else if(i % 5 == 2){
//            TImageMessageCellData *data = [[TImageMessageCellData alloc] init];
//            data.isSelf = (rand() % 2 == 1);
//            NSString *head = [NSString stringWithFormat:@"%d", i % 6];
//            data.head = TUIKitResource(head);
//            NSString *thumb = [NSString stringWithFormat:@"thumb_%d", rand() % 2 + 1];
//            data.thumb = TUIKitResource(thumb);
//            UIImage *image = [UIImage imageNamed:data.thumb];
//            data.size = image.size;
//            [_msgs addObject:data];
//        }
//        else if(i % 5 == 3){
//            TVideoMessageCellData *data = [[TVideoMessageCellData alloc] init];
//            data.isSelf = (rand() % 2 == 1);
//            NSString *head = [NSString stringWithFormat:@"%d", i % 6];
//            data.head = TUIKitResource(head);
//            NSString *thumb = [NSString stringWithFormat:@"thumb_%d", rand() % 2 + 1];
//            data.thumb = TUIKitResource(thumb);
//            UIImage *image = [UIImage imageNamed:data.thumb];
//            data.thumbSize = image.size;
//            data.time = rand() % 300 + 1;
//            [_msgs addObject:data];
//        }
//        else{
//            TTextMessageCellData *data = [[TTextMessageCellData alloc] init];
//            NSString *head = [NSString stringWithFormat:@"%d", i % 6];
//            data.head = TUIKitResource(head);
//            data.content = [[NSAttributedString alloc] initWithString:@"一对年轻男女公交车上激吻半小时，乘客们实在看不下去了，纷纷上前指责：尼玛前戏也太长了吧，我们都坐过很多站了"];
//            data.isSelf = (rand() % 2 == 1);
//            [_msgs addObject:data];
//        }
//    }
}

- (void)setupData
{
    __weak typeof(self) ws = self;
    TIMManager *manager = [TIMManager sharedInstance];
    [manager addMessageListener:self];
    TIMConversation *conv = [manager getConversation:TIM_C2C receiver:@"user1"];
    [conv getMessage:20 last:nil succ:^(NSArray *msgs) {
        [ws parseMessage:msgs];
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
    }];
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
            TSystemMessageCellData *system = [[TSystemMessageCellData alloc] init];
            system.content = [self getDateDisplayString:msg.timestamp];
            [_msgs addObject:system];
            _lastMsgTimestamp = msg.timestamp;
        }
        for (int i = 0; i < msg.elemCount; ++i) {
            TIMElem *elem = [msg getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                TTextMessageCellData *data = [[TTextMessageCellData alloc] init];
                data.content = text.text;
                data.isSelf = msg.isSelf;
                data.head = TUIKitResource(@"default_head");
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
    NSObject *data = _msgs[indexPath.row];
    if([data isKindOfClass:[TTextMessageCellData class]]){
        TTextMessageCellData *text = _msgs[indexPath.row];
        TTextMessageCell *cell = [[TTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TTextMessageCell_ReuseId];
        height = [cell getHeight:text];
    }else if([data isKindOfClass:[TVoiceMessageCellData class]]){
        TVoiceMessageCellData *voice = _msgs[indexPath.row];
        TVoiceMessageCell *cell = [[TVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TVoiceMessageCell_ReuseId];
        height = [cell getHeight:voice];
    }
    else if([data isKindOfClass:[TImageMessageCellData class]]){
        TImageMessageCellData *image = _msgs[indexPath.row];
        TImageMessageCell *cell = [[TImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TImageMessageCell_ReuseId];
        height = [cell getHeight:image];
    }
    else if([data isKindOfClass:[TSystemMessageCellData class]]){
        TSystemMessageCellData *system = _msgs[indexPath.row];
        TSystemMessageCell *cell = [[TSystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSystemMessageCell_ReuseId];
        height = [cell getHeight:system];
    }
    else if([data isKindOfClass:[TFaceMessageCellData class]]){
        TFaceMessageCellData *face = _msgs[indexPath.row];
        TFaceMessageCell *cell = [[TFaceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TFaceMessageCell_ReuseId];
        height = [cell getHeight:face];
    }
    else if([data isKindOfClass:[TVideoMessageCellData class]]){
//        TVideoMessageCellData *face = _msgs[indexPath.row];
//        TVideoMessageCell *cell = [[TVideoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TFaceMessageCell_ReuseId];
//        height = [TVideoMessageCell getHeight:face];
    }
    [_heightCache addObject:[NSNumber numberWithFloat:height]];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *data = _msgs[indexPath.row];
    if([data isKindOfClass:[TTextMessageCellData class]]){
        TTextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:TTextMessageCell_ReuseId];
        if(!cell){
            cell = [[TTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TTextMessageCell_ReuseId];
        }
        [cell setData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TVoiceMessageCellData class]]){
        TVoiceMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:TVoiceMessageCell_ReuseId];
        if(!cell){
            cell = [[TVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TVoiceMessageCell_ReuseId];
        }
        [cell setData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TImageMessageCellData class]]){
        static NSString *imageReuseId = @"imageCell";
        TImageMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:imageReuseId];
        if(!cell){
            cell = [[TImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageReuseId];
        }
        [cell setData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TSystemMessageCellData class]]){
        TSystemMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:TSystemMessageCell_ReuseId];
        if(!cell){
            cell = [[TSystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSystemMessageCell_ReuseId];
        }
        [cell setData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TFaceMessageCellData class]]){
        TFaceMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:TFaceMessageCell_ReuseId];
        if(!cell){
            cell = [[TFaceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TFaceMessageCell_ReuseId];
        }
        [cell setData:_msgs[indexPath.row]];
        return cell;
    }
    else if([data isKindOfClass:[TVideoMessageCellData class]]){
        static NSString *videoReuseId = @"videoCell";
        TVideoMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:videoReuseId];
        if(!cell){
            cell = [[TVideoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoReuseId];
        }
        [cell setData:_msgs[indexPath.row]];
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

- (void)didTapView
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapMessageView:)]){
        [_delegate didTapMessageView:self];
    }
}

- (void)sendMessage:(TMessageCellData *)msg
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

- (NSString *)getDateDisplayString:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:date];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    
    NSDateComponents *comp =  [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    
    if (nowCmps.day==myCmps.day) {
        dateFmt.AMSymbol = @"上午";
        dateFmt.PMSymbol = @"下午";
        dateFmt.dateFormat = @"aaa hh:mm";
        
    } else if((nowCmps.day-myCmps.day)==1) {
        dateFmt.AMSymbol = @"上午";
        dateFmt.PMSymbol = @"下午";
        dateFmt.dateFormat = @"昨天 aaahh:mm";
        
    } else {
        dateFmt.AMSymbol = @"上午";
        dateFmt.PMSymbol = @"下午";
        if ((nowCmps.day-myCmps.day) <=7) {
            switch (comp.weekday) {
                case 1:
                    dateFmt.dateFormat = @"星期日 aaahh:mm";
                    break;
                case 2:
                    dateFmt.dateFormat = @"星期一 aaahh:mm";
                    break;
                case 3:
                    dateFmt.dateFormat = @"星期二 aaahh:mm";
                    break;
                case 4:
                    dateFmt.dateFormat = @"星期三 aaahh:mm";
                    break;
                case 5:
                    dateFmt.dateFormat = @"星期四 aaahh:mm";
                    break;
                case 6:
                    dateFmt.dateFormat = @"星期五 aaahh:mm";
                    break;
                case 7:
                    dateFmt.dateFormat = @"星期六 aaahh:mm";
                    break;
                default:
                    break;
            }
        }else {
            dateFmt.dateFormat = @"yyyy年MM月dd日 aaahh:mm";
        }
    }
    return [dateFmt stringFromDate:date];
}
@end
