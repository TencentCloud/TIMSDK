package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.brush;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIHorizontalScrollView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.brush.BrushControlView.BrushMode;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster.SubtitleColorItemAdapter;

@SuppressLint("ViewConstructor")
public class BrushToolView extends RelativeLayout {

    public final TUIMultimediaData<Integer> mTuiDataSelectedTextColor = new TUIMultimediaData<>(Color.RED);
    private final String TAG = BrushToolView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private BrushToolListener mListener;
    private BrushMode mBrushMode;
    private TUIHorizontalScrollView mColorSelectScrollItemView;

    public BrushToolView(Context context) {
        super(context);
        mContext = context;
    }

    public void setBrushToolListener(BrushToolListener listener) {
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

    public void setBrushMode(BrushMode brushMode) {
        mBrushMode = brushMode;
        mColorSelectScrollItemView.setVisibility(brushMode != BrushMode.MOSAIC ? VISIBLE : GONE);
    }

    public void enableRedo(boolean enable) {
        findViewById(R.id.graffiti_operation_redo).setEnabled(enable);
    }

    public void enableUndo(boolean enable) {
        findViewById(R.id.graffiti_operation_undo).setEnabled(enable);
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_edit_graffiti_operation_view,
                this, true);

        mColorSelectScrollItemView = findViewById(R.id.graffiti_paster_color_select_view);
        mColorSelectScrollItemView.setAdapter(new SubtitleColorItemAdapter(mContext, mTuiDataSelectedTextColor));
        if (mBrushMode == BrushMode.MOSAIC) {
            mColorSelectScrollItemView.setVisibility(GONE);
        }

        findViewById(R.id.graffiti_operation_redo).setEnabled(false);
        findViewById(R.id.graffiti_operation_redo).setOnClickListener((v) -> {
            if (mListener != null) {
                mListener.redo();
            }
        });

        findViewById(R.id.graffiti_operation_undo).setEnabled(false);
        findViewById(R.id.graffiti_operation_undo).setOnClickListener((v) -> {
            if (mListener != null) {
                mListener.undo();
            }
        });
    }

    public interface BrushToolListener {
        void redo();
        void undo();
    }
}
