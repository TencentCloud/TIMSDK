//
//  TCommonCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//

#import <UIKit/UIKit.h>
#import "TUIDarkModel.h"

@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN
/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIUserFullInfo
//
/////////////////////////////////////////////////////////////////////////////////
@interface V2TIMUserFullInfo (TUIUserFullInfo)
- (NSString *)showName;
- (NSString *)showGender;
- (NSString *)showSignature;
- (NSString *)showAllowType;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIUserModel
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIUserModel : NSObject<NSCopying>
@property(nonatomic,copy) NSString *userId;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *avatar;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIScrollView
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIScrollView : UIScrollView
@property (strong, nonatomic) UIImageView *imageView;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIPopView
//
/////////////////////////////////////////////////////////////////////////////////
@class TUIPopView;
@protocol TUIPopViewDelegate <NSObject>
- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index;
@end

@interface TUIPopView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGPoint arrowPoint;
@property (nonatomic, weak) id<TUIPopViewDelegate> delegate;
- (void)setData:(NSMutableArray *)data;
- (void)showInWindow:(UIWindow *)window;
@end

@interface TUIPopCellData : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@end

@interface TUIPopCell : UITableViewCell
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *title;
+ (CGFloat)getHeight;
- (void)setData:(TUIPopCellData *)data;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIModifyView
//
/////////////////////////////////////////////////////////////////////////////////
@class TUIModifyView;
@protocol TUIModifyViewDelegate <NSObject>
- (void)modifyView:(TUIModifyView *)modifyView didModiyContent:(NSString *)content;
@end

@interface TUIModifyViewData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) BOOL enableNull;
@end

@interface TUIModifyView : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UITextField *content;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *confirm;
@property (nonatomic, strong) UIView *hLine;
@property (nonatomic, weak) id<TUIModifyViewDelegate> delegate;
- (void)setData:(TUIModifyViewData *)data;
- (void)showInWindow:(UIWindow *)window;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUINaviBarIndicatorView
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUINaviBarIndicatorView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UILabel *label;

- (void)setTitle:(NSString *)title;

- (void)startAnimating;

- (void)stopAnimating;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUICommonCell & data
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUICommonCellData : NSObject
@property (strong) NSString *reuseId;
@property (nonatomic, assign) SEL cselector;
@property (nonatomic, strong) NSDictionary *ext;
- (CGFloat)heightOfWidth:(CGFloat)width;
- (CGFloat)estimatedHeight;
@end

@interface TUICommonTableViewCell : UITableViewCell

@property (readonly) TUICommonCellData *data;
@property UIColor *colorWhenTouched;
@property BOOL changeColorWhenTouched;

- (void)fillWithData:(TUICommonCellData *)data;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUICommonTextCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUICommonTextCellData : TUICommonCellData

@property NSString *key;
@property NSString *value;
@property BOOL showAccessory;
@property UIColor *keyColor;
@property UIColor *valueColor;
@property BOOL enableMultiLineValue;

@property (nonatomic, assign) UIEdgeInsets keyEdgeInsets;

@end

@interface TUICommonTextCell : TUICommonTableViewCell
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property (readonly) TUICommonTextCellData *textData;

- (void)fillWithData:(TUICommonTextCellData *)data;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUICommonSwitchCell & data
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUICommonSwitchCellData : TUICommonCellData

@property NSString *title;
@property NSString *desc;
@property (getter=isOn) BOOL on;
@property CGFloat margin;
@property SEL cswitchSelector;

@property (nonatomic,assign) BOOL displaySeparatorLine;

@property (nonatomic,assign) BOOL disableChecked;

@end

@interface TUICommonSwitchCell : TUICommonTableViewCell
@property UILabel *titleLabel; // main title label
@property UILabel *descLabel; // detail title label below the main title label, used for explaining details
@property UISwitch *switcher;

@property (readonly) TUICommonSwitchCellData *switchData;

- (void)fillWithData:(TUICommonSwitchCellData *)data;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIButtonCell & data
//
/////////////////////////////////////////////////////////////////////////////////
typedef enum : NSUInteger {
    ButtonGreen,
    ButtonWhite,
    ButtonRedText,
    ButtonBule,
} TUIButtonStyle;

@interface TUIButtonCellData : TUICommonCellData
@property (nonatomic, strong) NSString *title;
@property SEL cbuttonSelector;
@property TUIButtonStyle style;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) BOOL hideSeparatorLine;
@end

@interface TUIButtonCell : TUICommonTableViewCell
@property (nonatomic, strong) UIButton *button;
@property TUIButtonCellData *buttonData;

