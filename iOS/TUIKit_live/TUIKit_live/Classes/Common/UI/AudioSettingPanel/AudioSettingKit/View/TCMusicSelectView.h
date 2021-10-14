//
//  TCMusicSelectView.h
//  TCAudioSettingKitResources
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AudioEffectSettingViewModel;
@class TCMusicSelectedModel;
@class TCMusicSelectView;
@protocol TCMusicSelectedDelegate <NSObject>

- (void)didSelectMusic:(TCMusicSelectedModel *)music isSelected:(BOOL)isSelected;
- (void)selectViewChangeState:(TCMusicSelectView *)view;

@end

@interface TCMusicSelectView : UIView

@property (nonatomic, weak) id<TCMusicSelectedDelegate> delegate;

- (instancetype)initWithViewModel:(AudioEffectSettingViewModel *)viewModel;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
