//
//  TUITagsView.m
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITagsView.h"
#import "TUITagsCell.h"
#import "TUITagsModel.h"

@interface TUITagsView ()

@end

@implementation TUITagsView

#pragma mark - View init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}
- (NSMutableArray *)listArrM {
    if (!_listArrM) {
        _listArrM = [NSMutableArray arrayWithCapacity:3];
    }
    return _listArrM;
}

- (void)updateView {
    for (UIView *subView in self.subviews) {
        if (subView) {
            [subView removeFromSuperview];
        }
    }
    if (self.listArrM.count <= 0) {
        return;
    }

    /**
     * 外边距 （上下左右）
     * Margin, including top、bottom、left and right
     */
    CGFloat margin = 12;
    CGFloat rightmargin = 12;
    CGFloat topMargin = 3;
    CGFloat bottomMargin = 3;

    /**
     * 水平内边距
     * Padding in the horizontal direction
     */
    CGFloat padding = 6;

    /**
     * 垂直内边距
     * Padding in the vertical direction
     */
    CGFloat verticalPadding = 8;

    /**
     * TagView 的宽高
     * Size of tagview
     */
    CGFloat tagViewWidth = 0;
    CGFloat tagViewHeight = 0;
    int index = 0;
    TUITagsCell *preCell = nil;
    for (TUITagsModel *model in self.listArrM) {
        TUITagsCell *cell = [[TUITagsCell alloc] initWithFrame:CGRectZero];
        cell.tag = index;
        cell.model = model;
        [self addSubview:cell];

        if (index == 0) {
            cell.frame = CGRectMake(margin, topMargin, cell.ItemWidth, 24);
            tagViewWidth = cell.ItemWidth;
            tagViewHeight = 24;
            if (self.listArrM.count == 1) {
                /**
                 * 总共就一个
                 * If  there is only one tag
                 */
                tagViewWidth = margin + cell.frame.size.width + rightmargin;
                tagViewHeight = cell.frame.origin.y + cell.frame.size.height + bottomMargin;
            }
        } else {
            CGFloat previousFrameRightPoint = preCell.frame.origin.x + preCell.frame.size.width;

            /**
             * 放置在当前行，布局后需要的宽度
             * Placed in the current line, the width required after layout
             */
            CGFloat needWidth = (padding + cell.ItemWidth);
            CGFloat residueWidth = (MaxTagSize - previousFrameRightPoint - rightmargin);
            BOOL condation = (needWidth < residueWidth);
            if (condation) {
                /**
                 * 这行还能放下 那就放
                 * Placed it in the same line if has enough space
                 */
                cell.frame = CGRectMake(previousFrameRightPoint + padding, preCell.frame.origin.y, cell.ItemWidth, 24);
            } else {
                /**
                 * 放不下新起一行
                 * Placed it in the another line if not enough space
                 */
                cell.frame = CGRectMake(margin, preCell.frame.origin.y + preCell.frame.size.height + verticalPadding, cell.ItemWidth, 24);
            }

            CGFloat curretLineMaxWidth = MAX(previousFrameRightPoint + rightmargin, cell.frame.origin.x + cell.frame.size.width + rightmargin);
            tagViewWidth = MAX(curretLineMaxWidth, tagViewWidth);
            tagViewHeight = cell.frame.origin.y + cell.frame.size.height + bottomMargin;
        }

        __weak typeof(self) weakSelf = self;
        cell.emojiClickCallback = ^(TUITagsModel *_Nonnull model) {
          NSLog(@"model.emojiKey click : %@", model.emojiKey);
          __strong typeof(weakSelf) strongSelf = weakSelf;
          if (strongSelf.emojiClickCallback) {
              strongSelf.emojiClickCallback(model);
          }
        };

        cell.userClickCallback = ^(TUITagsModel *_Nonnull model, NSInteger btnTagIndex) {
          NSLog(@"usermodel click name: %@   id: %@", model.followUserNames[btnTagIndex], model.followIDs[btnTagIndex]);
        };

        preCell = cell;
        index++;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, tagViewWidth, tagViewHeight);
}

- (void)updateRTLView {
    for (UIView *subView in self.subviews) {
        if (subView) {
            [subView resetFrameToFitRTL];
        }
    }
}

@end
