//
//  TCommonCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCommonCellData : NSObject
@property (strong) NSString *reuseId;
@property (nonatomic, assign) SEL cselector;
- (CGFloat)heightOfWidth:(CGFloat)width;
@end

@interface TCommonTableViewCell : UITableViewCell

@property (readonly) TCommonCellData *data;
@property UIColor *colorWhenTouched;
@property BOOL changeColorWhenTouched;

- (void)fillWithData:(TCommonCellData *)data;

@end

NS_ASSUME_NONNULL_END
