package com.tencent.liteav.demo.beauty;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.widget.Toast;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.demo.beauty.constant.BeautyConstants;
import com.tencent.liteav.demo.beauty.download.DownloadListener;
import com.tencent.liteav.demo.beauty.download.MaterialDownloader;
import com.tencent.liteav.demo.beauty.model.BeautyInfo;
import com.tencent.liteav.demo.beauty.model.ItemInfo;
import com.tencent.liteav.demo.beauty.model.TabInfo;
import com.tencent.liteav.demo.beauty.utils.BeautyUtils;
import com.tencent.liteav.demo.beauty.utils.ResourceUtils;
import com.tencent.liteav.demo.beauty.utils.SPUtils;
import com.tencent.liteav.demo.beauty.view.ProgressDialog;
import com.tencent.qcloud.tim.tuikit.live.R;

import java.util.List;

public class BeautyImpl implements Beauty {

    private static final String TAG = "BeautyImpl";

    private Context                mContext;
    private BeautyParams           mBeautyParams;
    private TXBeautyManager        mBeautyManager;
    private OnFilterChangeListener mOnFilterChangeListener;

    public BeautyImpl(@NonNull Context context) {
        mContext = context;
        mBeautyParams = new BeautyParams();
    }

    @Override
    public void setBeautyManager(@NonNull TXBeautyManager beautyManager) {
        mBeautyManager = beautyManager;
    }

    @Override
    public void setBeautySpecialEffects(@NonNull TabInfo tabinfo, @IntRange(from = 0) int tabPosition, @NonNull ItemInfo itemInfo, @IntRange(from = 0) int itemPosition) {
        dispatchEffects(tabinfo, tabPosition, itemInfo, itemPosition);
    }

    @Override
    public void setBeautyStyleAndLevel(int style, int level) {
        if (mBeautyManager != null) {
            setBeautyStyle(style);
            setBeautyLevel(level);
        }
    }

    /**
     * 设置指定素材滤镜特效
     *
     * @param filterImage 指定素材，即颜色查找表图片。必须使用 png 格式
     * @param index
     */
    private void setFilter(Bitmap filterImage, int index) {
        mBeautyParams.mFilterBmp = filterImage;
        mBeautyParams.mFilterIndex = index;
        if (mBeautyManager != null) {
            mBeautyManager.setFilter(filterImage);
            if (mOnFilterChangeListener != null) {
                mOnFilterChangeListener.onChanged(filterImage, index);
            }
        }
    }

    /**
     * 设置滤镜浓度
     *
     * @param strength 从0到1，越大滤镜效果越明显，默认值为0.5
     */
    private void setFilterStrength(float strength) {
        mBeautyParams.mFilterMixLevel = strength;
        if (mBeautyManager != null) {
            mBeautyManager.setFilterStrength(strength);
        }
    }

    /**
     * 设置绿幕文件
     *
     * @param path 视频文件路径。支持 MP4；null 表示关闭特效
     */
    private void setGreenScreenFile(String path) {
        mBeautyParams.mGreenFile = path;
        if (mBeautyManager != null) {
            mBeautyManager.setGreenScreenFile(path);
        }
    }

    /**
     * 设置美颜类型
     *
     * @param beautyStyle 美颜风格.三种美颜风格：0 ：光滑 1：自然 2：朦胧
     */
    private void setBeautyStyle(int beautyStyle) {
        if (beautyStyle >= 3 || beautyStyle < 0) {
            return;
        }
        mBeautyParams.mBeautyStyle = beautyStyle;
        if (mBeautyManager != null) {
            mBeautyManager.setBeautyStyle(beautyStyle);
        }
    }

