//
//  TUIGroupButtonCellData_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/4.
//

#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupButtonCellData_Minimalist : TUICommonCellData
@property (nonatomic, strong) NSString *title;
@property SEL cbuttonSelector;
@property TUIButtonStyle style;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) BOOL hideSeparatorLine;
@property (nonatomic, assign) BOOL isInfoPageLeftButton;
@end

NS_ASSUME_NONNULL_END
