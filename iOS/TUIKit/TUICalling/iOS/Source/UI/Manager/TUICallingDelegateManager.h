//
//  TUICallingDelegateManager.h
//  TUICalling
//
//  Created by noah on 2021/8/23.
//

#import <Foundation/Foundation.h>
#import "TRTCCallingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingDelegateManager : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;

- (__kindof UIView * _Nullable)getRenderViewFromUser:(NSString *)userId;

- (void)reloadCallingGroupWithModel:(NSArray <CallUserModel *>*)models;

- (void)reloadGroupCellWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
