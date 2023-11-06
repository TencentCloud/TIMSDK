//
//  TUICustomerServicePluginDataProvider+CalculateSize.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/6/13.
//

#import "TUICustomerServicePluginDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

#define TUICustomerServicePluginBranchCellWidth (0.65 * Screen_Width)
#define TUICustomerServicePluginBranchCellMargin 12
#define TUICustomerServicePluginBranchCellInnerMargin 8
#define TUICustomerServicePluginInputCellWidth (0.69 * Screen_Width)
#define TUICustomerServicePluginEvaluationBubbleWidth (0.67 * Screen_Width)
#define TUICustomerServicePluginCardBubbleWidth (0.65 * Screen_Width)

@interface TUICustomerServicePluginDataProvider (CalculateSize)

+ (CGSize)calcBranchCellSize:(NSString *)header items:(NSArray *)items;
+ (CGSize)calcBranchCellSizeOfHeader:(NSString *)header;
+ (CGSize)calcBranchCellSizeOfTableView:(NSArray *)items;
+ (CGFloat)calcBranchCellHeightOfTableView:(NSArray *)items row:(NSInteger)row;
+ (CGFloat)calcBranchCellHeightOfContent:(NSString *)content;

+ (CGSize)calcCollectionCellSize:(NSString *)header items:(NSArray *)items;
+ (CGSize)calcCollectionCellSizeOfHeader:(NSString *)header;
+ (CGSize)calcCollectionCellSizeOfTableView:(NSArray *)items;
+ (CGFloat)calcCollectionCellHeightOfTableView:(NSArray *)items row:(NSInteger)row;
+ (CGFloat)calcCollectionCellHeightOfContent:(NSString *)content;

+ (CGSize)calcCollectionInputCellSize:(NSString *)header;
+ (CGSize)calcCollectionInputCellSizeOfHeader:(NSString *)header;

+ (CGSize)calcEvaluationCellSize:(NSString *)header
                            tail:(NSString *)tail
                           score:(NSInteger)score
                        selected:(BOOL)selected;
+ (CGSize)calcEvaluationBubbleSize:(NSString *)header score:(NSInteger)score;
+ (CGSize)calcEvaluationBubbleHeaderSize:(NSString *)header;
+ (CGSize)calcEvaluationBubbleScoreSize:(NSInteger)score;
+ (CGSize)calcEvaluationBubbleTailSize:(NSString *)tail;

+ (CGSize)calcCardHeaderSize:(NSString *)header;

+ (CGSize)calcMenuCellSize:(NSString *)title;
+ (CGSize)calcMenuCellButtonSize:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
