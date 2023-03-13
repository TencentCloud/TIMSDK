//
//  TUISearchResultHeaderFooterView.h
//  Pods
//
//  Created by harvy on 2020/12/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultHeaderFooterView_Minimalist : UITableViewHeaderFooterView

@property (nonatomic, assign) BOOL isFooter;
@property (nonatomic, assign) BOOL showMoreBtn;
@property (nonatomic, copy) NSString * __nullable title;
@property (nonatomic, copy) dispatch_block_t __nullable onTap;

@end


@interface TUISearchChatHistoryResultHeaderView_Minimalist : UITableViewHeaderFooterView
@property (nonatomic, copy) NSString * __nullable title;
@property (nonatomic, copy) dispatch_block_t __nullable onTap;

- (void)configPlaceHolderImage:(UIImage *)img imgUrl:(NSString *)imgurl Text:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
