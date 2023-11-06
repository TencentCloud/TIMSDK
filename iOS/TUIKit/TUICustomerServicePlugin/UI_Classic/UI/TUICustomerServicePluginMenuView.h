//
//  TUICustomerServicePluginMenuView.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/6/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginMenuCellData : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) SEL cselector;
@property (nonatomic, strong) id target;

- (CGSize)calcSize;

@end


@interface TUICustomerServicePluginMenuCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) TUICustomerServicePluginMenuCellData *cellData;

@end


@interface TUICustomerServicePluginMenuView : UIView

- (instancetype)initWithDataSource:(NSArray *)source;
- (void)updateFrame;

@end

NS_ASSUME_NONNULL_END
