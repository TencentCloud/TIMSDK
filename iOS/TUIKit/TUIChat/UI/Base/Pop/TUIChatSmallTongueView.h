//
//  TUIChatSmallTongue.h
//  TUIChat
//
//  Created by xiangzhang on 2022/1/6.
//

#import <UIKit/UIKit.h>
@class TUIChatSmallTongue;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TUIChatSmallTongueType) {
    TUIChatSmallTongueType_None,
    TUIChatSmallTongueType_ScrollToBoom,
    TUIChatSmallTongueType_ReceiveNewMsg,
    TUIChatSmallTongueType_SomeoneAtMe,
};

@protocol TUIChatSmallTongueViewDelegate <NSObject>
- (void)onChatSmallTongueClick:(TUIChatSmallTongue *)tongue;
@end

@interface TUIChatSmallTongueView : UIView
@property(nonatomic, weak) id<TUIChatSmallTongueViewDelegate> delegate;
- (void)setTongue:(TUIChatSmallTongue *)tongue;
@end

@interface TUIChatSmallTongue : NSObject
@property(nonatomic, assign) TUIChatSmallTongueType type;
@property(nonatomic, assign) uint64_t unreadMsgCount;
@property(nonatomic, strong) NSArray *atMsgSeqs;
@end

@interface TUIChatSmallTongueManager : NSObject
+ (void)showTongue:(TUIChatSmallTongue *)tongue delegate:(id<TUIChatSmallTongueViewDelegate>) delegate;
+ (void)removeTongue:(TUIChatSmallTongueType)type;
+ (void)removeTongue;
+ (void)hideTongue:(BOOL)isHidden;
@end

NS_ASSUME_NONNULL_END
