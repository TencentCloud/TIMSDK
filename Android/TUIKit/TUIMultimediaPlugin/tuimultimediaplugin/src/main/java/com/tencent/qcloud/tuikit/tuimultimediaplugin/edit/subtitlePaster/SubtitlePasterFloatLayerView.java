package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster;

import static com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaPasterInfo.PasterType.SUBTITLE_PASTER;
import static com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerView.Status.STATUS_EDIT;
import static com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerView.Status.STATUS_INIT;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaPlugin;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerViewGroup;

@SuppressLint("ViewConstructor")
public class SubtitlePasterFloatLayerView extends FloatLayerView {

    private final String TAG = SubtitlePasterFloatLayerView.class + "_" + hashCode();
    private final SubtitlePanelView mSubtitlePanelView;
    private final FloatLayerViewGroup mFloatLayerViewGroup;

    private SubtitleInfo mSubtitleTextInfo;

    private final TUIMultimediaDataObserver<Status> mOnStatusChanged = status -> {
        switch (status) {
            case STATUS_EDIT:
                setVisibility(INVISIBLE);
                onEditText();
                break;
            case STATUS_DELETE:
                onDeleted();
                break;
            default:
                break;
        }
    };

    public SubtitlePasterFloatLayerView(Context context, FloatLayerViewGroup floatLayerViewGroup,
            SubtitleInfo tuiDataTextInfo, SubtitlePanelView tuiDataSubtitlePanelView) {
        super(context);
        mSubtitlePanelView = tuiDataSubtitlePanelView;
        mSubtitleTextInfo = tuiDataTextInfo;
        setPasterType(SUBTITLE_PASTER);
        mFloatLayerViewGroup = floatLayerViewGroup;
        mFloatLayerViewGroup.addOperationView(this);
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        generatorSubtitlePaster(mSubtitleTextInfo);
        addObserve();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
        removeObserve();
    }

    private void onEditText() {
        mSubtitlePanelView.inputText(mSubtitleTextInfo, subtitleInfo -> {
            if (subtitleInfo != null) {
                mSubtitleTextInfo = subtitleInfo;
                generatorSubtitlePaster(subtitleInfo);
            }
            invalidate();
            setVisibility(VISIBLE);
            mTuiDataStatus.set(STATUS_INIT);
        });
    }

    private void generatorSubtitlePaster(SubtitleInfo subtitleInfo) {
        LiteavLog.i(TAG, "set subtitle text");
        if (subtitleInfo == null) {
            return;
        }

        if (subtitleInfo.getText().isEmpty()) {
            onDeleted();
            return;
        }
        LiteavLog.i(TAG, "set subtitle text = " + subtitleInfo.getText());
        SubtitlePasterGenerator pasterGenerator = new SubtitlePasterGenerator();
        pasterGenerator.setSubtitleInfo(subtitleInfo);
        Bitmap bitmap = pasterGenerator.createTextBitmap();
        setImageBitmap(bitmap);

        int subtitleWidth = mSubtitlePanelView.getTextViewWidth();
        if (bitmap != null) {
            float scale = Math.max(bitmap.getHeight() * 1.0f / getSubtitleMaxHeight(),
                    bitmap.getWidth() * 1.0f / subtitleWidth);

            scale = Math.max(scale, pasterGenerator.getScale());
            if (mTuiDataStatus.get() != STATUS_EDIT) {
                setImageScale(1.0f / scale);
            }
        }
    }

    private void onDeleted() {
        mFloatLayerViewGroup.removeOperationView(this);
    }

    private void addObserve() {
        mTuiDataStatus.observe(mOnStatusChanged);
    }

    private void removeObserve() {
        mTuiDataStatus.removeObserver(mOnStatusChanged);
    }

    private int getSubtitleMaxHeight() {
        return (int) (TUIMultimediaResourceUtils.getScreenSize(TUIMultimediaPlugin.getAppContext()).y * 2 / 3);
    }
}