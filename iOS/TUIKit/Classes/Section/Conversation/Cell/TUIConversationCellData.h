//
//  TUIConversationCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TCommonCell.h"
@import ImSDK;

NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationCellData : TCommonCellData

- (instancetype)initWithConversation:(TIMConversation *)conv;

@property (nonatomic, strong) NSString *convId;
@property (nonatomic, assign) TIMConversationType convType;
@property NSURL *avatarUrl;
@property UIImage *avatarImage;
@property NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, assign) int unRead;
@property BOOL isOnTop;

@end

NS_ASSUME_NONNULL_END
