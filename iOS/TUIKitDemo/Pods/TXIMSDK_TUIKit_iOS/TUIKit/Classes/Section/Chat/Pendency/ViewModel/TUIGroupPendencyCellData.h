#import "TCommonCell.h"
@class V2TIMGroupApplication;

NS_ASSUME_NONNULL_BEGIN

#define TUIGroupPendencyCellData_onPendencyChanged @"TUIGroupPendencyCellData_onPendencyChanged"

/**
 * 【模块名称】TUIGroupPendencyCellData
 * 【功能说明】请求单元数据源
 *  请求单元是在请求控制器中的 tableCell。
 *  本类则负责存放请求单元所需的一系列信息与数据，包括群组 ID，用户信息（头像、昵称等）以及当前请求的对应状态（已同意、已拒绝）等等。
 *  本类整合调用了 IM SDK，通过 SDK提供的接口在线拉取请求信息，同时通过 SDK 接口同意/拒接请求并发送审批结果。
 *  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
 */
@interface TUIGroupPendencyCellData : TCommonCellData

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

NS_ASSUME_NONNULL_END
