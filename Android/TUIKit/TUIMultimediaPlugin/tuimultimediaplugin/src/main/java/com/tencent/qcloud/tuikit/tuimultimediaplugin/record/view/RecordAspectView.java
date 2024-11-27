package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecordCore;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo;
import com.tencent.ugc.TXRecordCommon;

@SuppressLint("ViewConstructor")
public class RecordAspectView extends RelativeLayout {

    private final String TAG = RecordAspectView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaRecordCore mRecordCore;
    private final RecordInfo mRecordInfo;

    private ImageView mImageAspectCurr;
    private int mFirstAspect;


    public RecordAspectView(Context context, TUIMultimediaRecordCore recordCore, RecordInfo recordInfo) {
        super(context);
        mContext = context;
        mRecordCore = recordCore;
        mRecordInfo = recordInfo;
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        initView();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
        removeAllViews();
    }

    private void initView() {
        View root = LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_record_aspect_view, this, true);
        mImageAspectCurr = findViewById(R.id.iv_aspect);
        selectAnotherAspect(mRecordInfo.tuiDataAspectRatio.get());
        root.setOnClickListener(v -> selectAnotherAspect(mFirstAspect));
    }

    private void selectAnotherAspect(int targetScale) {
        mRecordCore.setAspectRatio(targetScale);
        switch (targetScale) {
            case TXRecordCommon.VIDEO_ASPECT_RATIO_9_16:
                mImageAspectCurr.setImageResource(R.drawable.multimedia_plugin_record_aspect_916);
                mFirstAspect = TXRecordCommon.VIDEO_ASPECT_RATIO_3_4;
                break;
            case TXRecordCommon.VIDEO_ASPECT_RATIO_3_4:
                mImageAspectCurr.setImageResource(R.drawable.multimedia_plugin_record_aspect_34);
                mFirstAspect = TXRecordCommon.VIDEO_ASPECT_RATIO_9_16;
                break;
//            case TXRecordCommon.VIDEO_ASPECT_RATIO_FULL_SRCREEN:
//                mImageAspectCurr.setImageResource(R.drawable.multimedia_plugin_ic_aspect_11);
//                mFirstAspect = TXRecordCommon.VIDEO_ASPECT_RATIO_9_16;
//                break;
            default:
                break;
        }
    }
}
