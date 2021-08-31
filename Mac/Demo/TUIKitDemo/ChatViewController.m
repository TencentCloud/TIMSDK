//
//  ChatViewController.m
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/22.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import "ChatViewController.h"
#import "ImSDK.h"
#import "TIMConversation+MsgExt.h"

@interface ChatViewController () <TIMMessageListener>
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, strong) TIMMessage *msgForGet;
@end

@implementation ChatViewController
{
    NSMutableAttributedString *_oldMessage;
    BOOL _isLoadingMsg;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _oldMessage = [[NSMutableAttributedString alloc] initWithString:@""];
    self.groupMember.stringValue = self.conversation.title;
    self.msgTextView.editable = NO;
    [[TIMManager sharedInstance] addMessageListener:self];
    
    //获取缓存会话信息
    [self loadMessage];
}

- (void)loadMessage
{
    if(_isLoadingMsg){
        return;
    }
    _isLoadingMsg = YES;
    TIMConversation *conv = [[TIMManager sharedInstance]
                             getConversation:(TIMConversationType)_conversation.convType
                             receiver:_conversation.convId];
    __weak typeof(self) ws = self;
    //这里只做最简单的逻辑展示，更复杂的逻辑请参考 ios Demo源码
    [conv getMessage:20 last:_msgForGet succ:^(NSArray *msgs) {
        if(msgs.count != 0){
            ws.msgForGet = msgs[msgs.count - 1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws parseMessage:msgs];
        });
        ws.isLoadingMsg = NO;
    } fail:^(int code, NSString *msg) {
        ws.isLoadingMsg = NO;
        //to do
    }];
}

- (IBAction)sendBtnClick:(NSButton *)sender {
    NSString *loginUser = [[TIMManager sharedInstance] getLoginUser];
    NSString *text = self.msgTextFeild.stringValue;
    [self sendMsgToTextView:text user:loginUser];
    
    TIMMessage *imMsg = [[TIMMessage alloc] init];
    TIMTextElem *imText = [[TIMTextElem alloc] init];
    imText.text = text;
    [imMsg addElem:imText];
    
    TIMConversation *conv = [[TIMManager sharedInstance]
                             getConversation:(TIMConversationType)_conversation.convType
                             receiver:_conversation.convId];
    [conv sendMessage:imMsg succ:^{
        NSLog(@"发送成功");
    } fail:^(int code, NSString *desc) {
        NSLog(@"发送失败");
    }];
    self.msgTextFeild.stringValue = @"";
}

- (void)sendMsgToTextView:(NSString *)msg user:(NSString *)user{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ :  %@",user,msg]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, user.length + 1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(user.length + 2, 1)];
    [attributedString insertAttributedString:_oldMessage atIndex:0];
    _oldMessage = attributedString;
    [self.msgTextView.textStorage setAttributedString:_oldMessage];
    [self.msgTextView scrollToEndOfDocument:self.msgTextView];
}

#pragma TIMMessageListener
- (void)onNewMessage:(NSArray*)msgs
{
    [self parseMessage:msgs];
}

- (void)parseMessage:(NSArray *)msgs
{
    //这里只做text文本消息的代码展示，其他更复杂的消息请参考 ios Demo源码
    for (NSInteger k = msgs.count - 1; k >= 0; --k) {
        TIMMessage *msg = msgs[k];
        for (int i = 0; i < msg.elemCount; ++i) {
            TIMElem *elem = [msg getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                [self sendMsgToTextView:text.text user:[msg sender]];
            }
        }
    }
}

@end
