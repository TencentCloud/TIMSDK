//
//  TUIInputPreviewBar.h
//  TUIChat
//
//  Created by harvy on 2021/11/9.
//

#import <UIKit/UIKit.h>
#import "TUIReplyPreviewData.h"
NS_ASSUME_NONNULL_BEGIN


@interface TUIReplyPreviewBar : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, copy) TUIInputPreviewBarCallback onClose;

@property (nonatomic, strong) TUIReplyPreviewData *previewData;

@end

NS_ASSUME_NONNULL_END
