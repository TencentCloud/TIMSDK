//
//  TCommonCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCommonCellData : NSObject
@property (nonatomic, assign) SEL cselector;
@end

@interface TCommonTableViewCell : UITableViewCell

@property (readonly) TCommonCellData *data;

- (void)fillWithData:(TCommonCellData *)data;

@end

NS_ASSUME_NONNULL_END
