//
//  TChatController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TChatController.h"
#import "THeader.h"

@interface TChatController () <TMessageControllerDelegate, TInputControllerDelegate>
@end

@implementation TChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews
{
    self.title = _conversation.title;
    self.parentViewController.title = _conversation.title;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //left
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(leftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:TUIKitResource(@"back")] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -10.0f;
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)) {
        leftButton.contentEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
        leftButton.imageEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
    }
    self.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];
    self.parentViewController.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];
    
    
    //right
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    if(_conversation.convType == TConv_Type_C2C){
//        [rightButton setImage:[UIImage imageNamed:TUIKitResource(@"personal")] forState:UIControlStateNormal];
    }
    else if(_conversation.convType == TConv_Type_Group){
        [rightButton setImage:[UIImage imageNamed:TUIKitResource(@"group")] forState:UIControlStateNormal];
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;
    
    //message
    _messageController = [[TMessageController alloc] init];
    _messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight);
    _messageController.delegate = self;
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];
    [_messageController setConversation:_conversation];
    
    //input
    _inputController = [[TInputController alloc] init];
    _inputController.view.frame = CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.delegate = self;
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];
}


- (void)rightBarButtonClick{
    if(_conversation.convType == TConv_Type_C2C){
        return;
    }
    if(_delegate && [_delegate respondsToSelector:@selector(chatControllerDidClickRightBarButton:)]){
        [_delegate chatControllerDidClickRightBarButton:self];
    }
}

- (void)leftBarButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inputController:(TInputController *)inputController didChangeHeight:(CGFloat)height
{
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = ws.messageController.view.frame;
        msgFrame.size.height = ws.view.frame.size.height - height;
        ws.messageController.view.frame = msgFrame;
        
        CGRect inputFrame = ws.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        ws.inputController.view.frame = inputFrame;
        
        [ws.messageController scrollToBottom:NO];
    } completion:nil];
}

- (void)inputController:(TInputController *)inputController didSendMessage:(TMessageCellData *)msg
{
    [_messageController sendMessage:msg];
}

- (void)inputController:(TInputController *)inputController didSelectMoreAtIndex:(NSInteger)index
{
    if(_delegate && [_delegate respondsToSelector:@selector(chatController:didSelectMoreAtIndex:)]){
        [_delegate chatController:self didSelectMoreAtIndex:index];
    }
}

- (void)didTapInMessageController:(TMessageController *)controller
{
    [_inputController reset];
}

- (BOOL)messageController:(TMessageController *)controller willShowMenuInCell:(TMessageCell *)cell
{
    if([_inputController.textView.inputTextView isFirstResponder]){
        _inputController.textView.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (void)didHideMenuInMessageController:(TMessageController *)controller
{
    _inputController.textView.inputTextView.overrideNextResponder = nil;
}

- (void)messageController:(TMessageController *)controller didSelectMessages:(NSMutableArray *)msgs atIndex:(NSInteger)index
{
    if(_delegate && [_delegate respondsToSelector:@selector(chatController:didSelectMessages:atIndex:)]){
        [_delegate chatController:self didSelectMessages:msgs atIndex:index];
    }
}

- (void)sendImageMessage:(UIImage *)image;
{
    [_messageController sendImageMessage:image];
}

- (void)sendVideoMessage:(NSURL *)url
{
    [_messageController sendVideoMessage:url];
}

- (void)sendFileMessage:(NSURL *)url
{
    [_messageController sendFileMessage:url];
}
@end
