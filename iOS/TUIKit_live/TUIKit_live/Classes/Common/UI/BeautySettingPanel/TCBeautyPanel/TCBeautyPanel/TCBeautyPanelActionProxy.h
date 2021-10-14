//
//  TCBeautyPanelActionProxy.h
//  TCBeautyPanel
//
//  Created by cui on 2019/12/23.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCBeautyPanelActionPerformer.h"
#import "TCBeautyPanelView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCBeautyPanelActionProxy : NSProxy <TCBeautyPanelActionPerformer>
+ (instancetype)proxyWithSDKObject:(id)object;
@end

@interface TCBeautyPanel (SDK)
+ (instancetype)beautyPanelWithFrame:(CGRect)frame SDKObject:(id)object;
@end

NS_ASSUME_NONNULL_END
