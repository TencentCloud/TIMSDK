//
//  TUICustomerServicePluginDataProvider+CalculateSize.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/6/13.
//

#import "TUICustomerServicePluginDataProvider+CalculateSize.h"
#import <TUICore/TUIDefine.h>

@implementation TUICustomerServicePluginDataProvider (CalculateSize)

#pragma mark - Branch Cell
+ (CGSize)calcBranchCellSize:(NSString *)header items:(NSArray *)items {
    float topBottomMargin = TUICustomerServicePluginBranchCellMargin;
    float marginBetweenHeaderAndTableView = TUICustomerServicePluginBranchCellInnerMargin;
    float headerHeight = [TUICustomerServicePluginDataProvider calcBranchCellSizeOfHeader:header].height;
    float tableViewHeight = [TUICustomerServicePluginDataProvider calcBranchCellSizeOfTableView:items].height;
    return CGSizeMake(TUICustomerServicePluginBranchCellWidth,
                      headerHeight + tableViewHeight + topBottomMargin * 2 + marginBetweenHeaderAndTableView);
}

+ (CGSize)calcBranchCellSizeOfHeader:(NSString *)header {
    float leftRightMargin = TUICustomerServicePluginBranchCellMargin;
    CGRect rect = [header boundingRectWithSize:CGSizeMake(TUICustomerServicePluginBranchCellWidth - leftRightMargin * 2, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                                       context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

+ (CGSize)calcBranchCellSizeOfTableView:(NSArray *)items {
    CGFloat height = 0;
    for (int i = 0; i < items.count; i++) {
        height += [self calcBranchCellHeightOfTableView:items row:i];
    }
    return CGSizeMake(TUICustomerServicePluginBranchCellWidth, height);
}

+ (CGFloat)calcBranchCellHeightOfTableView:(NSArray *)items row:(NSInteger)row {
    if (row < 0 || row >= items.count) {
        return 0;
    }
    NSString *content = items[row];
    return [self calcBranchCellHeightOfContent:content];
}

+ (CGFloat)calcBranchCellHeightOfContent:(NSString *)content {
    float width = TUICustomerServicePluginBranchCellWidth - TUICustomerServicePluginBranchCellMargin * 2 - 5 - 6;
    CGRect rect = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                                        context:nil];
    return MAX(rect.size.height + 16, 36);
}

#pragma mark - Collection Cell
+ (CGSize)calcCollectionCellSize:(NSString *)header items:(NSArray *)items {
    float topBottomMargin = TUICustomerServicePluginBranchCellMargin;
    float marginBetweenHeaderAndTableView = TUICustomerServicePluginBranchCellInnerMargin;
    float headerHeight = [TUICustomerServicePluginDataProvider calcCollectionCellSizeOfHeader:header].height;
    float tableViewHeight = [TUICustomerServicePluginDataProvider calcCollectionCellSizeOfTableView:items].height;
    return CGSizeMake(TUICustomerServicePluginBranchCellWidth,
                      headerHeight + tableViewHeight + topBottomMargin * 2 + marginBetweenHeaderAndTableView);
}

+ (CGSize)calcCollectionCellSizeOfHeader:(NSString *)header {
    float leftRightMargin = TUICustomerServicePluginBranchCellMargin;
    float width = TUICustomerServicePluginBranchCellWidth - leftRightMargin * 2;
    CGRect rect = [header boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                                       context:nil];
    return CGSizeMake(width, rect.size.height);
}

+ (CGSize)calcCollectionCellSizeOfTableView:(NSArray *)items {
    CGFloat height = 0;
    for (int i = 0; i < items.count; i++) {
        height += [self calcCollectionCellHeightOfTableView:items row:i];
    }
    return CGSizeMake(TUICustomerServicePluginBranchCellWidth, height);
}

+ (CGFloat)calcCollectionCellHeightOfTableView:(NSArray *)items row:(NSInteger)row {
    if (row < 0 || row >= items.count) {
        return 0;
    }
    NSString *content = items[row];
    return [self calcBranchCellHeightOfContent:content];
}

+ (CGFloat)calcCollectionCellHeightOfContent:(NSString *)content {
    float width = TUICustomerServicePluginBranchCellWidth - TUICustomerServicePluginBranchCellMargin * 2;
    CGRect rect = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                                        context:nil];
    return MAX(rect.size.height + 16, 36);
}

#pragma mark - Collection input cell
+ (CGSize)calcCollectionInputCellSize:(NSString *)header {
    CGFloat headerHeight = [self calcCollectionInputCellSizeOfHeader:header].height;
    return CGSizeMake(TUICustomerServicePluginInputCellWidth, headerHeight + 20 + 6 + 36);
}

+ (CGSize)calcCollectionInputCellSizeOfHeader:(NSString *)header {
    float width = TUICustomerServicePluginInputCellWidth - TUICustomerServicePluginBranchCellMargin * 2;
    CGRect rect = [header boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                                       context:nil];
    return CGSizeMake(width, MAX(rect.size.height, 22));
}

#pragma mark - Evaluation cell
+ (CGSize)calcEvaluationCellSize:(NSString *)header
                            tail:(NSString *)tail
                           score:(NSInteger)score
                        selected:(BOOL)selected {
    float topLabelHeight = 20 + 20;
    float bubbleHeight = [self calcEvaluationBubbleSize:header score:score].height;
    float bottomHeight = 20;
    if (selected) {
        float height = [self calcEvaluationBubbleTailSize:tail].height;
        bottomHeight += height;
    }

    return CGSizeMake(Screen_Width, topLabelHeight + bubbleHeight + bottomHeight);
}

+ (CGSize)calcEvaluationBubbleSize:(NSString *)header score:(NSInteger)score {
    float width = TUICustomerServicePluginEvaluationBubbleWidth - TUICustomerServicePluginBranchCellMargin * 2;
    float headerHeight = [self calcEvaluationBubbleHeaderSize:header].height;
    float scoreHeight = [self calcEvaluationBubbleScoreSize:score].height;
    return CGSizeMake(width, 20 + headerHeight + 12 + scoreHeight + 12 + 30 + 20);
}

+ (CGSize)calcEvaluationBubbleHeaderSize:(NSString *)header {
    float width = TUICustomerServicePluginEvaluationBubbleWidth - TUICustomerServicePluginBranchCellMargin * 2;
    CGRect rect = [header boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12] }
                                       context:nil];
    return rect.size;
}

