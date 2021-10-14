//
//  TRTCV2TIMMessageObservable.h
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol V2TIMGroupListener;
@interface TRTCV2TIMMessageObservable : NSObject

- (void)addObserver:(id<V2TIMGroupListener>)listener;

@end

NS_ASSUME_NONNULL_END
