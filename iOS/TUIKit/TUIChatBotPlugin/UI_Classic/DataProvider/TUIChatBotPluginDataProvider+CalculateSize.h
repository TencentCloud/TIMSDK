//
//  TUIChatBotPluginDataProvider+CalculateSize.h
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIChatBotPluginDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

#define TUIChatBotPluginBranchCellWidth (0.65 * Screen_Width)
#define TUIChatBotPluginBranchCellMargin 12
#define TUIChatBotPluginBranchCellInnerMargin 8

@interface TUIChatBotPluginDataProvider (CalculateSize)

+ (CGSize)calcBranchCellSize:(NSString *)header items:(NSArray *)items;
+ (CGSize)calcBranchCellSizeOfHeader:(NSString *)header;
+ (CGSize)calcBranchCellSizeOfTableView:(NSArray *)items;
+ (CGFloat)calcBranchCellHeightOfTableView:(NSArray *)items row:(NSInteger)row;
+ (CGFloat)calcBranchCellHeightOfContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
