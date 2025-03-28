package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.rtmp.ui.TXCloudVideoView;

@SuppressLint("ViewConstructor")
public class TUIMultimediaVideoPreview extends FrameLayout {

    private final String TAG = TUIMultimediaVideoPreview.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaVideoEditorCore mEditorCore;

    public TUIMultimediaVideoPreview(@NonNull Context context, TUIMultimediaVideoEditorCore editorCore) {
        super(context);
        mContext = context;
        mEditorCore = editorCore;
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
        mEditorCore.stopPreview();
        removeAllViews();
    }

    public void initView() {
        View rootView = LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_edit_video_play_view, this, true);
        TXCloudVideoView videoView = rootView.findViewById(R.id.edit_video_view);
        mEditorCore.startPreview(videoView, true);
    }
}
