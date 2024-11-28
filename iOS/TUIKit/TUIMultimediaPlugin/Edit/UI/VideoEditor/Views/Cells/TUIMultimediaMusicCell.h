// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaBGM.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIMultimediaMusicCellState) {
    TUIMultimediaMusicCellStateNormal,
    TUIMultimediaMusicCellStateSelected,
    TUIMultimediaMusicCellStateEnabled,
};

@protocol TUIMultimediaMusicCellDelegate;

@interface TUIMultimediaMusicCell : UITableViewCell
@property(nonatomic) TUIMultimediaMusicCellState state;
@property(nullable, nonatomic) TUIMultimediaBGM *music;
@property(nonatomic) float selectDuration;
@property(weak, nullable, nonatomic) id<TUIMultimediaMusicCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
@end

@protocol TUIMultimediaMusicCellDelegate <NSObject>
- (void)musicCell:(TUIMultimediaMusicCell *)cell onEditStateChanged:(BOOL)editState;
- (void)musicCell:(TUIMultimediaMusicCell *)cell onBGMRangeChanged:(TUIMultimediaBGM *)bgm;
@end

NS_ASSUME_NONNULL_END
