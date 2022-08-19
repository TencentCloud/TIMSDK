//
//  TUIFindContactCellModel.h
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//

#import <Foundation/Foundation.h>
@class V2TIMUserFullInfo;
@class V2TIMGroupInfo;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIFindContactType) {
    TUIFindContactTypeC2C   =  1,
    TUIFindContactTypeGroup =  2,
};

@class TUIFindContactCellModel;
typedef void(^TUIFindContactOnCallback)(TUIFindContactCellModel *);

@interface TUIFindContactCellModel : NSObject

@property (nonatomic, assign) TUIFindContactType type;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, copy) NSString *mainTitle;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *desc;

/**
 * c2c-> userID,  group就是群ID
 * If the conversation type is c2c, contactID represents userid; if the conversation type is group, contactID represents groupID
 */
@property (nonatomic, copy) NSString *contactID;
@property (nonatomic, strong) V2TIMUserFullInfo *userInfo;
@property (nonatomic, strong) V2TIMGroupInfo *groupInfo;

@property (nonatomic, copy) TUIFindContactOnCallback onClick;

@end

NS_ASSUME_NONNULL_END
