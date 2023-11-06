//
//  TUICustomerServicePluginCardInputView.h
//  Masonry
//
//  Created by xia on 2023/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginCardInputItemCell : UITableViewCell

@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UITextField *inputTextField;

@end


@interface TUICustomerServicePluginCardInputView : UIView

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UITableView *itemsTableView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *closeButton;

@end

NS_ASSUME_NONNULL_END
