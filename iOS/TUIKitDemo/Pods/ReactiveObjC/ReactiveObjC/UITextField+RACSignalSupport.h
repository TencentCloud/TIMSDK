//
//  UITextField+RACSignalSupport.h
//  ReactiveObjC
//
//  Created by Josh Abernathy on 4/17/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACChannelTerminal<ValueType>;
@class RACSignal<__covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (RACSignalSupport)

/// Creates and returns a signal for the text of the field. It always starts with
/// the current text. The signal sends next when the UIControlEventAllEditingEvents
/// control event is fired on the control.
- (RACSignal<NSString *> *)rac_textSignal;

/// Creates a new RACChannel-based binding to the receiver.
///
/// Returns a RACChannelTerminal that sends the receiver's text whenever the
/// UIControlEventAllEditingEvents control event is fired, and sets the text
/// to the values it receives.
- (RACChannelTerminal<NSString *> *)rac_newTextChannel;

@end

NS_ASSUME_NONNULL_END
