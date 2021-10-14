// Copyright (c) 2019 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PanelMenuIndex) {
    PanelMenuIndexBeauty,
    PanelMenuIndexFilter,
    PanelMenuIndexMotion,
    PanelMenuIndexCosmetic,
    PanelMenuIndexGesture,
    PanelMenuIndexKoubei,
    PanelMenuIndexGreen,
    PanelMenuIndexCount
};

typedef NS_ENUM(NSInteger, TCBeautyStyle) {
    TCBeautyStyleSmooth    = 0,  ///< 光滑，适用于美女秀场，效果比较明显。
    TCBeautyStyleNature    = 1,  ///< 自然，磨皮算法更多地保留了面部细节，主观感受上会更加自然。
    TCBeautyStylePitu      = 2   ///< 企业版美颜算法（企业版有效，其它版本设置此参数无效）
};

@protocol TCBeautyPanelThemeProtocol;
@protocol TCBeautyPanelActionPerformer;

@protocol BeautyLoadPituDelegate <NSObject>
- (void)onLoadPituStart;
- (void)onLoadPituProgress:(CGFloat)progress;
- (void)onLoadPituFinished;
- (void)onLoadPituFailed;
@end

@interface TCBeautyPanel : UIView
@property (nonatomic, assign) NSInteger currentFilterIndex;
@property (nonatomic, readonly, nullable) NSString* currentFilterName;
@property (nonatomic, assign) CGFloat bottomOffset;
@property (nonatomic, assign, readonly) float beautyLevel;
@property (nonatomic, assign, readonly) float whiteLevel;
@property (nonatomic, assign, readonly) float ruddyLevel;
@property (nonatomic, assign, readonly) TCBeautyStyle beautyStyle;
@property (nonatomic, strong) id<TCBeautyPanelThemeProtocol> theme;
// 这里是强引用，一般传入一个代理对象，来转发各设置项到SDK
@property (nonatomic, strong) id<TCBeautyPanelActionPerformer> actionPerformer;
@property (nonatomic, weak) id<BeautyLoadPituDelegate> pituDelegate;

/// 以默认主题实例化美颜面板
+ (instancetype)beautyPanelWithFrame:(CGRect)frame
                     actionPerformer:(id<TCBeautyPanelActionPerformer>)actionPerformer;

- (instancetype)initWithFrame:(CGRect)frame
                        theme:(nullable id<TCBeautyPanelThemeProtocol>)theme
              actionPerformer:(nullable id<TCBeautyPanelActionPerformer>)actionPerformer;

/**
 * 重置默认值，并通过 actionPerformer 应用默认值
 *
 * 默认开启以下内容：
 * “自然”风格美颜，值为6；开启“美白”选项，值为1；使用“标准”风格滤镜，值为5；其它均为关闭。
 */
- (void)resetAndApplyValues;
+ (NSUInteger)getHeight;
- (UIImage*)filterImageByMenuOptionIndex:(NSInteger)index;
- (float)filterMixLevelByIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
