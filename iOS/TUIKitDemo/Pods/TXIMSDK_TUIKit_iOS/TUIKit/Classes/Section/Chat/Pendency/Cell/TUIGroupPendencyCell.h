/******************************************************************************
 *
 *  本文件声明了群组请求展示的相关模块
 *  用户申请入群时，可以通过本 cell 展示申请信息，如用户头像、用户昵称、申请简介等。
 *  同时本 cell 组件还负责响应用户的点击事件，使群管理可以点击 cell 跳转到对应用户的详细信息界面。
 *
 ******************************************************************************/

#import "TCommonCell.h"
#import "TUIGroupPendencyCellData.h"

NS_ASSUME_NONNULL_BEGIN

/** 腾讯云 TUIKit
 * 【模块名称】TUIGroupPendencyCell
 * 【功能说明】TUI 群组请求单元。
 *  本类为在群组请求控制器中显示的 tableCell。
 *  单元中包含的具体信息有用户头像、用户昵称、申请简介、同意按钮。
 */
@interface TUIGroupPendencyCell : TCommonTableViewCell

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

NS_ASSUME_NONNULL_END
