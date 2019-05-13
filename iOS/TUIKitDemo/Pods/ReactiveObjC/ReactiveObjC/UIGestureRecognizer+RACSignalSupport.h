//
//  UIGestureRecognizer+RACSignalSupport.h
//  ReactiveObjC
//
//  Created by Josh Vera on 5/5/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal<__covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (RACSignalSupport)

/// Returns a signal that sends the receiver when its gesture occurs.
- (RACSignal<__kindof UIGestureRecognizer *> *)rac_gestureSignal;

@end

NS_ASSUME_NONNULL_END
