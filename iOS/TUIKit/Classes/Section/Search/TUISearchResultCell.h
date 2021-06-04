//
//  TUISearchResultCell.h
//  Pods
//
//  Created by harvy on 2020/12/24.
//

#import <UIKit/UIKit.h>
@class TUISearchResultCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultCell : UITableViewCell
- (void)fillWithData:(TUISearchResultCellModel *)cellModel;
@end

NS_ASSUME_NONNULL_END
