//
//  TUICallingGroupCell.h
//  TUICalling
//
//  Created by noah on 2021/8/24.
//  Copyright © 2021 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>

@class TUIVideoView, CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingGroupCell : UICollectionViewCell

@property (nonatomic, strong) CallingUserModel *model;
/// 视频渲染视图
@property (nonatomic, weak) TUIVideoView *renderView;

@end

NS_ASSUME_NONNULL_END
