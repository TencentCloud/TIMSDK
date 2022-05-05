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
@property(nonatomic,copy) NSString *userId;  //userId
@property(nonatomic,copy) NSString *name;    //昵称
@property(nonatomic,copy) NSString *avatar;  //头像
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
//                           TUINaviBarIndicatorView
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUINaviBarIndicatorView : UIView

/**
 *  指示器视图，即“小圆圈”本体。
 */
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

/**
 *  示意标签
 *  除了通过“小圆圈”外，本试图还可通过文字形式对当前状态进行展示。
 *  例如：“连接中..." / ”腾讯·云通信（未连接）“等。
 */
@property (nonatomic, strong) UILabel *label;

/**
 *  设置标签
 *  通过本函数，您可以设置标签的内容，可以用于初始化标签或在合适的情况下修改标签内容。
 *
 *  @param title 需要设置的标签内容。
 */
- (void)setTitle:(NSString *)title;

/**
 *  开始转动
 *  令”小圆圈“开始转动。
 */
- (void)startAnimating;

/**
 *  停止转动
 *  令”小圆圈“停止转动。
 */
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
@end

@interface TUICommonTableViewCell : UITableViewCell

@property (readonly) TUICommonCellData *data;
@property UIColor *colorWhenTouched;
@property BOOL changeColorWhenTouched;

- (void)fillWithData:(TUICommonCellData *)data;

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

/**
 *  请求中，请求加群的群组 ID。
 */
@property(nonatomic,strong) NSString* groupId;

/**
 *  请求的发送者 ID。
 */
@property(nonatomic,strong) NSString* fromUser;

/**
 *  请求接收者的 ID。在群组请求中，本项可根据具体需求个性化填写或不填写。
 */
@property(nonatomic,strong) NSString* toUser;

/**
 *  请求项目。
 */
@property (readonly) V2TIMGroupApplication *pendencyItem;

/**
 *  请求者的头像 URL。
 */
@property NSURL *avatarUrl;

/**
 *  请求者昵称。
 */
@property NSString *title;

/**
 *  请求者的加群简介。如“小明申请加入群聊”。
 */
@property NSString *requestMsg;

/**
 *  是否同意。YES：同意。
 *  此变量为 NO时，仅表明当前请求未同意，并不意味着请求已拒绝。
 */
@property BOOL isAccepted;

/**
 *  是否拒绝。YES：拒绝。
 *  此变量为 NO时，仅表明当前请求未拒绝，并不意味着请求已同意。
 */
@property BOOL isRejectd;
@property SEL cbuttonSelector;

/**
 *  依据 IM SDK 中的 TIMGroupPendencyItem 初始化 cellData。
 *
 *  @param args 初始化的数据依据。通过 IM SDK 提供的请求相关接口获得。
 *
 *  @return 返回一个 TUIGroupPendencyCellData。将从 SDK 获取的对象转换成了更便于我们处理的对象。
 */
- (instancetype)initWithPendency:(V2TIMGroupApplication *)args;

/**
 *  接受请求
 *  通过 IM SDK 提供的接口 accept 对此请求进行接受，并给出相应的提示信息。
 */
- (void)accept;

/**
 *  接受请求
 *  通过 IM SDK 提供的接口 refuse 对此请求进行拒绝，并给出相应的提示信息。
 */
- (void)reject;

@end

@interface TUIGroupPendencyCell : TUICommonTableViewCell

/**
 *  申请者头像视图。
 */
@property UIImageView *avatarView;

/**
 *  申请者昵称标签。
 */
@property UILabel *titleLabel;

/**
 *  申请者请求简述。
 */
@property UILabel *addWordingLabel;

/**
 *  同意
 *  在 tableCell 最右侧显示的同意按钮。
 */
@property UIButton *agreeButton;

