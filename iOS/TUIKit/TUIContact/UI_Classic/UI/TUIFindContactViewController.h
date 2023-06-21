//
//  TUIFindContactViewController.h
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIFindContactCellModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIFindContactViewControllerCallback)(TUIFindContactCellModel *);

@interface TUIFindContactViewController : UIViewController

@property(nonatomic, assign) TUIFindContactType type;

@property(nonatomic, copy) TUIFindContactViewControllerCallback onSelect;

@end

NS_ASSUME_NONNULL_END
