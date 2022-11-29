//
//  TUICommonTextCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import <UIKit/UIKit.h>
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonTextCellData : TUICommonCellData

@property NSString *key;
@property NSString *value;
@property BOOL showAccessory;
@property UIColor *keyColor;
@property UIColor *valueColor;
@property BOOL enableMultiLineValue;

@property (nonatomic, assign) UIEdgeInsets keyEdgeInsets;

@end

@interface TUICommonTextCell : TUICommonTableViewCell
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property (readonly) TUICommonTextCellData *textData;

- (void)fillWithData:(TUICommonTextCellData *)data;

@end

NS_ASSUME_NONNULL_END