/**
 *  请求单元数据源。
 *  存放请求单元所需的一系列信息与数据。包括群组 ID、用户头像、用户昵称、请求状态（同意或拒绝）等等。
 *  具体信息请参考 Section\Chat\Pendency\ViewModel\TUIGroupPendencyCellData.h
 */
@property TUIGroupPendencyCellData *pendencyData;

/**
 *  根据消息源填充请求单元。
 *  包括用户头像、用户昵称、请求简述、按钮标题等。
 *
 *  @param pendencyData 负责存放数据的数据源。
 */
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
 */
@interface TUIFaceCellData : NSObject

/**
 *  表情名称。
 */
@property (nonatomic, strong) NSString *name;

/**
 * 表情的本地化名称（国际化属性，如果为空或者length为0，默认显示name）
 */
@property (nonatomic, copy) NSString *localizableName;

/**
 *  表情在本地缓存的存储路径。
 */
@property (nonatomic, strong) NSString *path;
@end

/**
 * 【模块名称】TUIFaceCell
 * 【功能说明】存储表情的图像，并根据 TUIFaceCellData 初始化 Cell。
 *  在表情视图中，TUIFaceCell 即为界面显示的单元。
 */
@interface TUIFaceCell : UICollectionViewCell

/**
 *  表情图像
 *  表情所对应的Image图像。
 */
@property (nonatomic, strong) UIImageView *face;

/**
 *  设置表情单元的数据
 *
 *  @param data 需要设置的数据源。
 */
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
 */
@interface TUIFaceGroup : NSObject

/**
 *  表情组索引号，从0开始。
 */
@property (nonatomic, assign) int groupIndex;

/**
 *  表情组路径
 *  用于保存表情组在系统中存放的路径。
 */
@property (nonatomic, strong) NSString *groupPath;

/**
 *  表情组总行数
 *  用于计算表情总数，进而定位每一个表情。
 */
@property (nonatomic, assign) int rowCount;

/**
 *  每行所包含的表情数
 *  用于计算表情总数，进而定位每一个表情。
 */
@property (nonatomic, assign) int itemCountPerRow;

/**
 *  表情信息组
 *  存储各个表情的 cellData
 */
@property (nonatomic, strong) NSMutableArray *faces;

/**
 *  删除标志位
 *  对于需要“删除”按钮的表情组，该位为 YES，否则为 NO。
 *  当该位为 YES 时，FaceView 会在表情视图右下角中显示一个“删除”图标，使您无需呼出键盘即可进行表情的删除操作。
 */
@property (nonatomic, assign) BOOL needBackDelete;

/**
 *  表情menu路径
 *  用于存储表情菜单在系统中存放的路径。
 *  表情菜单即在表情视图最下方显示表情组缩略图与“发送按钮”的菜单视图。
 */
@property (nonatomic, strong) NSString *menuPath;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIUnReadView（会话未读数）
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIUnReadView : UIView
/**
 * 未读数展示 label
 */
@property (nonatomic, strong) UILabel *unReadLabel;
/**
 * 设置未读数
 */
- (void)setNum:(NSInteger)num;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIConversationPin（会话置顶）
//
/////////////////////////////////////////////////////////////////////////////////
extern NSString *kTopConversationListChangedNotification;
@interface TUIConversationPin : NSObject
/**
 * 获取 TUIConversationPin 实例
 */
+ (instancetype)sharedInstance;
/**
 * 获取置顶的会话列表
 */
- (NSArray *)topConversationList;
/**
 * 置顶会话
 */
- (void)addTopConversation:(NSString *)conv callback:(void(^ __nullable)(BOOL success, NSString * __nullable errorMessage))callback;
/**
 * 删除置顶的会话
 */
- (void)removeTopConversation:(NSString *)conv callback:(void(^ __nullable)(BOOL success, NSString * __nullable errorMessage))callback;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIGroupAvatar（九宫格群头像）
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIGroupAvatar : NSObject

