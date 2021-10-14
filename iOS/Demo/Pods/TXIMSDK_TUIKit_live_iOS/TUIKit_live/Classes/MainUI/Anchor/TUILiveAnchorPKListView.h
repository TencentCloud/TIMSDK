//
//  TUILiveAnchorPKListView.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUILiveAnchorPKListView;
@class TRTCLiveRoomInfo;
@protocol TUILiveAnchorPKListViewDelegate <NSObject>

- (void)pkListView:(TUILiveAnchorPKListView *)view didSelectRoom:(TRTCLiveRoomInfo *)roomInfo;
- (void)pkListViewDidHidden:(TUILiveAnchorPKListView *)view;

@end

@interface TUILiveAnchorPKCell: UITableViewCell


@end

@interface TUILiveAnchorPKListView : UIView

@property(nonatomic, weak)id<TUILiveAnchorPKListViewDelegate> delegate;

- (void)showWithRoomInfos:(NSArray<TRTCLiveRoomInfo *> *)infos;

- (void)refreshRoomInfos:(NSArray<TRTCLiveRoomInfo *> *)infos;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
