//
//  TUIReactPreview.m
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReactPreview.h"
#import "TUIReactPreviewCell.h"
#import "TUIReactModel.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TUIMessageCell.h>
#import <TUICore/TUICore.h>

@interface TUIReactPreview ()

@end

@implementation TUIReactPreview

#pragma mark - View init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){

    }
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
     * Margin, including top、bottom、left and right
     */
    CGFloat margin = 12;
    CGFloat rightmargin = 12;
    CGFloat topMargin = 3;
    CGFloat bottomMargin = 3;

    /**
     * Padding in the horizontal direction
     */
    CGFloat padding = 6;

    /**
     * Padding in the vertical direction
     */
    CGFloat verticalPadding = 8;

    /**
     * Size of tagview
     */
    CGFloat tagViewWidth = 0;
    CGFloat tagViewHeight = 0;
    int index = 0;
    TUIReactPreviewCell *preCell = nil;
    for (TUIReactModel *model in self.listArrM) {
        TUIReactPreviewCell *cell = [[TUIReactPreviewCell alloc] initWithFrame:CGRectZero];
        cell.tag = index;
        cell.model = model;
        [self addSubview:cell];

        if (index == 0) {
            cell.frame = CGRectMake(margin, topMargin, cell.ItemWidth, 24);
            tagViewWidth = cell.ItemWidth;
            tagViewHeight = 24;
            if (self.listArrM.count == 1) {
                /**
                 * If  there is only one tag
                 */
                tagViewWidth = margin + cell.frame.size.width + rightmargin;
                tagViewHeight = cell.frame.origin.y + cell.frame.size.height + bottomMargin;
            }
        } else {
            CGFloat previousFrameRightPoint = preCell.frame.origin.x + preCell.frame.size.width;

            /**
             * Placed in the current line, the width required after layout
             */
            CGFloat needWidth = (padding + cell.ItemWidth);
            CGFloat residueWidth = (MaxTagSize - previousFrameRightPoint - rightmargin);
            BOOL condation = (needWidth < residueWidth);
            if (condation) {
                /**
                 * Placed it in the same line if has enough space
                 */
                cell.frame = CGRectMake(previousFrameRightPoint + padding, preCell.frame.origin.y, cell.ItemWidth, 24);
            } else {
                /**
                 * Placed it in the another line if not enough space
                 */
                cell.frame = CGRectMake(margin, preCell.frame.origin.y + preCell.frame.size.height + verticalPadding, cell.ItemWidth, 24);
            }

            CGFloat curretLineMaxWidth = MAX(previousFrameRightPoint + rightmargin, cell.frame.origin.x + cell.frame.size.width + rightmargin);
            tagViewWidth = MAX(curretLineMaxWidth, tagViewWidth);
            tagViewHeight = cell.frame.origin.y + cell.frame.size.height + bottomMargin;
        }

        __weak typeof(self) weakSelf = self;
        cell.emojiClickCallback = ^(TUIReactModel *_Nonnull model) {
          NSLog(@"model.emojiKey click : %@", model.emojiKey);
          __strong typeof(weakSelf) strongSelf = weakSelf;
          if (strongSelf.emojiClickCallback) {
              strongSelf.emojiClickCallback(model);
          }
        };

        cell.userClickCallback = ^(TUIReactModel *_Nonnull model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.userClickCallback) {
                strongSelf.userClickCallback(model);
            }
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

- (void)notifyReactionChanged {
    NSDictionary *param = @{TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data : self.delegateCell.messageData,
                            TUICore_TUIPluginNotify_DidChangePluginViewSubKey_VC : self,
                            TUICore_TUIPluginNotify_DidChangePluginViewSubKey_isAllowScroll2Bottom: @"0"};
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                  object:nil
                   param:param];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // tell constraints they need updating
        [self setNeedsUpdateConstraints];

        // update constraints now so we can animate the change
        [self updateConstraintsIfNeeded];

        [self layoutIfNeeded];
    });
}

- (void)refreshByArray:(NSMutableArray *)tagsArray {
    if (tagsArray && tagsArray.count > 0) {
        self.listArrM = [NSMutableArray arrayWithArray:tagsArray];
        [UIView animateWithDuration:1 animations:^{
            [self updateView];
        }completion:^(BOOL finished) {
            
        }];
        self.delegateCell.messageData.messageContainerAppendSize = self.frame.size;
        [self notifyReactionChanged];
    }
    else {
        self.listArrM = [NSMutableArray array];
        [UIView animateWithDuration:1 animations:^{
            [self updateView];
        }completion:^(BOOL finished) {
            
        }];
        self.delegateCell.messageData.messageContainerAppendSize = CGSizeZero;
        [self notifyReactionChanged];
    }
}
@end
