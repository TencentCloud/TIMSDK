//
//  TUIChatObjectFactory.m
//  TUIChat
//
//  Created by wyl on 2023/3/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatObjectFactory.h"
#import <TUICore/NSDictionary+TUISafe.h>
#import "TUIC2CChatViewController.h"
#import "TUIChatConfig.h"
#import "TUIChatDefine.h"
#import "TUIGroupChatViewController.h"

@interface TUIChatObjectFactory () <TUIObjectProtocol>

@end

@implementation TUIChatObjectFactory
+ (void)load {
    [TUICore registerObjectFactory:TUICore_TUIChatObjectFactory objectFactory:[TUIChatObjectFactory shareInstance]];
}
+ (TUIChatObjectFactory *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIChatObjectFactory *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TUIChatObjectFactory alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TUIObjectProtocol
- (id)onCreateObject:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIChatObjectFactory_ChatViewController_Classic]) {
        return [self createChatViewControllerParam:param];
    }
    return nil;
}

#pragma mark - Private

- (UIViewController *)createChatViewControllerParam:(nullable NSDictionary *)param {
    
    NSString *title = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_Title asClass:NSString.class];
    NSString *userID = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_UserID asClass:NSString.class];
    NSString *groupID = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_GroupID asClass:NSString.class];
    NSString *conversationID = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_ConversationID asClass:NSString.class];
    UIImage *avatarImage = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage asClass:UIImage.class];
    NSString *avatarUrl = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl asClass:NSString.class];
    NSString *highlightKeyword = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_HighlightKeyword asClass:NSString.class];
    V2TIMMessage *locateMessage = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_LocateMessage asClass:V2TIMMessage.class];
    NSArray * atMsgSeqs = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_AtMsgSeqs asClass:NSArray.class];
    NSString *draft = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_Draft asClass:NSString.class];
    NSString *isEnableVideoInfoStr = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_Enable_Video_Call asClass:NSString.class];
    NSString *isEnableAudioInfoStr = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_Enable_Audio_Call asClass:NSString.class];
    NSString *isEnableRoomInfoStr = [param tui_objectForKey:TUICore_TUIChatObjectFactory_ChatViewController_Enable_Room asClass:NSString.class];
    
    TUIChatConversationModel *conversationModel = [[TUIChatConversationModel alloc] init];
    conversationModel.title = title;
    conversationModel.userID = userID;
    conversationModel.groupID = groupID;
    conversationModel.conversationID = conversationID;
    conversationModel.avatarImage = avatarImage;
    conversationModel.faceUrl = avatarUrl;
    conversationModel.atMsgSeqs = [NSMutableArray arrayWithArray:atMsgSeqs];
    conversationModel.draftText = draft;

    if ([isEnableVideoInfoStr isEqualToString:@"0"]) {
        conversationModel.enabelVideo = NO;
    }
    
    if ([isEnableAudioInfoStr isEqualToString:@"0"]) {
        conversationModel.enabelAudio = NO;
    }
    
    if ([isEnableRoomInfoStr isEqualToString:@"0"]) {
        conversationModel.enabelRoom = NO;
    }
    
    TUIBaseChatViewController *chatVC = nil;
    if (conversationModel.groupID.length > 0) {
        chatVC = [[TUIGroupChatViewController alloc] init];
    } else if (conversationModel.userID.length > 0) {
        chatVC = [[TUIC2CChatViewController alloc] init];
    }
    chatVC.conversationData = conversationModel;
    chatVC.title = conversationModel.title;
    chatVC.highlightKeyword = highlightKeyword;
    chatVC.locateMessage = locateMessage;
    return chatVC;
}

@end
