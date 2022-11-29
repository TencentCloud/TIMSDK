//
//  TUIFindContactViewController.h
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//

#import <UIKit/UIKit.h>
#import "TUIFindContactCellModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIFindContactViewControllerCallback_Minimalist)(TUIFindContactCellModel *);


@interface TUIFindContactViewController_Minimalist : UIViewController

@property (nonatomic, assign) TUIFindContactType type;

@property (nonatomic, copy) TUIFindContactViewControllerCallback_Minimalist onSelect;

@end

NS_ASSUME_NONNULL_END