- (void)fillWithData:(TUIButtonCellData *)data;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIGroupPendencyCell & data
//
/////////////////////////////////////////////////////////////////////////////////
#define TUIGroupPendencyCellData_onPendencyChanged @"TUIGroupPendencyCellData_onPendencyChanged"

@interface TUIGroupPendencyCellData : TUICommonCellData

@property(nonatomic,strong) NSString* groupId;

@property(nonatomic,strong) NSString* fromUser;

@property(nonatomic,strong) NSString* toUser;

@property (readonly) V2TIMGroupApplication *pendencyItem;

@property NSURL *avatarUrl;

@property NSString *title;

/**
 *  请求者的加群简介。如“小明申请加入群聊”。
 *  The joining group introduction of the requester. Such as "Xiao Ming applied to join the group".
 */
@property NSString *requestMsg;

/**
 *  是否同意。YES：同意。
 *  此变量为 NO时，仅表明当前请求未同意，并不意味着请求已拒绝。
 *
 *  Agree or Not
 *  YES: Agree;  NO: Indicates that the current request was not granted, but does not mean that the request has been denied.
 */
@property BOOL isAccepted;

/**
 *  是否拒绝。YES：拒绝。
 *  此变量为 NO时，仅表明当前请求未拒绝，并不意味着请求已同意。
 *
 *  Refuse or Not
 *  YES: Refuse; NO: Indicates that the current request is not denied, but does not mean that the request has been granted.
 */
@property BOOL isRejectd;
@property SEL cbuttonSelector;


- (instancetype)initWithPendency:(V2TIMGroupApplication *)args;


- (void)accept;
- (void)reject;

@end

@interface TUIGroupPendencyCell : TUICommonTableViewCell

@property UIImageView *avatarView;

@property UILabel *titleLabel;

@property UILabel *addWordingLabel;

@property UIButton *agreeButton;

@property TUIGroupPendencyCellData *pendencyData;

- (void)fillWithData:(TUIGroupPendencyCellData *)pendencyData;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIFaceCell & data
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIFaceCellData
 * 【功能说明】存储表情的名称、本地存储路径。
 *
 *
 * 【Module name】 TUIFaceCellData
 * 【Function description]】The name and local storage path of the stored emoticon.
 */
@interface TUIFaceCellData : NSObject

/**
 * 表情名称
 * The name of emoticon
 */
@property (nonatomic, strong) NSString *name;

/**
 * 表情的本地化名称（国际化属性，如果为空或者length为0，默认显示name）
 * The localized name of the emoticon (the attribute used for internationalization, if it is empty or the length is 0, the name is displayed by default)
 */
@property (nonatomic, copy) NSString *localizableName;

/**
 * 表情在本地缓存的存储路径。
 * The storage path of the emoticon cached locally.
 */
@property (nonatomic, strong) NSString *path;
@end

/**
 * 【模块名称】TUIFaceCell
 * 【功能说明】存储表情的图像，并根据 TUIFaceCellData 初始化 Cell。
 *  在表情视图中，TUIFaceCell 即为界面显示的单元。
 *
 *
 * 【Module name】TUIFaceCell
 * 【Function description】 Store the image of the emoticon, and initialize the Cell according to TUIFaceCellData.
 *  In the emoticon view, TUIFaceCell is the unit displayed on the interface.
 */
@interface TUIFaceCell : UICollectionViewCell

/**
 *  表情图像
 *  The image view for displaying emoticon
 */
@property (nonatomic, strong) UIImageView *face;


- (void)setData:(TUIFaceCellData *)data;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIFaceGroup
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIFaceGroup
 * 【功能说明】用于实现表情的分组，方便用户在不同表情主题下浏览、选择。
 *  该类存储了每组表情分组的自身标号，方便 FaceView 能够定位到每个表情分组。
 *  同时，该类存储了一个表情组下的表情路径，并提供数据如行数、每行表情数等用于精确在组内定位表情。
 *
 *
 * 【Module name】 TUIFaceGroup
 * 【Function description】 It is used to realize the grouping of emoticon, which is convenient for users to browse and select under different emoticon themes.
 *  This class stores the index of each emoticon group, so that FaceView can locate each emoticon group.
 *  At the same time, this class stores the path of all emoticon pictures in an emoticon group, and provides data such as the number of lines, the number of emoticons in each line, etc., to locate specific emoticons
 */
@interface TUIFaceGroup : NSObject

/**
 *  表情组索引号，从0开始。
 *  Index of emoticons group, begining with zero.
 */
