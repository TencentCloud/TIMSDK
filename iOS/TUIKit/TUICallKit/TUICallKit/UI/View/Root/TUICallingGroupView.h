//
//  TUICallingGroupView.h
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>
#import "BaseCallViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingGroupView : UIView <BaseCallViewProtocol>

- (instancetype)initWithFrame:(CGRect)frame localPreView:(TUICallingVideoRenderView *)localPreView;

@end

NS_ASSUME_NONNULL_END
