//
//  TUIAudioCallUserCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/7.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIAudioCallUserCell : UICollectionViewCell
- (void)fillWithData:(CallUserModel *)model;
@end

NS_ASSUME_NONNULL_END