@property (nonatomic, assign) int groupIndex;

/**
 *  表情组路径
 *  The resource path of the entire expression group
 */
@property (nonatomic, strong) NSString *groupPath;

/**
 *  表情组总行数
 *  The number of lines of emoticons in the emoticon group
 */
@property (nonatomic, assign) int rowCount;

/**
 *  每行所包含的表情数
 *  The number of emoticons contained in each line
 */
@property (nonatomic, assign) int itemCountPerRow;

@property (nonatomic, strong) NSMutableArray *faces;

/**
 *  删除标志位
 *  当该位为 YES 时，FaceView 会在表情视图右下角中显示一个“删除”图标，使您无需呼出键盘即可进行表情的删除操作。
 *
 *  The flag of indicating whether to display the delete button
 *  When set to YES, FaceView will display a "delete" icon in the lower right corner of the emoticon view. Clicking the icon can delete the entered emoticon directly without evoking the keyboard.
 */
@property (nonatomic, assign) BOOL needBackDelete;

/**
 *  表情menu路径
 *  表情菜单即在表情视图最下方显示表情组缩略图与“发送按钮”的菜单视图。
 *
 *  The path to the cover image of the emoticon group
 */
@property (nonatomic, strong) NSString *menuPath;
@end

@interface TUIEmojiTextAttachment : NSTextAttachment

@property(nonatomic,strong) TUIFaceCellData *faceCellData;

@property(nonatomic,copy) NSString *emojiTag;

@property(nonatomic,assign) CGSize emojiSize;  //For emoji image size

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIUnReadView（会话未读数）
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIUnReadView : UIView

/**
 * 未读数展示 label
 * The label of displaying unread message count
 */
@property (nonatomic, strong) UILabel *unReadLabel;

/**
 * 设置未读数
 * Set the unread message count
 */
- (void)setNum:(NSInteger)num;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIConversationPin
//
/////////////////////////////////////////////////////////////////////////////////
extern NSString *kTopConversationListChangedNotification;

@interface TUIConversationPin : NSObject

+ (instancetype)sharedInstance;

/**
 * 获取置顶的会话列表
 * Getting the list of pinned conversations
 */
- (NSArray *)topConversationList;

/**
 * 置顶会话
 * Pin the conversation
 */
- (void)addTopConversation:(NSString *)conv callback:(void(^ __nullable)(BOOL success, NSString * __nullable errorMessage))callback;
/**
 * 删除置顶的会话
 * Remove pinned conversations
 */
- (void)removeTopConversation:(NSString *)conv callback:(void(^ __nullable)(BOOL success, NSString * __nullable errorMessage))callback;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIGroupAvatar
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIGroupAvatar : NSObject

/**
 * 根据群 id 实时获取最新的群头像，头像更新后会缓存在本地，该接口会请求网络
 * 该接口不会读取缓存，如果需要读取缓存，请使用 getCacheGroupAvatar:imageCallback 或者 getCacheAvatarForGroup: number:
 *
 * Obtain the latest group avatar in real time according to the group id. After the avatar is updated, it will be cached locally. This interface will request the network
 * This interface will not use the cache. If you need to read the cache, please use getCacheGroupAvatar:imageCallback or getCacheAvatarForGroup: number:
 */
+ (void)fetchGroupAvatars:(NSString *)groupID placeholder:(UIImage *)placeholder callback:(void(^)(BOOL success, UIImage *image, NSString *groupID))callback;

/**
 * 根据给定的url数组创建群组头像
 * Create a group avatar based on the given url array
 */
+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(UIImage *groupAvatar))finished;

/**
 * 根据群组 ID 和群组成员，缓存头像
 * Cache avatars based on group ID and number of group members
 */
