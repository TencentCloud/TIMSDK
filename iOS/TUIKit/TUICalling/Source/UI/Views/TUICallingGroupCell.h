//
//  TUICallingGroupCell.h
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import <UIKit/UIKit.h>
#import "TRTCCallingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingGroupCell : UICollectionViewCell

@property (nonatomic, strong) CallUserModel *model;

@property (nonatomic, weak) UIView *renderView;

@end

NS_ASSUME_NONNULL_END
