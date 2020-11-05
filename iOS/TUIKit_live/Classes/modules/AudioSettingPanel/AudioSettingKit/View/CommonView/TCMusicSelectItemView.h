//
//  TCMusicSelectItemView.h
//  TCAudioSettingKitResources
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCMusicSelectItemDelegate <NSObject>

- (void)didClickItem;
- (void)didClickPausButton:(BOOL)isPause;

@end

@interface TCMusicSelectItemView : UIView

@property (nonatomic, weak) id<TCMusicSelectItemDelegate> delegate;

/// 选中音乐后传入名称
/// @param musicName 音乐名（空字符串代表没有选中）
- (void)selectMusic:(NSString *)musicName;
- (void)refreshMusicPlayingProgress:(NSString *)progressString;
- (void)completeStatus;

@end

NS_ASSUME_NONNULL_END
