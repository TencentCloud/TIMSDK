package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.graffiti;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIHorizontalScrollView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster.SubtitleColorItemAdapter;

@SuppressLint("ViewConstructor")
public class GraffitiOperationView extends RelativeLayout {

    public final TUIMultimediaData<Integer> mTuiDataSelectedTextColor = new TUIMultimediaData<>(Color.RED);
    private final String TAG = GraffitiOperationView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private GraffitiOperationListener mListener;

    public GraffitiOperationView(Context context) {
        super(context);
        mContext = context;
    }

    public void setGraffitiOperationListener(GraffitiOperationListener listener) {
        mListener = listener;
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
        removeAllViews();
        super.onDetachedFromWindow();
    }

    public void enableForward(boolean enable) {
        LiteavLog.i(TAG, "enableForward = " + enable);
        findViewById(R.id.graffiti_operation_forward).setEnabled(enable);
    }

    public void enableBack(boolean enable) {
        LiteavLog.i(TAG, "enableBack = " + enable);
        findViewById(R.id.graffiti_operation_back).setEnabled(enable);
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_edit_graffiti_operation_view,
                this, true);

        TUIHorizontalScrollView colorSelectScrollItemView = findViewById(R.id.graffiti_paster_color_select_view);
        SubtitleColorItemAdapter adapter = new SubtitleColorItemAdapter(mContext, mTuiDataSelectedTextColor);
        colorSelectScrollItemView.setAdapter(adapter);
        findViewById(R.id.graffiti_operation_forward).setEnabled(false);
        findViewById(R.id.graffiti_operation_back).setEnabled(false);
        findViewById(R.id.graffiti_operation_forward).setOnClickListener((v) -> {
            if (mListener != null) {
                mListener.forward();
            }
        });
        findViewById(R.id.graffiti_operation_back).setOnClickListener((v) -> {
            if (mListener != null) {
                mListener.back();
            }
        });
    }

    protected interface GraffitiOperationListener {

        void forward();

        void back();
    }
}
