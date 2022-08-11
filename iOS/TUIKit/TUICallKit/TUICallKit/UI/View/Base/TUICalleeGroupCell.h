//
//  TUICalleeGroupCell.h
//  TUICalling
//
//  Created by noah on 2021/9/23.
//  Copyright © 2021 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>

@class CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUICalleeGroupCell : UICollectionViewCell

@property (nonatomic, strong) CallingUserModel *model;

@end

NS_ASSUME_NONNULL_END