    /**
     * 设置美颜级别
     *
     * @param beautyLevel 美颜级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setBeautyLevel(int beautyLevel) {
        mBeautyParams.mBeautyLevel = beautyLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setBeautyLevel(beautyLevel);
        }
    }

    /**
     * 设置美白级别
     *
     * @param whitenessLevel 美白级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setWhitenessLevel(int whitenessLevel) {
        mBeautyParams.mWhiteLevel = whitenessLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setWhitenessLevel(whitenessLevel);
        }
    }

    /**
     * 设置红润级别
     *
     * @param ruddyLevel 红润级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setRuddyLevel(int ruddyLevel) {
        mBeautyParams.mRuddyLevel = ruddyLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setRuddyLevel(ruddyLevel);
        }
    }

    /**
     * 设置大眼级别
     *
     * @param eyeScaleLevel 大眼级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setEyeScaleLevel(int eyeScaleLevel) {
        mBeautyParams.mBigEyeLevel = eyeScaleLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setEyeScaleLevel(eyeScaleLevel);
        }
    }

    /**
     * 设置瘦脸级别
     *
     * @param faceSlimLevel 瘦脸级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setFaceSlimLevel(int faceSlimLevel) {
        mBeautyParams.mFaceSlimLevel = faceSlimLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setFaceSlimLevel(faceSlimLevel);
        }
    }

    /**
     * 设置 V 脸级别
     *
     * @param faceVLevel V脸级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setFaceVLevel(int faceVLevel) {
        mBeautyParams.mFaceVLevel = faceVLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setFaceVLevel(faceVLevel);
        }
    }

    /**
     * 设置下巴拉伸或收缩
     *
     * @param chinLevel 下巴拉伸或收缩级别，取值范围 -9 - 9；0 表示关闭，小于0表示收缩，大于0表示拉伸
     */
    private void setChinLevel(int chinLevel) {
        mBeautyParams.mChinSlimLevel = chinLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setChinLevel(chinLevel);
        }
    }

    /**
     * 设置短脸级别
     *
     * @param faceShortLevel 短脸级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setFaceShortLevel(int faceShortLevel) {
        mBeautyParams.mFaceShortLevel = faceShortLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setFaceShortLevel(faceShortLevel);
        }
    }

    /**
     * 设置瘦鼻级别
     *
     * @param noseSlimLevel 瘦鼻级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setNoseSlimLevel(int noseSlimLevel) {
        mBeautyParams.mNoseSlimLevel = noseSlimLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setNoseSlimLevel(noseSlimLevel);
        }
    }

    /**
     * 设置亮眼
     *
     * @param eyeLightenLevel 亮眼级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setEyeLightenLevel(int eyeLightenLevel) {
        mBeautyParams.mEyeLightenLevel = eyeLightenLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setEyeLightenLevel(eyeLightenLevel);
        }
    }

    /**
     * 设置白牙
     *
     * @param toothWhitenLevel 亮眼级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setToothWhitenLevel(int toothWhitenLevel) {
        mBeautyParams.mToothWhitenLevel = toothWhitenLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setToothWhitenLevel(toothWhitenLevel);
        }
    }

    /**
     * 设置祛皱
     *
     * @param wrinkleRemoveLevel 祛皱级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setWrinkleRemoveLevel(int wrinkleRemoveLevel) {
        mBeautyParams.mWrinkleRemoveLevel = wrinkleRemoveLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setWrinkleRemoveLevel(wrinkleRemoveLevel);
        }
    }

    /**
     * 设置祛眼袋
     *
     * @param pounchRemoveLevel 祛眼袋级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setPounchRemoveLevel(int pounchRemoveLevel) {
        mBeautyParams.mPounchRemoveLevel = pounchRemoveLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setPounchRemoveLevel(pounchRemoveLevel);
        }
    }

    /**
     * 设置祛法令纹
     *
     * @param smileLinesRemoveLevel 祛法令纹级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setSmileLinesRemoveLevel(int smileLinesRemoveLevel) {
        mBeautyParams.mSmileLinesRemoveLevel = smileLinesRemoveLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setSmileLinesRemoveLevel(smileLinesRemoveLevel);
        }
    }

    /**
     * 设置发际线
     *
     * @param foreheadLevel 发际线级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setForeheadLevel(int foreheadLevel) {
        mBeautyParams.mForeheadLevel = foreheadLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setForeheadLevel(foreheadLevel);
        }
    }

    /**
     * 设置眼距
     *
     * @param eyeDistanceLevel 眼距级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setEyeDistanceLevel(int eyeDistanceLevel) {
        mBeautyParams.mEyeDistanceLevel = eyeDistanceLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setEyeDistanceLevel(eyeDistanceLevel);
        }
    }

    /**
     * 设置眼角
     *
     * @param eyeAngleLevel 眼角级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setEyeAngleLevel(int eyeAngleLevel) {
        mBeautyParams.mEyeAngleLevel = eyeAngleLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setEyeAngleLevel(eyeAngleLevel);
        }
    }

    /**
     * 设置嘴型
     *
     * @param mouthShapeLevel 嘴型级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setMouthShapeLevel(int mouthShapeLevel) {
        mBeautyParams.mMouthShapeLevel = mouthShapeLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setMouthShapeLevel(mouthShapeLevel);
        }
    }

    private void setNoseWingLevel(int noseWingLevel) {
        mBeautyParams.mNoseWingLevel = noseWingLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setNoseWingLevel(noseWingLevel);
        }
    }

    /**
     * 设置鼻翼
     *
     * @param nosePositionLevel 鼻翼级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setNosePositionLevel(int nosePositionLevel) {
        mBeautyParams.mNosePositionLevel = nosePositionLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setNosePositionLevel(nosePositionLevel);
        }
    }

    /**
     * 设置嘴唇厚度
     *
     * @param lipsThicknessLevel 嘴唇厚度级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setLipsThicknessLevel(int lipsThicknessLevel) {
        mBeautyParams.mMouthShapeLevel = lipsThicknessLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setLipsThicknessLevel(lipsThicknessLevel);
        }
    }

    /**
     * 设置脸型
     *
     * @param faceBeautyLevel 脸型级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
     */
    private void setFaceBeautyLevel(int faceBeautyLevel) {
        mBeautyParams.mFaceBeautyLevel = faceBeautyLevel;
        if (mBeautyManager != null) {
            mBeautyManager.setFaceBeautyLevel(faceBeautyLevel);
        }
    }

    /**
     * 选择使用哪一款 AI 动效挂件
     *
     * @param tmplPath
     */
    private void setMotionTmpl(String tmplPath) {
        mBeautyParams.mMotionTmplPath = tmplPath;
        if (mBeautyManager != null) {
            mBeautyManager.setMotionTmpl(tmplPath);
        }
    }

    @Override
    public void setMotionTmplEnable(boolean enable) {
        if (mBeautyManager != null) {
            if (enable) {
                mBeautyManager.setMotionTmpl(null);
            } else {
                mBeautyManager.setMotionTmpl(mBeautyParams.mMotionTmplPath);
            }
        }
    }

    @Override
    public void fillingMaterialPath(@NonNull BeautyInfo beautyInfo) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            List<ItemInfo> tabItemList = tabInfo.getTabItemList();
            for (ItemInfo itemInfo : tabItemList) {
                itemInfo.setItemMaterialPath(SPUtils.get().getString(getMaterialPathKey(itemInfo)));
            }
        }
    }

    @Override
    public void setCurrentFilterIndex(BeautyInfo beautyInfo, int index) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
                ItemInfo itemInfo = tabInfo.getTabItemList().get(index);
                dispatchFilterEffects(itemInfo, index);
            }
        }
    }

    @Override
    public void setCurrentBeautyIndex(@NonNull BeautyInfo beautyInfo, int index) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_BEAUTY) {
                ItemInfo itemInfo = tabInfo.getTabItemList().get(index);
                dispatchBeautyEffects(itemInfo);
            }
        }
    }

    @Override
    public void setOnFilterChangeListener(OnFilterChangeListener listener) {
        mOnFilterChangeListener = listener;
    }

    /**
     * 清空美颜配置，如果SDK是新创建的则不需要最后清理，如果SDK是单例，需要调用此方法清空上次设置的美颜参数<br/>
     * 示例：TXUGCRecord是单例，需要调用，TXLivePusher每次创建新的，不需要调用
     */
    @Override
    public void clear() {
        mBeautyParams = new BeautyParams();
        if (mBeautyManager != null) {
            mBeautyManager.setFilter(mBeautyParams.mFilterBmp);
            mBeautyManager.setFilterStrength(mBeautyParams.mFilterMixLevel);
            mBeautyManager.setGreenScreenFile(mBeautyParams.mGreenFile);
            mBeautyManager.setBeautyStyle(mBeautyParams.mBeautyStyle);
            mBeautyManager.setBeautyLevel(mBeautyParams.mBeautyLevel);
            mBeautyManager.setWhitenessLevel(mBeautyParams.mWhiteLevel);
            mBeautyManager.setRuddyLevel(mBeautyParams.mRuddyLevel);
            mBeautyManager.setEyeScaleLevel(mBeautyParams.mBigEyeLevel);
            mBeautyManager.setFaceSlimLevel(mBeautyParams.mFaceSlimLevel);
            mBeautyManager.setFaceVLevel(mBeautyParams.mFaceVLevel);
            mBeautyManager.setChinLevel(mBeautyParams.mChinSlimLevel);
            mBeautyManager.setFaceShortLevel(mBeautyParams.mFaceShortLevel);
            mBeautyManager.setNoseSlimLevel(mBeautyParams.mNoseSlimLevel);
            mBeautyManager.setEyeLightenLevel(mBeautyParams.mEyeLightenLevel);
            mBeautyManager.setToothWhitenLevel(mBeautyParams.mToothWhitenLevel);
            mBeautyManager.setWrinkleRemoveLevel(mBeautyParams.mWrinkleRemoveLevel);
            mBeautyManager.setPounchRemoveLevel(mBeautyParams.mPounchRemoveLevel);
            mBeautyManager.setSmileLinesRemoveLevel(mBeautyParams.mSmileLinesRemoveLevel);
            mBeautyManager.setForeheadLevel(mBeautyParams.mForeheadLevel);
            mBeautyManager.setEyeDistanceLevel(mBeautyParams.mEyeDistanceLevel);
            mBeautyManager.setEyeAngleLevel(mBeautyParams.mEyeAngleLevel);
            mBeautyManager.setMouthShapeLevel(mBeautyParams.mMouthShapeLevel);
            mBeautyManager.setNoseWingLevel(mBeautyParams.mNoseWingLevel);
            mBeautyManager.setNosePositionLevel(mBeautyParams.mNosePositionLevel);
            mBeautyManager.setLipsThicknessLevel(mBeautyParams.mLipsThicknessLevel);
            mBeautyManager.setFaceBeautyLevel(mBeautyParams.mFaceBeautyLevel);
            mBeautyManager.setMotionTmpl(mBeautyParams.mMotionTmplPath);
        }
    }

    @Override
    public int getFilterProgress(@NonNull BeautyInfo beautyInfo, int index) {
        if (index < 0) {
            return 0;
        }
        List<TabInfo> beautyTabList = beautyInfo.getBeautyTabList();
        for (TabInfo tabInfo : beautyTabList) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
                List<ItemInfo> tabItemList = tabInfo.getTabItemList();
                if (index < tabItemList.size()) {
                    ItemInfo itemInfo = tabItemList.get(index);
                    return itemInfo.getItemLevel();
                } else {
                    return 0;
                }
            }
        }
        return 0;
    }

    @Override
    public ItemInfo getFilterItemInfo(BeautyInfo beautyInfo, int index) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
                return tabInfo.getTabItemList().get(index);
            }
        }
        return null;
    }

    @Override
    public int getFilterSize(@NonNull BeautyInfo beautyInfo) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
                return tabInfo.getTabItemList().size();
            }
        }
        return 0;
    }

    @Override
    public Bitmap getFilterResource(@NonNull BeautyInfo beautyInfo, int index) {
        return decodeFilterResource(getFilterItemInfo(beautyInfo, index));
    }

    @Override
    public BeautyInfo getDefaultBeauty() {
        return BeautyUtils.getDefaultBeautyInfo();
    }

    private void dispatchEffects(@NonNull TabInfo tabInfo, @IntRange(from = 0) int tabPosition, @NonNull ItemInfo itemInfo, @IntRange(from = 0) int itemPosition) {
        int tabType = tabInfo.getTabType();
        switch (tabType) {
            case BeautyConstants.TAB_TYPE_BEAUTY:
                dispatchBeautyEffects(itemInfo);
                break;
            case BeautyConstants.TAB_TYPE_FILTER:
                dispatchFilterEffects(itemInfo, itemPosition);
                break;
            case BeautyConstants.TAB_TYPE_MOTION:
            case BeautyConstants.TAB_TYPE_BEAUTY_FACE:
            case BeautyConstants.TAB_TYPE_GESTURE:
            case BeautyConstants.TAB_TYPE_CUTOUT_BACKGROUND:
                setMaterialEffects(tabInfo, itemInfo);
                break;
            case BeautyConstants.TAB_TYPE_GREEN:
                String file = "";
                if (itemInfo.getItemType() == BeautyConstants.ITEM_TYPE_GREEN_GOOD_LUCK) {
                    file = "green_1.mp4";
                }
                setGreenScreenFile(file);
                break;
            default:
                break;
        }
    }

    private void dispatchBeautyEffects(@NonNull ItemInfo itemInfo) {
        int itemType = itemInfo.getItemType();
        int level = itemInfo.getItemLevel();
        switch (itemType) {
            case BeautyConstants.ITEM_TYPE_BEAUTY_SMOOTH:           // 光滑
                setBeautyStyleAndLevel(0, level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_NATURAL:          // 自然
                setBeautyStyleAndLevel(1, level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_PITU:             // 天天p图
                setBeautyStyleAndLevel(2, level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_WHITE:            // 美白
                setWhitenessLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_RUDDY:            // 红润
                setRuddyLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_BIG_EYE:          // 大眼
                setEyeScaleLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACES_LIM:        // 瘦脸
                setFaceSlimLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACEV:            // V脸
                setFaceVLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_CHIN:             // 下巴
                setChinLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACE_SHORT:       // 短脸
                setFaceShortLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_NOSES_LIM:        // 瘦鼻
                setNoseSlimLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_EYE_BRIGHT:       // 亮眼
                setEyeLightenLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_TOOTH_WHITE:      // 白牙
                setToothWhitenLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_WRINKLE_REMOVE:   // 祛皱
                setWrinkleRemoveLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_POUCH_REMOVE:     // 祛眼袋
                setPounchRemoveLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_SMILE_LINES:      // 袪法令纹
                setSmileLinesRemoveLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FOREHEAD:         // 发际线
                setForeheadLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_EYE_DISTANCE:     // 眼距
                setEyeDistanceLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_EYE_ANGLE:        // 眼角
                setEyeAngleLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_MOUTH_SHAPE:      // 嘴型
                setMouthShapeLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_NOSEWING:         // 鼻翼
                setNoseWingLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_NOSE_POSITION:    // 鼻子位置
                setNosePositionLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_MOUSE_WIDTH:      // 嘴唇厚度
                setLipsThicknessLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACE_SHAPE:       // 脸型
                setFaceBeautyLevel(level);
                break;
        }
    }

    private void dispatchFilterEffects(@NonNull ItemInfo itemInfo, int position) {
        Bitmap bitmap = decodeFilterResource(itemInfo);
        mBeautyParams.mFilterBmp = bitmap;
        mBeautyParams.mFilterIndex = position;
        setFilter(bitmap, position);
        setFilterStrength(itemInfo.getItemLevel() / 10.0f);
    }

    private void setMaterialEffects(@NonNull final TabInfo tabInfo, @NonNull final ItemInfo itemInfo) {
        String itemMaterialPath = itemInfo.getItemMaterialPath();
        if (!TextUtils.isEmpty(itemMaterialPath)) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_GESTURE
                    && itemInfo.getItemId() == 2) { // 皮卡丘 item 特殊逻辑
                showToast(ResourceUtils.getString(R.string.beauty_palm_out));
            }
            setMotionTmpl(itemMaterialPath);
            return;
        }
        int itemType = itemInfo.getItemType();
        switch (itemType) {
            case BeautyConstants.ITEM_TYPE_MOTION_NONE:
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACE_NONE:
            case BeautyConstants.ITEM_TYPE_GESTURE_NONE:
            case BeautyConstants.ITEM_TYPE_CUTOUT_BACKGROUND_NONE:
                setMotionTmpl("");
                break;
            case BeautyConstants.ITEM_TYPE_MOTION_MATERIAL:
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACE_MATERIAL:
            case BeautyConstants.ITEM_TYPE_GESTURE_MATERIAL:
            case BeautyConstants.ITEM_TYPE_CUTOUT_BACKGROUND_MATERIAL:
                downloadVideoMaterial(tabInfo, itemInfo);
                break;
        }
    }

    private void downloadVideoMaterial(@NonNull final TabInfo tabInfo, @NonNull final ItemInfo itemInfo) {
        MaterialDownloader materialDownloader = new MaterialDownloader(mContext, ResourceUtils.getString(itemInfo.getItemName()), itemInfo.getItemMaterialUrl());
        materialDownloader.start(new DownloadListener() {

            private ProgressDialog mProgressDialog;

            @Override
            public void onDownloadFail(final String errorMsg) {
                ((Activity) mContext).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mProgressDialog != null) {
                            mProgressDialog.dismiss();
                        }
                        Toast.makeText(mContext, errorMsg, Toast.LENGTH_SHORT).show();
                    }
                });
            }

            @Override
            public void onDownloadProgress(final int progress) {
                ((Activity) mContext).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Log.i(TAG, "onDownloadProgress, progress = " + progress);
                        if (mProgressDialog == null) {
                            mProgressDialog = new ProgressDialog();
                            mProgressDialog.createLoadingDialog(mContext);
                            mProgressDialog.setCancelable(false);               // 设置是否可以通过点击Back键取消
                            mProgressDialog.setCanceledOnTouchOutside(false);   // 设置在点击Dialog外是否取消Dialog进度条
                            mProgressDialog.show();
                        }
                        mProgressDialog.setMsg(progress + "%");
                    }
                });
            }

            @Override
            public void onDownloadSuccess(String filePath) {
                itemInfo.setItemMaterialPath(filePath);
                SPUtils.get().put(getMaterialPathKey(itemInfo), filePath);

                ((Activity) mContext).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mProgressDialog != null) {
                            mProgressDialog.dismiss();
                            mProgressDialog = null;
                        }
                        setMaterialEffects(tabInfo, itemInfo);
                    }
                });
            }
        });
    }

    private Bitmap decodeFilterResource(@NonNull ItemInfo itemInfo) {
        int itemType = itemInfo.getItemType();
        int resId = 0;
        switch (itemType) {
            case BeautyConstants.ITEM_TYPE_FILTER_FACE_SHAPE:
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_STANDARD:
                resId = R.drawable.beauty_filter_biaozhun;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_ZIRAN:
                resId = R.drawable.beauty_filter_ziran;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_BAIXI:
                resId = R.drawable.beauty_filter_baixi;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_CHEERY:
                resId = R.drawable.beauty_filter_yinghong;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_CLOUD:
                resId = R.drawable.beauty_filter_yunshang;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_PURE:
                resId = R.drawable.beauty_filter_chunzhen;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_ORCHID:
                resId = R.drawable.beauty_filter_bailan;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_VITALITY:
                resId = R.drawable.beauty_filter_yuanqi;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_SUPER:
                resId = R.drawable.beauty_filter_chaotuo;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_FRAGRANCE:
                resId = R.drawable.beauty_filter_xiangfen;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_WHITE:
                resId = R.drawable.beauty_filter_white;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_ROMANTIC:
                resId = R.drawable.beauty_filter_langman;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_FRESH:
                resId = R.drawable.beauty_filter_qingxin;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_BEAUTIFUL:
                resId = R.drawable.beauty_filter_weimei;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_PINK:
                resId = R.drawable.beauty_filter_fennen;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_REMINISCENCE:
                resId = R.drawable.beauty_filter_huaijiu;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_BLUES:
                resId = R.drawable.beauty_filter_landiao;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_COOL:
                resId = R.drawable.beauty_filter_qingliang;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_JAPANESE:
                resId = R.drawable.beauty_filter_rixi;
                break;
        }
        if (resId != 0) {
            return decodeResource(resId);
        } else {
            return null;
        }
    }

    private Bitmap decodeResource(int id) {
        TypedValue value = new TypedValue();
        ResourceUtils.getResources().openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(ResourceUtils.getResources(), id, opts);
    }

    private String getMaterialPathKey(@NonNull ItemInfo itemInfo) {
        return itemInfo.getItemId() + "-" + itemInfo.getItemType();
    }

    private void showToast(@StringRes int resId) {
        showToast(ResourceUtils.getString(resId));
    }

    private void showToast(@NonNull String text) {
        Toast.makeText(mContext, text, Toast.LENGTH_SHORT).show();
    }
}
