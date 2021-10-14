//  Copyright © 2019 Tencent. All rights reserved.
//
// TXBeautyManager 的接口包装，使用时可以将TXBeautyManager 强制转为 id<TCBeautyPanelParamSetter>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCBeautyPanelActionPerformer <NSObject>
/**
* 设置指定素材滤镜特效
*
* @param filterImage 指定素材，即颜色查找表图片。**必须使用 png 格式**
*/
- (void)setFilter:(nullable UIImage*)filterImage;

/**
 * 设置滤镜强度（v7.2后的版本请使用 setFilterStrength）
 *
 * @param level 滤镜强度, 从0到1，越大滤镜效果越明显，默认值为0.5。
 */
- (void)setFilterConcentration:(float)level;

/**
 * 设置滤镜浓度
 *
 * 在美女秀场等应用场景里，滤镜浓度的要求会比较高，以便更加突显主播的差异。
 * 我们默认的滤镜浓度是0.5，如果您觉得滤镜效果不明显，可以使用下面的接口进行调节。
 *
 * @param strength 从0到1，越大滤镜效果越明显，默认值为0.5。
 */
- (void)setFilterStrength:(float)strength;

/** 设置绿幕文件（增值版本有效，普通版本设置此参数无效）[仅限企业版Pro]
 *
 * @param file 绿幕文件路径
 */
- (void)setGreenScreenFile:(nullable NSString *)file;

// 以下为 TXBeautyManager 方法
/**
 * 设置美颜（磨皮）算法
 *
 * SDK 内部集成了两套风格不同的磨皮算法，一套我们取名叫“光滑”，适用于美女秀场，效果比较明显。
 * 另一套我们取名“自然”，磨皮算法更多地保留了面部细节，主观感受上会更加自然。
 *
 * @param beautyStyle 美颜风格，光滑或者自然，光滑风格磨皮更加明显，适合娱乐场景。
 */
- (void)setBeautyStyle:(NSInteger)beautyStyle;

/**
 * 设置美颜级别
 * @param level 美颜级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setBeautyLevel:(float)level;

/**
 * 设置美白级别
 *
 * @param level 美白级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setWhitenessLevel:(float)level;

/**
 * 设置红润级别
 *
 * @param level 红润级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setRuddyLevel:(float)level;

#if TARGET_OS_IPHONE
/**
 * 设置大眼级别（企业版有效，其它版本设置此参数无效）
 *
 * @param level 大眼级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setEyeScaleLevel:(float)level;

/**
 * 设置瘦脸级别（企业版有效，其它版本设置此参数无效）
 *
 * @param level 瘦脸级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setFaceSlimLevel:(float)level;

/**
 * 设置V脸级别（企业版有效，其它版本设置此参数无效）
 *
 * @param level V脸级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setFaceVLevel:(float)level;

/**
 * 设置下巴拉伸或收缩（企业版有效，其它版本设置此参数无效）
 *
 * @param level 下巴拉伸或收缩级别，取值范围-9 - 9；0 表示关闭，小于0表示收缩，大于0表示拉伸。
 */
- (void)setChinLevel:(float)level;
/**
 * 设置短脸级别（企业版有效，其它版本设置此参数无效）
 *
 * @param level 短脸级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setFaceShortLevel:(float)level;

/**
 * 设置瘦鼻级别（企业版有效，其它版本设置此参数无效）
 *
 * @param level 瘦鼻级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setNoseSlimLevel:(float)level;

/**
 * 设置亮眼 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 亮眼级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setEyeLightenLevel:(float)level;

/**
 * 设置白牙 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 白牙级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setToothWhitenLevel:(float)level;

/**
 * 设置祛皱 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 祛皱级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setWrinkleRemoveLevel:(float)level;

/**
 * 设置祛眼袋 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 祛眼袋级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setPounchRemoveLevel:(float)level;

/**
 * 设置法令纹 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 法令纹级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setSmileLinesRemoveLevel:(float)level;

/**
 * 设置发际线 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 发际线级别，取值范围-9 - 9；0表示关闭，小于0表示抬高，大于0表示降低。
 */
- (void)setForeheadLevel:(float)level;

/**
 * 设置眼距 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 眼距级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
 */
- (void)setEyeDistanceLevel:(float)level;

/**
 * 设置眼角 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 眼角级别，取值范围-9 - 9；0表示关闭，小于0表示降低，大于0表示抬高。
 */
- (void)setEyeAngleLevel:(float)level;

/**
 * 设置嘴型 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 嘴型级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
 */
- (void)setMouthShapeLevel:(float)level;

/**
 * 设置鼻翼 （企业版有效，其它版本设置此参数无效）
 *
 * @param level 鼻翼级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
 */
- (void)setNoseWingLevel:(float)level;

/**
 * 设置鼻子位置 （企业版有效，其它版本设置此参数无效）
 * @param level 鼻子位置级别，取值范围-9 - 9；0表示关闭，小于0表示抬高，大于0表示降低。
 */
- (void)setNosePositionLevel:(float)level;

/**
 * 设置嘴唇厚度 （企业版有效，其它版本设置此参数无效）
 * @param level 嘴唇厚度级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
 */
- (void)setLipsThicknessLevel:(float)level;

/**
 * 设置脸型（企业版有效，其它版本设置此参数无效）
 * @param   level 美型级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setFaceBeautyLevel:(float)level;

/**
 * 选择 AI 动效挂件（企业版有效，其它版本设置此参数无效）
 *
 * @param tmplName 动效名称
 * @param tmplDir 动效所在目录
 */
- (void)setMotionTmpl:(nullable NSString *)tmplName inDir:(nullable NSString *)tmplDir;

/**
 * 设置动效静音（企业版有效，其它版本设置此参数无效）
 *
 * 有些挂件本身会有声音特效，通过此 API 可以关闭这些特效播放时所带的声音效果。
 *
 * @param motionMute YES：静音；NO：不静音。
 */
- (void)setMotionMute:(BOOL)motionMute;
#endif

@end

NS_ASSUME_NONNULL_END
