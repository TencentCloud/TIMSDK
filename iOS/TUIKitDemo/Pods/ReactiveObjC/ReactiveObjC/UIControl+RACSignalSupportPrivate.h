//
//  UIControl+RACSignalSupportPrivate.h
//  ReactiveObjC
//
//  Created by Uri Baghin on 06/08/2013.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACChannelTerminal;

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (RACSignalSupportPrivate)

/// Adds a RACChannel-based interface to the receiver for the given
/// UIControlEvents and exposes it.
///
/// controlEvents - A mask of UIControlEvents on which to send new values.
/// key           - The key whose value should be read and set when a control
///                 event fires and when a value is sent to the
///                 RACChannelTerminal respectively.
/// nilValue      - The value to be assigned to the key when `nil` is sent to the
///                 RACChannelTerminal. This value can itself be nil.
///
/// Returns a RACChannelTerminal which will send future values from the receiver,
/// and update the receiver when values are sent to the terminal.
- (RACChannelTerminal *)rac_channelForControlEvents:(UIControlEvents)controlEvents key:(NSString *)key nilValue:(nullable id)nilValue;

@end

NS_ASSUME_NONNULL_END
