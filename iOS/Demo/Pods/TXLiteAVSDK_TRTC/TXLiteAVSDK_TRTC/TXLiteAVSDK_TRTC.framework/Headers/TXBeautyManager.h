/**
 * Module:   美颜与图像处理参数设置类
 * Function: 修改美颜、滤镜、绿幕等参数
 */
#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIImage TXImage;
#else
#import <AppKit/AppKit.h>
typedef NSImage TXImage;
#endif

NS_ASSUME_NONNULL_BEGIN

/// @defgroup TXBeautyManager_ios TXBeautyManager
/// 美颜与图像处理参数设置类
/// @{

/**
 * 美颜（磨皮）算法
 * TRTC 内置多种不同的磨皮算法，您可以选择最适合您产品定位的方案。
 */
typedef NS_ENUM(NSInteger, TXBeautyStyle) {

    ///光滑，算法比较激进，磨皮效果比较明显，适用于秀场直播。
    TXBeautyStyleSmooth = 0,

    ///自然，算法更多地保留了面部细节，磨皮效果更加自然，适用于绝大多数直播场景。
    TXBeautyStyleNature = 1,

    ///优图，由优图实验室提供，磨皮效果介于光滑和自然之间，比光滑保留更多皮肤细节，比自然磨皮程度更高。
    TXBeautyStylePitu = 2
};

@interface TXBeautyManager : NSObject

/**
 * 设置美颜（磨皮）算法
 *
 * TRTC 内置多种不同的磨皮算法，您可以选择最适合您产品定位的方案：
 *
 * @param beautyStyle 美颜风格，TXBeautyStyleSmooth：光滑；TXBeautyStyleNature：自然；TXBeautyStylePitu：优图。
 */
- (void)setBeautyStyle:(TXBeautyStyle)beautyStyle;

/**
 * 设置美颜级别
 *
 * @param beautyLevel 美颜级别，取值范围0 - 9； 0表示关闭，9表示效果最明显。
 */
- (void)setBeautyLevel:(float)beautyLevel;

/**
 * 设置美白级别
 *
 * @param whitenessLevel 美白级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 */
- (void)setWhitenessLevel:(float)whitenessLevel;

/**
 * 开启清晰度增强
 */
- (void)enableSharpnessEnhancement:(BOOL)enable;

/**
 * 设置红润级别
 *
 * @param ruddyLevel 红润级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 */
- (void)setRuddyLevel:(float)ruddyLevel;

/**
 * 设置色彩滤镜效果
 *
 * 色彩滤镜，是一副包含色彩映射关系的颜色查找表图片，您可以在我们提供的官方 Demo 中找到预先准备好的几张滤镜图片。
 * SDK 会根据该查找表中的映射关系，对摄像头采集出的原始视频画面进行二次处理，以达到预期的滤镜效果。
 * @param image 包含色彩映射关系的颜色查找表图片，必须是 png 格式。
 */
- (void)setFilter:(nullable TXImage *)image;

/**
 * 设置色彩滤镜的强度
 *
 * 该数值越高，色彩滤镜的作用强度越明显，经过滤镜处理后的视频画面跟原画面的颜色差异越大。
 * 我默认的滤镜浓度是0.5，如果您觉得默认的滤镜效果不明显，可以设置为 0.5 以上的数字，最大值为1。
 *
 * @param strength 从0到1，数值越大滤镜效果越明显，默认值为0.5。
 */
- (void)setFilterStrength:(float)strength;

