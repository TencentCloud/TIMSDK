//
//  TUIInputPreviewBar.h
//  TUIChat
//
//  Created by harvy on 2021/11/9.
//

#import <UIKit/UIKit.h>
#import "TUIReplyPreviewData_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN


@interface TUIReplyPreviewBar_Minimalist : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, copy) TUIInputPreviewBarCallback onClose;

@property (nonatomic, strong) TUIReplyPreviewData_Minimalist *previewData;
@property (nonatomic, strong) TUIReferencePreviewData_Minimalist *previewReferenceData;


@end

@interface TUIReferencePreviewBar_Minimalist : TUIReplyPreviewBar_Minimalist
@end
NS_ASSUME_NONNULL_END
