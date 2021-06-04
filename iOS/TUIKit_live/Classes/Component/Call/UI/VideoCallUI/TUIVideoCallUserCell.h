//
//  TUIVideoCallUserCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/8.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
#import "TUIVideoRenderView.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIVideoCallUserCell : UICollectionViewCell

- (void)fillWithData:(CallUserModel *)model renderView:(TUIVideoRenderView *)renderView;

@end

NS_ASSUME_NONNULL_END
