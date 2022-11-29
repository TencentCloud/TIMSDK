//
//  TUIReplyPreviewData_Minimalist.m
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//

#import "TUIReplyPreviewData_Minimalist.h"
#import "TUIDefine.h"

@implementation TUIReplyPreviewData_Minimalist

+ (NSString *)displayAbstract:(NSInteger)type abstract:(NSString *)abstract withFileName:(BOOL)withFilename
{
    NSString *text = abstract;
    if (type == V2TIM_ELEM_TYPE_IMAGE) {
        text = TUIKitLocalizableString(TUIkitMessageTypeImage);
    } else if (type == V2TIM_ELEM_TYPE_VIDEO) {
        text = TUIKitLocalizableString(TUIkitMessageTypeVideo);
    } else if (type == V2TIM_ELEM_TYPE_SOUND) {
        text = TUIKitLocalizableString(TUIKitMessageTypeVoice);
    } else if (type == V2TIM_ELEM_TYPE_FACE) {
        text = TUIKitLocalizableString(TUIKitMessageTypeAnimateEmoji);
    } else if (type == V2TIM_ELEM_TYPE_FILE) {
        if (withFilename) {
            text = [NSString stringWithFormat:@"%@%@", TUIKitLocalizableString(TUIkitMessageTypeFile), abstract];;
        } else {
            text = TUIKitLocalizableString(TUIkitMessageTypeFile);
        }
    }
    return text;
}

@end

@implementation TUIReferencePreviewData_Minimalist

@end
