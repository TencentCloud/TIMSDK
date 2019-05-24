//
//  TContactsController.h
//  TUIKit
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TContactController : UIViewController

@property (nonatomic) TContactViewModel *viewModel;

- (void)didSelectContactCell:(TCommonContactCell *)cell;

@end

NS_ASSUME_NONNULL_END
