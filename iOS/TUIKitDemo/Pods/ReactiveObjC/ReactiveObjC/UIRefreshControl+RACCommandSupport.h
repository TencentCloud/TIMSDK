//
//  UIRefreshControl+RACCommandSupport.h
//  ReactiveObjC
//
//  Created by Dave Lee on 2013-10-17.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACCommand<__contravariant InputType, __covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface UIRefreshControl (RACCommandSupport)

/// Manipulate the RACCommand property associated with this refresh control.
///
/// When this refresh control is activated by the user, the command will be
/// executed. Upon completion or error of the execution signal, -endRefreshing
/// will be invoked.
@property (nonatomic, strong, nullable) RACCommand<__kindof UIRefreshControl *, id> *rac_command;

@end

NS_ASSUME_NONNULL_END
