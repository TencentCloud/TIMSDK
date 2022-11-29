//
//  TUIGroupNoticeController.h
//  TUIGroup
//
//  Created by harvy on 2022/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupNoticeController : UIViewController

@property (nonatomic, copy) dispatch_block_t onNoticeChanged;
@property (nonatomic, copy) NSString *groupID;
@end

NS_ASSUME_NONNULL_END
