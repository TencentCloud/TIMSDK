//
//  TUICallingGroupDelegateManager.h
//  TUICalling
//
//  Created by noah on 2021/8/23.
//  Copyright © 2021 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TUIVideoView, CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingGroupDelegateManager : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;

- (__kindof TUIVideoView * _Nullable)getRenderViewFromUser:(NSString *)userId;

- (void)reloadCallingGroupWithModel:(NSArray <CallingUserModel *>*)models;

- (void)reloadGroupCellWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