/**
 * 设置绿幕背景视频，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * 此接口所开启的绿幕功能不具备智能去除背景的能力，需要被拍摄者的背后有一块绿色的幕布来辅助产生特效。
 *
 * @param path MP4格式的视频文件路径; 设置空值表示关闭特效。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
- (int)setGreenScreenFile:(nullable NSString *)path;

/**
 * 设置大眼级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param eyeScaleLevel 大眼级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setEyeScaleLevel:(float)eyeScaleLevel;
#endif

/**
 * 设置瘦脸级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param faceSlimLevel 瘦脸级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setFaceSlimLevel:(float)faceSlimLevel;
#endif

/**
 * 设置 V 脸级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param faceVLevel V脸级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setFaceVLevel:(float)faceVLevel;
#endif

/**
 * 设置下巴拉伸或收缩，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param chinLevel 下巴拉伸或收缩级别，取值范围-9 - 9；0 表示关闭，小于0表示收缩，大于0表示拉伸。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setChinLevel:(float)chinLevel;
#endif

/**
 * 设置短脸级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param faceShortLevel 短脸级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setFaceShortLevel:(float)faceShortLevel;
#endif

/**
 * 设置窄脸级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param level 窄脸级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setFaceNarrowLevel:(float)faceNarrowLevel;
#endif

/**
 * 设置瘦鼻级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param noseSlimLevel 瘦鼻级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setNoseSlimLevel:(float)noseSlimLevel;
#endif

/**
 * 设置亮眼级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param eyeLightenLevel 亮眼级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setEyeLightenLevel:(float)eyeLightenLevel;
#endif

/**
 * 设置牙齿美白级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param toothWhitenLevel 白牙级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setToothWhitenLevel:(float)toothWhitenLevel;
#endif

/**
 * 设置祛皱级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param wrinkleRemoveLevel 祛皱级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setWrinkleRemoveLevel:(float)wrinkleRemoveLevel;
#endif

/**
 * 设置祛眼袋级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param pounchRemoveLevel 祛眼袋级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setPounchRemoveLevel:(float)pounchRemoveLevel;
#endif

/**
 * 设置法令纹去除级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param smileLinesRemoveLevel 法令纹级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setSmileLinesRemoveLevel:(float)smileLinesRemoveLevel;
#endif

/**
 * 设置发际线调整级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param foreheadLevel 发际线级别，取值范围-9 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setForeheadLevel:(float)foreheadLevel;
#endif

/**
 * 设置眼距，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param eyeDistanceLevel 眼距级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setEyeDistanceLevel:(float)eyeDistanceLevel;
#endif

/**
 * 设置眼角调整级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param eyeAngleLevel 眼角调整级别，取值范围-9 - 9；0表示关闭，9表示效果最明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setEyeAngleLevel:(float)eyeAngleLevel;
#endif

/**
 * 设置嘴型调整级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param mouthShapeLevel 嘴型级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setMouthShapeLevel:(float)mouthShapeLevel;
#endif

/**
 * 设置鼻翼调整级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param noseWingLevel 鼻翼调整级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setNoseWingLevel:(float)noseWingLevel;
#endif

/**
 * 设置鼻子位置，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param nosePositionLevel 鼻子位置级别，取值范围-9 - 9；0表示关闭，小于0表示抬高，大于0表示降低。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setNosePositionLevel:(float)nosePositionLevel;
#endif

/**
 * 设置嘴唇厚度，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param lipsThicknessLevel 嘴唇厚度级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setLipsThicknessLevel:(float)lipsThicknessLevel;
#endif

/**
 * 设置脸型，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param   faceBeautyLevel 美型级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 * @return 0：成功；-5：当前 License 对应 feature 不支持。
 */
#if TARGET_OS_IPHONE
- (int)setFaceBeautyLevel:(float)faceBeautyLevel;
#endif

/**
 * 选择 AI 动效挂件，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 *
 * @param tmplName 动效挂件名称
 * @param tmplDir 动效素材文件所在目录
 */
#if TARGET_OS_IPHONE
- (void)setMotionTmpl:(nullable NSString *)tmplName inDir:(nullable NSString *)tmplDir;
#endif

/**
 * 是否在动效素材播放时静音，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
 * 有些挂件本身会有声音特效，通过此 API 可以关闭这些特效播放时所带的声音效果。
 *
 * @param motionMute YES：静音；NO：不静音。
 */
#if TARGET_OS_IPHONE
- (void)setMotionMute:(BOOL)motionMute;
#endif

@end
/// @}

NS_ASSUME_NONNULL_END
