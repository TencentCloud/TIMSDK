//
//  TUIBaseMessageController+ProtectedAPI.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//

#import "TUIBaseMessageController_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIChatConversationModel.h"

@class TUIMessageCellData_Minimalist;

NS_ASSUME_NONNULL_BEGIN

@interface TUIBaseMessageController_Minimalist ()<TUIMessageBaseDataProviderDataSource>

@property (nonatomic, strong) TUIMessageDataProvider_Minimalist *messageDataProvider;
@property (nonatomic, strong) TUIChatConversationModel *conversationData;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)onNewMessage:(NSNotification *)notification;

- (void)onJumpToRepliesDetailPage:(TUIMessageCellData *)data;

- (void)onJumpToRepliesEmojiPage:(TUIMessageCellData *)data faceList:(NSArray <TUITagsModel *>*)listModel;

@end

NS_ASSUME_NONNULL_END
