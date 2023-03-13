//
//  TUIContactButtonCellData.h
//  TUIContact
//
//  Created by wyl on 2022/12/14.
//

#import <Foundation/Foundation.h>
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactButtonCellData_Minimalist : TUICommonCellData
@property (nonatomic, strong) NSString *title;
@property SEL cbuttonSelector;
@property TUIButtonStyle style;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) BOOL hideSeparatorLine;
@end

NS_ASSUME_NONNULL_END
