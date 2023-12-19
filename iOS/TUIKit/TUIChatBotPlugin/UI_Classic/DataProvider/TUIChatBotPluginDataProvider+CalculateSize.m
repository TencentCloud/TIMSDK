//
//  TUIChatBotPluginDataProvider+CalculateSize.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIChatBotPluginDataProvider+CalculateSize.h"
#import <TUICore/TUIDefine.h>

@implementation TUIChatBotPluginDataProvider (CalculateSize)

#pragma mark - Branch Cell
+ (CGSize)calcBranchCellSize:(NSString *)header items:(NSArray *)items {
    float topBottomMargin = TUIChatBotPluginBranchCellMargin;
    float marginBetweenHeaderAndTableView = TUIChatBotPluginBranchCellInnerMargin;
    float headerHeight = [TUIChatBotPluginDataProvider calcBranchCellSizeOfHeader:header].height;
    float tableViewHeight = [TUIChatBotPluginDataProvider calcBranchCellSizeOfTableView:items].height;
    return CGSizeMake(TUIChatBotPluginBranchCellWidth,
                      headerHeight + tableViewHeight + topBottomMargin * 2 + marginBetweenHeaderAndTableView);
}

+ (CGSize)calcBranchCellSizeOfHeader:(NSString *)header {
    float leftRightMargin = TUIChatBotPluginBranchCellMargin;
    CGRect rect = [header boundingRectWithSize:CGSizeMake(TUIChatBotPluginBranchCellWidth - leftRightMargin * 2, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                                       context:nil];
    return CGSizeMake(TUIChatBotPluginBranchCellWidth, rect.size.height);
}

+ (CGSize)calcBranchCellSizeOfTableView:(NSArray *)items {
    CGFloat height = 0;
    for (int i = 0; i < items.count; i++) {
        height += [self calcBranchCellHeightOfTableView:items row:i];
    }
    return CGSizeMake(TUIChatBotPluginBranchCellWidth, height);
}

+ (CGFloat)calcBranchCellHeightOfTableView:(NSArray *)items row:(NSInteger)row {
    if (row < 0 || row >= items.count) {
        return 0;
    }
    NSString *content = items[row];
    return [self calcBranchCellHeightOfContent:content];
}

+ (CGFloat)calcBranchCellHeightOfContent:(NSString *)content {
    float width = TUIChatBotPluginBranchCellWidth - TUIChatBotPluginBranchCellMargin * 2 - 5 - 6;
    CGRect rect = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                                        context:nil];
    return MAX(rect.size.height + 16, 36);
}
@end
