//
//  TUICalleeDelegateManager.h
//  TUICalling
//
//  Created by noah on 2021/9/23.
//

#import <Foundation/Foundation.h>
#import "TRTCCallingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICalleeDelegateManager : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (void)reloadCallingGroupWithModel:(NSArray <CallUserModel *>*)models;

@end

NS_ASSUME_NONNULL_END
