//
//  TUIChatPopRecentView.h
//  TUIChat
//
//  Created by wyl on 2022/5/25.
//

#import <UIKit/UIKit.h>

@class  TUIChatPopRecentView;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIChatPopRecentEmojiDelegate <NSObject>

- (void)popRecentViewClickArrow:(TUIChatPopRecentView *)faceView;
- (void)popRecentViewClickface:(TUIChatPopRecentView *)faceView tag:(NSInteger)tag;

@end

@interface TUIChatPopRecentView : UIView

@property (nonatomic, strong, readonly) NSMutableArray *faceGroups;
@property (nonatomic, assign) BOOL needShowbottomLine;
@property (nonatomic, strong) UIButton *arrowButton;

- (void)setData:(NSMutableArray *)data;

@property (nonatomic, weak) id<TUIChatPopRecentEmojiDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
