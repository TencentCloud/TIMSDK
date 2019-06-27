//
//  TUIMessageCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TCommonCell.h"
#import "TUIMessageCellLayout.h"
@import ImSDK;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDownloadProgress)(NSInteger curSize, NSInteger totalSize);
typedef void (^TDownloadResponse)(int code, NSString *desc, NSString *path);


typedef NS_ENUM(NSUInteger, TMsgStatus) {
    Msg_Status_Init,
    Msg_Status_Sending,
    Msg_Status_Sending_2,
    Msg_Status_Succ,
    Msg_Status_Fail,
};

typedef NS_ENUM(NSUInteger, TMsgDirection) {
    MsgDirectionIncoming,
    MsgDirectionOutgoing,
};

@interface TUIMessageCellData : TCommonCellData

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL showName;
@property TMsgDirection direction;
@property (nonatomic, assign) TMsgStatus status;
@property (nonatomic, strong) TIMMessage *innerMessage;
@property UIFont *nameFont;
@property UIColor *nameColor;

@property (nonatomic, class) UIColor *outgoingNameColor;
@property (nonatomic, class) UIFont *outgoingNameFont;
@property (nonatomic, class) UIColor *incommingNameColor;
@property (nonatomic, class) UIFont *incommingNameFont;

@property TUIMessageCellLayout *cellLayout;

- (CGSize)contentSize;

- (instancetype)initWithDirection:(TMsgDirection)direction;

@end

NS_ASSUME_NONNULL_END
