//
//  TUIGroupTypeListController.h
//  TUIContact
//
//  Created by wyl on 2022/8/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupTypeListController : UIViewController

@property (nonatomic, copy) void (^selectCallBack)(NSString *groupType);


@end

NS_ASSUME_NONNULL_END
