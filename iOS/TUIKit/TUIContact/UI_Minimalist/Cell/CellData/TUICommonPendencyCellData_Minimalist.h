//
//  TCommonPendencyCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TUICommonModel.h"
@class V2TIMFriendApplication;

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonPendencyCellData_Minimalist : TUICommonCellData
@property V2TIMFriendApplication *application;
@property NSString *identifier;
@property NSURL *avatarUrl;
@property NSString *title;
@property NSString *addSource;
@property NSString *addWording;
@property BOOL isAccepted;
@property BOOL isRejected;
@property SEL cbuttonSelector;
@property SEL cRejectButtonSelector;

@property BOOL hideSource;

- (instancetype)initWithPendency:(V2TIMFriendApplication *)application;

- (void)agree;
- (void)reject;

@end

NS_ASSUME_NONNULL_END
