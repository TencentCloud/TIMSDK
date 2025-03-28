//
//  TUIReactPreview_Minimalist.h
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/11/29.
//

#import <UIKit/UIKit.h>
#import <TIMCommon/TUIMessageCell.h>
@class TUIReactModel;
NS_ASSUME_NONNULL_BEGIN

@interface TUIReactPreview_Minimalist : UIView
@property(nonatomic, strong) NSMutableArray<TUIReactModel *> *reactlistArr;
@property(nonatomic, weak) TUIMessageCell *delegateCell;
@property(nonatomic, copy) void (^emojiClickCallback)(TUIReactModel *model);
- (void)refreshByArray:(NSMutableArray *)tagsArray;
- (void)updateView;
- (void)notifyReactionChanged;
@end

NS_ASSUME_NONNULL_END