/**
 * 根据群 id 实时获取最新的群头像，头像跟新后会缓存在本地，该接口会请求网络
 * 该接口不会读取缓存，如果需要读取缓存，请使用 getCacheGroupAvatar:imageCallback 或者 getCacheAvatarForGroup: number:
 *
 * @param groupID 群ID
 * @param placeholder 占位头像，当网络异常获取失败时，callback 回调会返回该占位头像
 * @param callback 回调
 */
+ (void)fetchGroupAvatars:(NSString *)groupID placeholder:(UIImage *)placeholder callback:(void(^)(BOOL success, UIImage *image, NSString *groupID))callback;

/**
 * 根据给定的url数组创建群组头像
 *
 * @param group 群组成员的头像 url 列表
 * @param finished 创建完成后的回调
 */
+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(UIImage *groupAvatar))finished;

/**
 * 缓存头像
 *
 * @param avatar 准备缓存的图像
 * @param memberNum  当前头像对应的成员数
 * @param groupID 当前缓存的群组ID
 */
+ (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum groupID:(NSString *)groupID;

/**
 * 异步获取头像缓存，该接口会请求接口获取当前群成员个数，并返回对应本地缓存的头像
 *
 * @param groupID 群ID
 * @param imageCallBack 回调
 */
+ (void)getCacheGroupAvatar:(NSString *)groupID callback:(void(^)(UIImage *))imageCallBack;

/**
 * 同步获取头像缓存，该接口不请求网络
 *
 * @param groupId 群组ID
 * @param memberNum 指定群成员个数
 */
+ (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIImageCache（图像资源、表情资源缓存与加载）
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIImageCache : NSObject

+ (instancetype)sharedInstance;

/**
 *  将图像资源添加进本地缓存中
 *
 *  @param path 本地缓存所在路径
 */
- (void)addResourceToCache:(NSString *)path;

/**
 *  从本地缓存获取图像资源
 *
 *  @param path 本地缓存所在路径
 */
- (UIImage *)getResourceFromCache:(NSString *)path;

/**
 *  将表情添加进本地缓存中
 *
 *  @param path 本地缓存所在路径
 */
- (void)addFaceToCache:(NSString *)path;

/**
 *  从本地缓存获取表情资源
 *
 *  @param path 本地缓存所在路径
 */
- (UIImage *)getFaceFromCache:(NSString *)path;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonContactSelectCellData（通讯录联系人信息）
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUICommonContactSelectCellData : TUICommonCellData

/**
 *  设置用户
 */
@property (nonatomic, strong) NSString *identifier;

/**
 *  设置标题
 */
@property (nonatomic, strong) NSString *title;

/**
 *  设置头像 URL
 */
@property (nonatomic, strong) NSURL *avatarUrl;

/**
 *  设置头像 image
 */
@property (nonatomic, strong) UIImage *avatarImage;


@property (nonatomic,getter=isSelected) BOOL selected;
@property (nonatomic,getter=isEnabled) BOOL enabled;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                          TUICommonContactListPickerCell（通讯录多选视图的cell）
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUICommonContactListPickerCell : UICollectionViewCell

@property UIImageView *avatar;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIContactListPickerOnCancel（通讯录多选视图）
//
/////////////////////////////////////////////////////////////////////////////////
typedef void(^TUIContactListPickerOnCancel)(TUICommonContactSelectCellData *data);

@interface TUIContactListPicker : UIControl

/// 获取 “确定”  Btn
@property (nonatomic, strong, readonly) UIButton *accessoryBtn;
/// 设置选中用户
@property (nonatomic, strong) NSArray<TUICommonContactSelectCellData *> *selectArray;
/// 用户取消选中回调
@property (nonatomic, copy) TUIContactListPickerOnCancel onCancel;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUINavigationController（通讯录多选视图）
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUINavigationController : UINavigationController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>


@property(nonatomic,weak) UIViewController* currentShowVC;

@end


@interface UIAlertController (TUITheme)

@end

NS_ASSUME_NONNULL_END
