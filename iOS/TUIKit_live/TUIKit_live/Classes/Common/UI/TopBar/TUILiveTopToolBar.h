//
//  TUILiveTopToolBar.h
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUILiveAnchorInfo.h"
#import "TUILiveTopBarAudienceListView.h"

NS_ASSUME_NONNULL_BEGIN

@class TUILiveTopToolBar;
//info: AnchorInfo/audienceInfo/nil
typedef void(^TUILiveTopToolBarClickBlock)(id toolBar, id info);

@interface TUILiveTopToolBar : UIView
@property(nonatomic, strong) UIView *anchorInfoBackgroundView;
@property(nonatomic, strong) UIButton *avatarButton; /// 主播头像
@property(nonatomic, strong) UILabel *nicknameLabel; /// 主播昵称
@property(nonatomic, strong) UIButton *tagButton; /// 主播《经验》标签
@property(nonatomic, strong) UIButton *followButton; /// 主播关注按钮
@property(nonatomic, strong) UIButton *onLineNumButton; /// 在线人数
@property(nonatomic, strong) TUILiveTopBarAudienceListView *audienceListView;

@property(nonatomic, assign) BOOL hasFollowed; //0.已关注，隐藏 1.未关注
@property(nonatomic, strong) TUILiveAnchorInfo *anchorInfo;//主播信息
@property(nonatomic, strong) NSArray<TUILiveAnchorInfo *> *audienceList;//观众列表

/// 点击主播头像，返回主播Info信息
@property(nonatomic, strong) TUILiveTopToolBarClickBlock onClickAnchorAvator;
/// 点击关注按钮
@property(nonatomic, strong) TUILiveTopToolBarClickBlock onClickFollow;
/// 点击观众头像，返回观众Info信息
@property(nonatomic, strong) TUILiveTopToolBarClickBlock onClickAudience;
/// 点击在线人数
@property(nonatomic, strong) TUILiveTopToolBarClickBlock onClickOnlineNum;

/// 更新信息后，主动调用一下刷新
- (void)updateUIInfo;
@end

NS_ASSUME_NONNULL_END
