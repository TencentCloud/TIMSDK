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
//                           TUICommonCell & data
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUICommonCellData : NSObject
@property (strong) NSString *reuseId;
@property (nonatomic, assign) SEL cselector;
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
@interface TUINavigationController : UINavigationController

@end

NS_ASSUME_NONNULL_END
