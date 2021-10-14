//
//  TUILiveJoinAnchorListView.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TRTCLiveUserInfo;
@class TUILiveJoinAnchorListView;
@protocol TUILiveJoinAnchorListViewDelegate <NSObject>

- (void)joinAnchorListView:(TUILiveJoinAnchorListView *)listView didRespondJoinAnchor:(TRTCLiveUserInfo *)user agree:(BOOL)agree;
- (void)joinAnchorListViewDidHidden;

@end

@interface TUILiveJoinAnchorCell: UITableViewCell


@end


@interface TUILiveJoinAnchorListView : UIView

@property(nonatomic, weak)id<TUILiveJoinAnchorListViewDelegate> delegate;

- (void)showWithUserInfos:(NSArray<TRTCLiveUserInfo *> *)infos;

- (void)refreshUserInfos:(NSArray<TRTCLiveUserInfo *> *)infos;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