+ (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum groupID:(NSString *)groupID;

/**
 * 异步获取头像缓存，该接口会请求接口获取当前群成员个数，并返回对应本地缓存的头像
 * Get the cached avatar asynchronously, this interface will request the interface to get the current number of group members, and return the avatar corresponding to the local cache
 */
+ (void)getCacheGroupAvatar:(NSString *)groupID callback:(void(^)(UIImage *, NSString *groupID))imageCallBack;

/**
 * 同步获取头像缓存，该接口不请求网络
 * Get the cached avatar synchronously, this interface does not request the network
 */
+ (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum;

/**
 * 清理指定群组的头像缓存
 * Clear the avatar cache of the specified group
 */
+ (void)asyncClearCacheAvatarForGroup:(NSString *)groupID;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIImageCache
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIImageCache : NSObject

+ (instancetype)sharedInstance;

- (void)addResourceToCache:(NSString *)path;
- (UIImage *)getResourceFromCache:(NSString *)path;


- (void)addFaceToCache:(NSString *)path;
- (UIImage *)getFaceFromCache:(NSString *)path;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonContactSelectCellData
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUICommonContactSelectCellData : TUICommonCellData


@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, strong) UIImage *avatarImage;


@property (nonatomic,getter=isSelected) BOOL selected;
@property (nonatomic,getter=isEnabled) BOOL enabled;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonContactListPickerCell
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUICommonContactListPickerCell : UICollectionViewCell

@property UIImageView *avatar;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIContactListPickerOnCancel
//
/////////////////////////////////////////////////////////////////////////////////
typedef void(^TUIContactListPickerOnCancel)(TUICommonContactSelectCellData *data);

@interface TUIContactListPicker : UIControl

@property (nonatomic, strong, readonly) UIButton *accessoryBtn;
@property (nonatomic, strong) NSArray<TUICommonContactSelectCellData *> *selectArray;
@property (nonatomic, copy) TUIContactListPickerOnCancel onCancel;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIProfileCardCell & vc
//
/////////////////////////////////////////////////////////////////////////////////
@class TUIProfileCardCell;
@protocol TUIProfileCardDelegate <NSObject>
- (void)didTapOnAvatar:(TUIProfileCardCell *)cell;
@end

@interface TUIProfileCardCellData : TUICommonCellData
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) UIImage *genderIconImage;
@property (nonatomic, strong) NSString *genderString;
@property BOOL showAccessory;
@property BOOL showSignature;
@end

@interface TUIProfileCardCell : TUICommonTableViewCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identifier;
@property (nonatomic, strong) UILabel *signature;
@property (nonatomic, strong) UIImageView *genderIcon;
@property (nonatomic, strong) TUIProfileCardCellData *cardData;
@property (nonatomic, weak)  id<TUIProfileCardDelegate> delegate;
- (void)fillWithData:(TUIProfileCardCellData *)data;
@end

@interface TUIAvatarViewController : UIViewController

@property (nonatomic, strong) TUIProfileCardCellData *avatarData;

@end

typedef NS_ENUM(NSUInteger, TUISelectAvatarType) {
    TUISelectAvatarTypeUserAvatar,
    TUISelectAvatarTypeGroupAvatar,
    TUISelectAvatarTypeCover,
    TUISelectAvatarTypeConversationBackGroundCover,
};

@interface TUISelectAvatarCardItem : NSObject
@property (nonatomic, strong) NSString *posterUrlStr;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, copy) NSString *fullUrlStr;
@property (nonatomic, assign) BOOL isDefaultBackgroundItem;
@property (nonatomic, assign) BOOL isGroupGridAvatar;
@property (nonatomic, copy) NSString *createGroupType;
@property (nonatomic, strong) UIImage *cacheGroupGridAvatarImage;
@end

@interface TUISelectAvatarController : UIViewController
@property (nonatomic, copy) void (^selectCallBack)(NSString *urlStr);
@property (nonatomic, assign) TUISelectAvatarType selectAvatarType;
@property (nonatomic, copy) NSString *profilFaceURL;
@property (nonatomic, strong) UIImage *cacheGroupGridAvatarImage;
@property (nonatomic, copy) NSString *createGroupType;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUICommonAvatarCell & Data
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUICommonAvatarCellData : TUICommonCellData;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property BOOL showAccessory;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSURL *avatarUrl;

@end

@interface TUICommonAvatarCell :TUICommonTableViewCell
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property UIImageView *avatar;
@property (readonly) TUICommonAvatarCellData *avatarData;


- (void)fillWithData:(TUICommonAvatarCellData *) avatarData;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUINavigationController
//
/////////////////////////////////////////////////////////////////////////////////
@class TUINavigationController;
@protocol TUINavigationControllerDelegate <NSObject>
@optional
- (void)navigationControllerDidClickLeftButton:(TUINavigationController *)controller;
- (void)navigationControllerDidSideSlideReturn:(TUINavigationController *)controller
                            fromViewController:(UIViewController *)fromViewController;
@end

@interface TUINavigationController : UINavigationController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic,weak) UIViewController* currentShowVC;
@property (nonatomic, weak) id<TUINavigationControllerDelegate> uiNaviDelegate;
@property (nonatomic, strong) UIImage *navigationItemBackArrowImage;
@end


@interface UIAlertController (TUITheme)

- (void)tuitheme_addAction:(UIAlertAction *)action;

@end

NS_ASSUME_NONNULL_END