+ (CGSize)calcEvaluationBubbleScoreSize:(NSInteger)score {
    float width = TUICustomerServicePluginEvaluationBubbleWidth - TUICustomerServicePluginBranchCellMargin * 2;
    return CGSizeMake(width, score <= 5 ? 24 : 24 * 2 + 15);
}

+ (CGSize)calcEvaluationBubbleTailSize:(NSString *)tail {
    float width = Screen_Width - 52 * 2;
    CGRect rect = [tail boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12] }
                              context:nil];
    return CGSizeMake(width, rect.size.height + 20);
}

#pragma mark - Card cell
+ (CGSize)calcCardHeaderSize:(NSString *)header {
    float width = TUICustomerServicePluginCardBubbleWidth - 120;
    CGRect rect = [header boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12] }
                              context:nil];
    return CGSizeMake(width, rect.size.height);
}

#pragma mark - Menu button
+ (CGSize)calcMenuCellSize:(NSString *)title {
    CGSize size = [self calcMenuCellButtonSize:title];
    return CGSizeMake(size.width + 12, size.height + 8 + 6);
}

+ (CGSize)calcMenuCellButtonSize:(NSString *)title {
    CGFloat margin = 28;
    CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 32)
                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14] }
                                      context:nil];
    return CGSizeMake(rect.size.width + margin, 32);
}

@end
