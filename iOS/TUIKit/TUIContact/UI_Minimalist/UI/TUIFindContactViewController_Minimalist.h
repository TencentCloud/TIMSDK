//
//  TUIFindContactViewController.h
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//

#import <UIKit/UIKit.h>
#import "TUIFindContactCellModel_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIFindContactViewControllerCallback_Minimalist)(TUIFindContactCellModel_Minimalist *);


@interface TUIFindContactViewController_Minimalist : UIViewController

@property (nonatomic, assign) TUIFindContactType_Minimalist type;

@property (nonatomic, copy) TUIFindContactViewControllerCallback_Minimalist onSelect;

@end

NS_ASSUME_NONNULL_END
