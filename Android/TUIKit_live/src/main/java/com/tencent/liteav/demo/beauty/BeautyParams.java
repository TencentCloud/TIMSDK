package com.tencent.liteav.demo.beauty;

import android.graphics.Bitmap;

/**
 * 美颜参数
 */
public class BeautyParams {
    // 美颜类型
    public int mBeautyStyle = 0;
    // 美颜
    public int mBeautyLevel = 4;
    // 美白
    public int mWhiteLevel = 1;
    // 红润
    public int mRuddyLevel = 0;
    // 滤镜LUT图
    public Bitmap mFilterBmp;
    // 滑动滤镜索引
    public int mFilterIndex;
    // 滤镜程度
    public float mFilterMixLevel = 0;
    // 大眼
    public int mBigEyeLevel;
    // 瘦脸
    public int mFaceSlimLevel;
    // 瘦鼻
    public int mNoseSlimLevel;
    // 缩下巴
    public int mChinSlimLevel;
    // V脸
    public int mFaceVLevel;
    // 短脸
    public int mFaceShortLevel;
    // 亮眼
    public int mEyeLightenLevel = 0;
    // 白牙
    public int mToothWhitenLevel = 0;
    // 祛皱
    public int mWrinkleRemoveLevel = 0;
    // 祛眼袋
    public int mPounchRemoveLevel = 0;
    // 祛法令纹
    public int mSmileLinesRemoveLevel = 0;
    // 发际线
    public int mForeheadLevel = 0;
    // 眼距
    public int mEyeDistanceLevel = 0;
    // 眼角
    public int mEyeAngleLevel = 0;
    // 嘴型
    public int mMouthShapeLevel = 0;
    // 鼻翼
    public int mNoseWingLevel = 0;
    // 鼻子位置
    public int mNosePositionLevel = 0;
    // 嘴唇厚度
    public int mLipsThicknessLevel = 0;
    // 脸型
    public int mFaceBeautyLevel = 0;
    // 长腿
    public int mLongLegLevel = 0;
    // 瘦腰
    public int mThinWaistLevel = 0;
    // 瘦体
    public int mThinBodyLevel = 0;
    // 瘦肩
    public int mThinShoulderLevel = 0;
    // 动效文件路径
    public String mMotionTmplPath;
    // 绿幕
    public String mGreenFile;
    // 滤镜效果程度
    public int mFilterStrength;
}
